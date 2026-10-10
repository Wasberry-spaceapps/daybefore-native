import Foundation

class SettingsService {
    static let shared = SettingsService()
    private let defaults = UserDefaults.standard

    var token: String? {
        get { defaults.string(forKey: "daybefore_token") }
        set { defaults.set(newValue, forKey: "daybefore_token") }
    }

    var email: String? {
        get { defaults.string(forKey: "daybefore_email") }
        set { defaults.set(newValue, forKey: "daybefore_email") }
    }

    var salt: String? {
        get { defaults.string(forKey: "daybefore_salt") }
        set { defaults.set(newValue, forKey: "daybefore_salt") }
    }

    var wrappedKeyPwd: String? {
        get { defaults.string(forKey: "daybefore_wrappedKeyPwd") }
        set { defaults.set(newValue, forKey: "daybefore_wrappedKeyPwd") }
    }

    var lastSync: Int64 {
        get { Int64(defaults.integer(forKey: "daybefore_lastSync")) }
        set { defaults.set(Int(newValue), forKey: "daybefore_lastSync") }
    }

    func clear() {
        defaults.removeObject(forKey: "daybefore_token")
        defaults.removeObject(forKey: "daybefore_email")
        defaults.removeObject(forKey: "daybefore_salt")
        defaults.removeObject(forKey: "daybefore_wrappedKeyPwd")
        defaults.removeObject(forKey: "daybefore_lastSync")
    }
}
