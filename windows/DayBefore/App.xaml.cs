using System.Windows;

namespace DayBefore;

public partial class App : Application
{
    protected override void OnStartup(StartupEventArgs e)
    {
        base.OnStartup(e);

        var settings = SettingsService.Load();
        if (string.IsNullOrEmpty(settings.Token))
        {
            var auth = new AuthWindow();
            auth.Show();
        }
        else
        {
            var main = new MainWindow();
            main.Show();
        }
    }
}
