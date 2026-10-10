using System.IO;
using System.Windows;
using System.Windows.Input;

namespace DayBefore;

public partial class AuthWindow : Window
{
    private bool _isLogin = true;
    private string _recoveryKey = "";
    private string _email = "";
    private byte[]? _dataKey;

    public AuthWindow()
    {
        InitializeComponent();
        EmailBox.Focus();
    }

    private void TitleBar_MouseDown(object sender, MouseButtonEventArgs e) => DragMove();
    private void Close_Click(object sender, RoutedEventArgs e) => Close();
    private void Password_KeyDown(object sender, KeyEventArgs e) { if (e.Key == Key.Enter) Submit_Click(sender, e); }

    private void ToggleMode_Click(object sender, RoutedEventArgs e)
    {
        _isLogin = !_isLogin;
        FormTitle.Text = _isLogin ? "Log In" : "Create Account";
        SubmitBtn.Content = _isLogin ? "Log In" : "Register";
        ToggleModeBtn.Content = _isLogin ? "Don't have an account? Register" : "Already have an account? Log In";
        ForgotBtn.Visibility = _isLogin ? Visibility.Visible : Visibility.Collapsed;
        ErrorLabel.Text = "";
    }

    private void Forgot_Click(object sender, RoutedEventArgs e)
    {
        AuthPanel.Visibility = Visibility.Collapsed;
        ForgotPanel.Visibility = Visibility.Visible;
        ForgotEmailBox.Text = EmailBox.Text;
        ForgotEmailBox.Focus();
    }

    private void BackToLogin_Click(object sender, RoutedEventArgs e)
    {
        ForgotPanel.Visibility = Visibility.Collapsed;
        AuthPanel.Visibility = Visibility.Visible;
        ForgotErrorLabel.Text = "";
    }

    private async void Submit_Click(object sender, RoutedEventArgs e)
    {
        var email = EmailBox.Text.Trim();
        var password = PasswordBox.Password;

        if (string.IsNullOrEmpty(email) || string.IsNullOrEmpty(password))
        {
            ErrorLabel.Text = "Please enter email and password.";
            return;
        }

        ErrorLabel.Text = "";
        SubmitBtn.Content = "Processing...";
        SubmitBtn.IsEnabled = false;

        try
        {
            var passwordHash = CryptoService.HashPassword(password);

            if (_isLogin)
            {
                var result = await ApiService.Login(email, passwordHash);
                if (result == null) { ErrorLabel.Text = "Login failed."; return; }

                var settings = SettingsService.Load();
                settings.Token = result.Token;
                settings.Salt = result.Salt;
                settings.Email = email;

                byte[] saltBytes;
                if (!string.IsNullOrEmpty(result.Salt))
                {
                    try { saltBytes = Convert.FromBase64String(result.Salt); }
                    catch { saltBytes = System.Text.Encoding.UTF8.GetBytes("daybefore-salt"); }
                }
                else
                {
                    saltBytes = System.Text.Encoding.UTF8.GetBytes("daybefore-salt");
                }

                var pwdKey = CryptoService.DeriveKey(password, saltBytes);

                if (!string.IsNullOrEmpty(result.WrappedKeyPwd))
                {
                    settings.WrappedKeyPwd = result.WrappedKeyPwd;
                    _dataKey = CryptoService.UnwrapDataKey(result.WrappedKeyPwd, pwdKey);
                    SettingsService.Save(settings);
                    OpenMainWindow();
                }
                else
                {
                    _dataKey = pwdKey;
                    _recoveryKey = CryptoService.GenerateRecoveryKey();
                    var recKey = CryptoService.DeriveRecoveryKey(_recoveryKey);
                    var wrappedPwd = CryptoService.WrapDataKey(pwdKey, pwdKey);
                    var wrappedRec = CryptoService.WrapDataKey(pwdKey, recKey);

                    settings.WrappedKeyPwd = wrappedPwd;
                    SettingsService.Save(settings);

                    try { await ApiService.MigrateV2(result.Token, wrappedPwd, wrappedRec); } catch { }

                    _email = email;
                    RecoveryTitle.Text = "Account Upgraded — Recovery Key";
                    RecoveryDesc.Text = "Your account has been upgraded to stronger encryption. This recovery key is the only way to access your entries if you forget your password. This screen appears once — save it now.";
                    RecoveryKeyLabel.Text = _recoveryKey;
                    AuthPanel.Visibility = Visibility.Collapsed;
                    RecoveryPanel.Visibility = Visibility.Visible;
                }
            }
            else
            {
                var salt = CryptoService.GenerateSalt();
                var saltB64 = Convert.ToBase64String(salt);
                var pwdKey = CryptoService.DeriveKey(password, salt);
                var dataKey = CryptoService.GenerateDataKey();
                _recoveryKey = CryptoService.GenerateRecoveryKey();
                var recKey = CryptoService.DeriveRecoveryKey(_recoveryKey);
                var wrappedPwd = CryptoService.WrapDataKey(dataKey, pwdKey);
                var wrappedRec = CryptoService.WrapDataKey(dataKey, recKey);

                var result = await ApiService.Register(email, passwordHash, saltB64, wrappedPwd, wrappedRec);
                if (result == null) { ErrorLabel.Text = "Registration failed."; return; }

                var settings = SettingsService.Load();
                settings.Token = result.Token;
                settings.Salt = saltB64;
                settings.Email = email;
                settings.WrappedKeyPwd = wrappedPwd;
                SettingsService.Save(settings);

                _dataKey = dataKey;
                _email = email;
                RecoveryTitle.Text = "Your Recovery Key";
                RecoveryDesc.Text = "This key is the only way to recover your journal if you forget your password. Nobody can reset it for you — that is the honest trade-off of real encryption. Write it down or keep it somewhere safe.";
                RecoveryKeyLabel.Text = _recoveryKey;
                AuthPanel.Visibility = Visibility.Collapsed;
                RecoveryPanel.Visibility = Visibility.Visible;
            }
        }
        catch (Exception ex)
        {
            ErrorLabel.Text = ex.Message;
        }
        finally
        {
            SubmitBtn.Content = _isLogin ? "Log In" : "Register";
            SubmitBtn.IsEnabled = true;
        }
    }

    private void DownloadRecovery_Click(object sender, RoutedEventArgs e)
    {
        var dlg = new Microsoft.Win32.SaveFileDialog
        {
            FileName = "daybefore-recovery-key",
            DefaultExt = ".txt",
            Filter = "Text file (.txt)|*.txt"
        };
        if (dlg.ShowDialog() == true)
        {
            File.WriteAllText(dlg.FileName, _recoveryKey);
            MessageBox.Show("Recovery key saved.", "Day Before", MessageBoxButton.OK);
        }
    }

    private void RecoverySaved_Click(object sender, RoutedEventArgs e) => OpenMainWindow();

    private async void ResetPassword_Click(object sender, RoutedEventArgs e)
    {
        var email = ForgotEmailBox.Text.Trim();
        var recoveryKey = RecoveryKeyInput.Text.Trim();
        var newPassword = NewPasswordBox.Password;

        if (string.IsNullOrEmpty(email) || string.IsNullOrEmpty(recoveryKey) || string.IsNullOrEmpty(newPassword))
        {
            ForgotErrorLabel.Text = "All fields are required.";
            return;
        }

        ForgotErrorLabel.Text = "";

        try
        {
            var passwordHash = CryptoService.HashPassword(newPassword);
            var result = await ApiService.ResetPassword(email, recoveryKey);
            if (result == null || string.IsNullOrEmpty(result.WrappedKeyRecovery))
            {
                ForgotErrorLabel.Text = "Invalid recovery key or email.";
                return;
            }

            var recKey = CryptoService.DeriveRecoveryKey(recoveryKey);
            var dataKey = CryptoService.UnwrapDataKey(result.WrappedKeyRecovery, recKey);

            var salt = CryptoService.GenerateSalt();
            var saltB64 = Convert.ToBase64String(salt);
            var pwdKey = CryptoService.DeriveKey(newPassword, salt);
            var wrappedPwd = CryptoService.WrapDataKey(dataKey, pwdKey);
            var wrappedRec = CryptoService.WrapDataKey(dataKey, recKey);

            await ApiService.UpdatePassword(email, passwordHash, saltB64, wrappedPwd, wrappedRec);

            MessageBox.Show("Password reset successfully. Please log in.", "Day Before", MessageBoxButton.OK);
            BackToLogin_Click(sender, e);
        }
        catch (Exception ex)
        {
            ForgotErrorLabel.Text = ex.Message;
        }
    }

    private void OpenMainWindow()
    {
        var main = new MainWindow();
        main.Show();
        Close();
    }
}
