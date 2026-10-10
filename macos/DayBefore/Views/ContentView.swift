import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        if appState.isLoggedIn {
            MainView()
        } else {
            AuthView()
        }
    }
}

struct AuthView: View {
    @EnvironmentObject var appState: AppState
    @State private var isLogin = true
    @State private var email = ""
    @State private var password = ""
    @State private var error = ""
    @State private var loading = false
    @State private var recoveryKey: String?

    var body: some View {
        if let key = recoveryKey {
            VStack(spacing: 24) {
                Text("Your Recovery Key")
                    .font(.title2)
                    .fontWeight(.medium)

                Text("This key is the only way to recover your journal if you forget your password. Write it down or keep it somewhere safe.")
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)

                Text(key)
                    .font(.system(.body, design: .monospaced))
                    .padding()
                    .background(Color(white: 0.15))
                    .cornerRadius(8)

                Button("I have saved this") {
                    appState.isLoggedIn = true
                }
                .buttonStyle(.borderedProminent)
            }
            .padding(48)
            .frame(width: 400)
        } else {
            VStack(alignment: .leading, spacing: 24) {
                Text("Day Before")
                    .font(.largeTitle)
                    .fontWeight(.medium)

                Text(isLogin ? "Log In" : "Create Account")
                    .font(.title3)
                    .fontWeight(.medium)

                if !error.isEmpty {
                    Text(error)
                        .foregroundColor(.red)
                        .font(.caption)
                }

                TextField("Email address", text: $email)
                    .textFieldStyle(.roundedBorder)

                SecureField("Passphrase", text: $password)
                    .textFieldStyle(.roundedBorder)

                Button(loading ? "Processing..." : (isLogin ? "Log In" : "Register")) {
                    submit()
                }
                .disabled(loading)
                .buttonStyle(.bordered)
                .frame(maxWidth: .infinity)

                Button(isLogin ? "Don't have an account? Register" : "Already have an account? Log In") {
                    isLogin.toggle()
                    error = ""
                }
                .buttonStyle(.plain)
                .foregroundColor(.secondary)
            }
            .padding(48)
            .frame(width: 400)
        }
    }

    func submit() {
        guard !email.isEmpty, !password.isEmpty else {
            error = "Please enter email and password."
            return
        }

        loading = true
        error = ""

        Task {
            do {
                let passwordHash = CryptoService.hashPassword(password)

                if isLogin {
                    let result = try await ApiService.shared.login(email: email, passwordHash: passwordHash)
                    if let err = result.error {
                        await MainActor.run { error = err; loading = false }
                        return
                    }

                    guard let token = result.token else {
                        await MainActor.run { error = "Login failed"; loading = false }
                        return
                    }

                    SettingsService.shared.token = token
                    SettingsService.shared.salt = result.salt
                    SettingsService.shared.email = email

                    let saltData: Data
                    if let saltStr = result.salt, let decoded = Data(base64Encoded: saltStr) {
                        saltData = decoded
                    } else {
                        saltData = "daybefore-salt".data(using: .utf8)!
                    }

                    let pwdKey = CryptoService.deriveKey(password: password, salt: saltData)

                    if let wrapped = result.wrappedKeyPwd, !wrapped.isEmpty {
                        SettingsService.shared.wrappedKeyPwd = wrapped
                        await MainActor.run {
                            appState.dataKey = CryptoService.unwrapDataKey(wrapped, wrapKey: pwdKey)
                            appState.isLoggedIn = true
                            loading = false
                        }
                    } else {
                        let newRecoveryKey = CryptoService.generateRecoveryKey()
                        let recKey = CryptoService.deriveRecoveryKey(newRecoveryKey)
                        let wrappedPwd = CryptoService.wrapDataKey(pwdKey, wrapKey: pwdKey)
                        let wrappedRec = CryptoService.wrapDataKey(pwdKey, wrapKey: recKey)

                        SettingsService.shared.wrappedKeyPwd = wrappedPwd
                        try? await ApiService.shared.migrateV2(token: token, wrappedKeyPwd: wrappedPwd, wrappedKeyRecovery: wrappedRec)

                        await MainActor.run {
                            appState.dataKey = pwdKey
                            recoveryKey = newRecoveryKey
                            loading = false
                        }
                    }
                } else {
                    let salt = CryptoService.generateSalt()
                    let saltB64 = salt.base64EncodedString()
                    let pwdKey = CryptoService.deriveKey(password: password, salt: salt)
                    let dataKey = CryptoService.generateDataKey()
                    let newRecoveryKey = CryptoService.generateRecoveryKey()
                    let recKey = CryptoService.deriveRecoveryKey(newRecoveryKey)
                    let wrappedPwd = CryptoService.wrapDataKey(dataKey, wrapKey: pwdKey)
                    let wrappedRec = CryptoService.wrapDataKey(dataKey, wrapKey: recKey)

                    let result = try await ApiService.shared.register(
                        email: email,
                        passwordHash: passwordHash,
                        salt: saltB64,
                        wrappedKeyPwd: wrappedPwd,
                        wrappedKeyRecovery: wrappedRec
                    )

                    if let err = result.error {
                        await MainActor.run { error = err; loading = false }
                        return
                    }

                    SettingsService.shared.token = result.token
                    SettingsService.shared.salt = saltB64
                    SettingsService.shared.email = email
                    SettingsService.shared.wrappedKeyPwd = wrappedPwd

                    await MainActor.run {
                        appState.dataKey = dataKey
                        recoveryKey = newRecoveryKey
                        loading = false
                    }
                }
            } catch {
                await MainActor.run {
                    self.error = error.localizedDescription
                    loading = false
                }
            }
        }
    }
}
