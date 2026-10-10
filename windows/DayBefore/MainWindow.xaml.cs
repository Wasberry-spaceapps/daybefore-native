using System.Diagnostics;
using System.IO;
using System.IO.Compression;
using System.Text.Json;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Input;
using System.Windows.Media;
using System.Windows.Shapes;
using System.Windows.Threading;

namespace DayBefore;

public partial class MainWindow : Window
{
    private readonly DatabaseService _db = new();
    private readonly DispatcherTimer _autosaveTimer;
    private readonly DispatcherTimer _deleteTimer;
    private readonly DispatcherTimer _gameTimer;

    private enum ActiveType { None, Journal, Core, Issue }
    private ActiveType _activeType = ActiveType.None;
    private string? _activeId;
    private bool _suppressTextChanged;
    private byte[]? _dataKey;

    private ActiveType _pendingDeleteType;
    private string? _pendingDeleteId;
    private string? _pendingDeleteLabel;

    private double _carY, _carVelocity;
    private bool _carGrounded = true, _gameOver;
    private readonly List<(double x, double height)> _obstacles = [];
    private int _gameScore, _frameCount;
    private readonly Random _random = new();
    private bool _isLocked;

    public MainWindow()
    {
        InitializeComponent();
        _autosaveTimer = new DispatcherTimer { Interval = TimeSpan.FromSeconds(1) };
        _autosaveTimer.Tick += AutosaveTimer_Tick;
        _deleteTimer = new DispatcherTimer { Interval = TimeSpan.FromSeconds(5) };
        _deleteTimer.Tick += DeleteTimer_Tick;
        _gameTimer = new DispatcherTimer { Interval = TimeSpan.FromMilliseconds(16) };
        _gameTimer.Tick += GameTimer_Tick;
        Loaded += MainWindow_Loaded;
    }

    private async void MainWindow_Loaded(object sender, RoutedEventArgs e)
    {
        RefreshAll();
        var settings = SettingsService.Load();
        if (!string.IsNullOrEmpty(settings.Token) && !string.IsNullOrEmpty(settings.Salt) && !string.IsNullOrEmpty(settings.WrappedKeyPwd))
        {
            try
            {
                var info = await ApiService.GetAccountInfo(settings.Token);
                if (info?.SubscriptionStatus == "active")
                {
                    SubStatusLabel.Text = "PAID — sync active";
                    SubStatusLabel.Visibility = Visibility.Visible;
                    ManageSubBtn.Visibility = Visibility.Visible;
                }
            }
            catch { }
        }
    }

    private void TitleBar_MouseDown(object sender, MouseButtonEventArgs e) { if (e.ClickCount == 2) Maximize_Click(sender, e); else DragMove(); }
    private void Minimize_Click(object sender, RoutedEventArgs e) => WindowState = WindowState.Minimized;
    private void Maximize_Click(object sender, RoutedEventArgs e) => WindowState = WindowState == WindowState.Maximized ? WindowState.Normal : WindowState.Maximized;
    private void Close_Click(object sender, RoutedEventArgs e) => Close();

    private void Window_Deactivated(object sender, EventArgs e)
    {
        var settings = SettingsService.Load();
        if (!string.IsNullOrEmpty(settings.Token) && !_isLocked)
        {
            _isLocked = true;
            _dataKey = null;
            LockOverlay.Visibility = Visibility.Visible;
            LockPasswordBox.Clear();
            LockErrorLabel.Text = "";
        }
    }

    private void LockPassword_KeyDown(object sender, KeyEventArgs e) { if (e.Key == Key.Enter) Unlock_Click(sender, e); }

    private void Unlock_Click(object sender, RoutedEventArgs e)
    {
        var password = LockPasswordBox.Password;
        if (string.IsNullOrEmpty(password)) { LockErrorLabel.Text = "Please enter your password."; return; }
        try
        {
            var settings = SettingsService.Load();
            if (string.IsNullOrEmpty(settings.Salt) || string.IsNullOrEmpty(settings.WrappedKeyPwd)) { LockErrorLabel.Text = "No credentials stored."; return; }
            var saltBytes = Convert.FromBase64String(settings.Salt);
            var pwdKey = CryptoService.DeriveKey(password, saltBytes);
            _dataKey = CryptoService.UnwrapDataKey(settings.WrappedKeyPwd, pwdKey);
            _isLocked = false;
            LockOverlay.Visibility = Visibility.Collapsed;
        }
        catch { LockErrorLabel.Text = "That password did not match."; }
    }

    private void LockGoHome_Click(object sender, RoutedEventArgs e)
    {
        SettingsService.Clear();
        _isLocked = false;
        new AuthWindow().Show();
        Close();
    }

    private void RefreshAll() { RefreshJournalList(); RefreshCoreList(); RefreshIssueList(); }

    private void RefreshJournalList()
    {
        var entries = _db.GetJournalEntries();
        JournalList.ItemsSource = entries;
        if (_activeType == ActiveType.Journal && _activeId != null)
            JournalList.SelectedItem = entries.FirstOrDefault(e => e.Id == _activeId);
    }

    private void RefreshCoreList()
    {
        var points = _db.GetCorePoints();
        CoreList.ItemsSource = points;
        if (_activeType == ActiveType.Core && _activeId != null)
            CoreList.SelectedItem = points.FirstOrDefault(p => p.Id == _activeId);
    }

    private void RefreshIssueList()
    {
        var issues = _db.GetIssues().Where(i => !i.IsArchived).ToList();
        IssueList.ItemsSource = issues;
        if (_activeType == ActiveType.Issue && _activeId != null)
            IssueList.SelectedItem = issues.FirstOrDefault(i => i.Id == _activeId);
    }

    private void OpenJournalEntry(JournalEntry entry)
    {
        _autosaveTimer.Stop();
        _activeType = ActiveType.Journal;
        _activeId = entry.Id;
        _suppressTextChanged = true;
        EntryTitleBlock.Text = entry.DisplayDate.Replace(" ", "_") + ".md";
        EntryTitleBlock.Visibility = Visibility.Visible;
        EntryTitleInput.Visibility = Visibility.Collapsed;
        EditorBox.Text = entry.Content;
        _suppressTextChanged = false;
        ShowEditor();
    }

    private void OpenCorePoint(CorePoint point)
    {
        _autosaveTimer.Stop();
        _activeType = ActiveType.Core;
        _activeId = point.Id;
        _suppressTextChanged = true;
        EntryTitleInput.Text = point.Name;
        EntryTitleBlock.Visibility = Visibility.Collapsed;
        EntryTitleInput.Visibility = Visibility.Visible;
        EditorBox.Text = point.Content;
        _suppressTextChanged = false;
        ShowEditor();
    }

    private void OpenIssue(Issue issue)
    {
        _autosaveTimer.Stop();
        _activeType = ActiveType.Issue;
        _activeId = issue.Id;
        _suppressTextChanged = true;
        EntryTitleInput.Text = issue.Name;
        EntryTitleBlock.Visibility = Visibility.Collapsed;
        EntryTitleInput.Visibility = Visibility.Visible;
        EditorBox.Text = issue.Content ?? "";
        _suppressTextChanged = false;
        ShowEditor();
    }

    private void ShowEditor()
    {
        EmptyState.Visibility = Visibility.Collapsed;
        ToolbarPanel.Visibility = Visibility.Visible;
        EditorBox.Visibility = Visibility.Visible;
        AutosavedLabel.Visibility = Visibility.Collapsed;
        EditorBox.Focus();
    }

    private void ClearEditor()
    {
        _activeType = ActiveType.None;
        _activeId = null;
        EmptyState.Visibility = Visibility.Visible;
        ToolbarPanel.Visibility = Visibility.Collapsed;
        EditorBox.Visibility = Visibility.Collapsed;
        JournalList.SelectedItem = null;
        CoreList.SelectedItem = null;
        IssueList.SelectedItem = null;
    }

    private void NewJournal_Click(object sender, RoutedEventArgs e)
    {
        var entry = new JournalEntry { Id = Guid.NewGuid().ToString(), Content = "", CreatedAt = DateTimeOffset.UtcNow.ToUnixTimeMilliseconds(), UpdatedAt = DateTimeOffset.UtcNow.ToUnixTimeMilliseconds() };
        _db.SaveJournalEntry(entry);
        RefreshJournalList();
        OpenJournalEntry(entry);
        JournalList.SelectedItem = ((List<JournalEntry>)JournalList.ItemsSource).FirstOrDefault(e2 => e2.Id == entry.Id);
    }

    private void NewCorePoint_Click(object sender, RoutedEventArgs e) { NewCoreNameBox.Text = ""; NewCoreNameBox.Visibility = Visibility.Visible; NewCoreNameBox.Focus(); }
    private void NewIssue_Click(object sender, RoutedEventArgs e) { NewIssueNameBox.Text = ""; NewIssueNameBox.Visibility = Visibility.Visible; NewIssueNameBox.Focus(); }

    private void NewCoreName_KeyDown(object sender, KeyEventArgs e) { if (e.Key == Key.Enter) CommitNewCorePoint(); else if (e.Key == Key.Escape) NewCoreNameBox.Visibility = Visibility.Collapsed; }
    private void NewCoreName_LostFocus(object sender, RoutedEventArgs e) { if (!string.IsNullOrWhiteSpace(NewCoreNameBox.Text)) CommitNewCorePoint(); else NewCoreNameBox.Visibility = Visibility.Collapsed; }

    private void CommitNewCorePoint()
    {
        var name = NewCoreNameBox.Text.Trim();
        if (string.IsNullOrEmpty(name)) return;
        NewCoreNameBox.Visibility = Visibility.Collapsed;
        var pt = new CorePoint { Id = Guid.NewGuid().ToString(), Name = name, Content = "", CreatedAt = DateTimeOffset.UtcNow.ToUnixTimeMilliseconds(), UpdatedAt = DateTimeOffset.UtcNow.ToUnixTimeMilliseconds() };
        _db.SaveCorePoint(pt);
        RefreshCoreList();
        OpenCorePoint(pt);
        CoreList.SelectedItem = ((List<CorePoint>)CoreList.ItemsSource).FirstOrDefault(p => p.Id == pt.Id);
    }

    private void NewIssueName_KeyDown(object sender, KeyEventArgs e) { if (e.Key == Key.Enter) CommitNewIssue(); else if (e.Key == Key.Escape) NewIssueNameBox.Visibility = Visibility.Collapsed; }
    private void NewIssueName_LostFocus(object sender, RoutedEventArgs e) { if (!string.IsNullOrWhiteSpace(NewIssueNameBox.Text)) CommitNewIssue(); else NewIssueNameBox.Visibility = Visibility.Collapsed; }

    private void CommitNewIssue()
    {
        var name = NewIssueNameBox.Text.Trim();
        if (string.IsNullOrEmpty(name)) return;
        NewIssueNameBox.Visibility = Visibility.Collapsed;
        var issue = new Issue { Id = Guid.NewGuid().ToString(), Name = name, Content = "", CreatedAt = DateTimeOffset.UtcNow.ToUnixTimeMilliseconds(), UpdatedAt = DateTimeOffset.UtcNow.ToUnixTimeMilliseconds() };
        _db.SaveIssue(issue);
        RefreshIssueList();
        OpenIssue(issue);
        IssueList.SelectedItem = ((List<Issue>)IssueList.ItemsSource).FirstOrDefault(i => i.Id == issue.Id);
    }

    private void JournalList_SelectionChanged(object sender, SelectionChangedEventArgs e) { if (JournalList.SelectedItem is JournalEntry entry) { CoreList.SelectedItem = null; IssueList.SelectedItem = null; OpenJournalEntry(entry); } }
    private void CoreList_SelectionChanged(object sender, SelectionChangedEventArgs e) { if (CoreList.SelectedItem is CorePoint pt) { JournalList.SelectedItem = null; IssueList.SelectedItem = null; OpenCorePoint(pt); } }
    private void IssueList_SelectionChanged(object sender, SelectionChangedEventArgs e) { if (IssueList.SelectedItem is Issue issue) { JournalList.SelectedItem = null; CoreList.SelectedItem = null; OpenIssue(issue); } }

    private void EditorBox_TextChanged(object sender, TextChangedEventArgs e) { if (_suppressTextChanged) return; _autosaveTimer.Stop(); _autosaveTimer.Start(); AutosavedLabel.Visibility = Visibility.Collapsed; }

    private void EntryTitleInput_TextChanged(object sender, TextChangedEventArgs e)
    {
        if (_suppressTextChanged || _activeId == null) return;
        var now = DateTimeOffset.UtcNow.ToUnixTimeMilliseconds();
        if (_activeType == ActiveType.Core)
        {
            var pt = _db.GetCorePoint(_activeId);
            if (pt != null) _db.SaveCorePoint(pt with { Name = EntryTitleInput.Text, UpdatedAt = now });
            RefreshCoreList();
        }
        else if (_activeType == ActiveType.Issue)
        {
            var issue = _db.GetIssue(_activeId);
            if (issue != null) _db.SaveIssue(issue with { Name = EntryTitleInput.Text, UpdatedAt = now });
            RefreshIssueList();
        }
    }

    private void AutosaveTimer_Tick(object? sender, EventArgs e)
    {
        _autosaveTimer.Stop();
        if (_activeId == null) return;
        var now = DateTimeOffset.UtcNow.ToUnixTimeMilliseconds();
        var text = EditorBox.Text;
        if (_activeType == ActiveType.Journal)
        {
            var entry = _db.GetJournalEntry(_activeId);
            if (entry != null) _db.SaveJournalEntry(entry with { Content = text, UpdatedAt = now });
            RefreshJournalList();
        }
        else if (_activeType == ActiveType.Core)
        {
            var pt = _db.GetCorePoint(_activeId);
            if (pt != null) _db.SaveCorePoint(pt with { Content = text, UpdatedAt = now });
            RefreshCoreList();
        }
        else if (_activeType == ActiveType.Issue)
        {
            var issue = _db.GetIssue(_activeId);
            if (issue != null) _db.SaveIssue(issue with { Content = text, UpdatedAt = now });
            RefreshIssueList();
        }
        AutosavedLabel.Visibility = Visibility.Visible;
    }

    private void DeleteEntry_Click(object sender, RoutedEventArgs e)
    {
        if (_activeId == null) return;
        _deleteTimer.Stop();
        _pendingDeleteType = _activeType;
        _pendingDeleteId = _activeId;
        _pendingDeleteLabel = _activeType switch
        {
            ActiveType.Journal => _db.GetJournalEntry(_activeId)?.DisplayDate ?? "entry",
            ActiveType.Core => _db.GetCorePoint(_activeId)?.Name ?? "item",
            ActiveType.Issue => _db.GetIssue(_activeId)?.Name ?? "item",
            _ => "item"
        };
        ToastLabel.Text = $"Deleting \"{_pendingDeleteLabel}\"…";
        ToastPanel.Visibility = Visibility.Visible;
        _deleteTimer.Start();
        ClearEditor();
    }

    private void DeleteTimer_Tick(object? sender, EventArgs e)
    {
        _deleteTimer.Stop();
        ToastPanel.Visibility = Visibility.Collapsed;
        if (_pendingDeleteId == null) return;
        switch (_pendingDeleteType)
        {
            case ActiveType.Journal: _db.DeleteJournalEntry(_pendingDeleteId); RefreshJournalList(); break;
            case ActiveType.Core: _db.DeleteCorePoint(_pendingDeleteId); RefreshCoreList(); break;
            case ActiveType.Issue: _db.DeleteIssue(_pendingDeleteId); RefreshIssueList(); break;
        }
        _pendingDeleteId = null;
    }

    private void Undo_Click(object sender, RoutedEventArgs e)
    {
        _deleteTimer.Stop();
        ToastPanel.Visibility = Visibility.Collapsed;
        if (_pendingDeleteId == null) return;
        var id = _pendingDeleteId;
        _pendingDeleteId = null;
        switch (_pendingDeleteType)
        {
            case ActiveType.Journal: var je = _db.GetJournalEntry(id); if (je != null) { RefreshJournalList(); OpenJournalEntry(je); JournalList.SelectedItem = ((List<JournalEntry>)JournalList.ItemsSource).FirstOrDefault(x => x.Id == id); } break;
            case ActiveType.Core: var cp = _db.GetCorePoint(id); if (cp != null) { RefreshCoreList(); OpenCorePoint(cp); CoreList.SelectedItem = ((List<CorePoint>)CoreList.ItemsSource).FirstOrDefault(x => x.Id == id); } break;
            case ActiveType.Issue: var iss = _db.GetIssue(id); if (iss != null) { RefreshIssueList(); OpenIssue(iss); IssueList.SelectedItem = ((List<Issue>)IssueList.ItemsSource).FirstOrDefault(x => x.Id == id); } break;
        }
    }

    private void ToggleJournal_Click(object sender, RoutedEventArgs e) { var visible = JournalList.Visibility == Visibility.Visible; JournalList.Visibility = visible ? Visibility.Collapsed : Visibility.Visible; JournalToggleBtn.Content = visible ? "show" : "hide"; }
    private void ToggleCore_Click(object sender, RoutedEventArgs e) { var visible = CoreList.Visibility == Visibility.Visible; CoreList.Visibility = visible ? Visibility.Collapsed : Visibility.Visible; NewCoreNameBox.Visibility = Visibility.Collapsed; CoreToggleBtn.Content = visible ? "show" : "hide"; }
    private void ToggleIssue_Click(object sender, RoutedEventArgs e) { var visible = IssueList.Visibility == Visibility.Visible; IssueList.Visibility = visible ? Visibility.Collapsed : Visibility.Visible; NewIssueNameBox.Visibility = Visibility.Collapsed; IssueToggleBtn.Content = visible ? "show" : "hide"; }

    private void Export_Click(object sender, RoutedEventArgs e)
    {
        var dlg = new Microsoft.Win32.SaveFileDialog { FileName = $"daybefore-export-{DateTime.Now:yyyyMMdd}", DefaultExt = ".zip", Filter = "ZIP Archive (.zip)|*.zip|JSON (.json)|*.json" };
        if (dlg.ShowDialog() != true) return;
        var ext = System.IO.Path.GetExtension(dlg.FileName).ToLower();
        if (ext == ".zip") ExportMarkdownZip(dlg.FileName);
        else ExportJson(dlg.FileName);
    }

    private void ExportMarkdownZip(string path)
    {
        using var fs = new FileStream(path, FileMode.Create);
        using var archive = new ZipArchive(fs, ZipArchiveMode.Create);
        foreach (var entry in _db.GetJournalEntries()) { var e = archive.CreateEntry($"journal/{entry.DisplayDate.Replace(" ", "_")}.md"); using var writer = new StreamWriter(e.Open()); writer.Write(entry.Content); }
        foreach (var issue in _db.GetIssues()) { var e = archive.CreateEntry($"issues/{issue.Name}.md"); using var writer = new StreamWriter(e.Open()); writer.Write(issue.Content ?? ""); }
        var cpEntry = archive.CreateEntry("core-points.md"); using (var writer = new StreamWriter(cpEntry.Open())) { foreach (var cp in _db.GetCorePoints()) writer.WriteLine($"## {cp.Name}\n\n{cp.Content}\n\n---\n"); }
        MessageBox.Show("Exported successfully.", "Day Before", MessageBoxButton.OK);
    }

    private void ExportJson(string path)
    {
        var data = new { journalEntries = _db.GetJournalEntries(), corePoints = _db.GetCorePoints(), issues = _db.GetIssues(), issueEntries = _db.GetIssueEntries() };
        File.WriteAllText(path, JsonSerializer.Serialize(data, new JsonSerializerOptions { WriteIndented = true }));
        MessageBox.Show("Exported successfully.", "Day Before", MessageBoxButton.OK);
    }

    private async void ManageSubscription_Click(object sender, RoutedEventArgs e)
    {
        var settings = SettingsService.Load();
        if (string.IsNullOrEmpty(settings.Token)) return;
        try { var url = await ApiService.GetPortalUrl(settings.Token); if (!string.IsNullOrEmpty(url)) Process.Start(new ProcessStartInfo(url) { UseShellExecute = true }); else Process.Start(new ProcessStartInfo("mailto:mutairuwasiu929@gmail.com?subject=Cancel%20Subscription") { UseShellExecute = true }); }
        catch { Process.Start(new ProcessStartInfo("mailto:mutairuwasiu929@gmail.com?subject=Cancel%20Subscription") { UseShellExecute = true }); }
    }

    private void LogOut_Click(object sender, RoutedEventArgs e)
    {
        if (MessageBox.Show("Log out? Your entries remain on this device.", "Day Before", MessageBoxButton.YesNo) == MessageBoxResult.Yes) { SettingsService.Clear(); new AuthWindow().Show(); Close(); }
    }

    private void Game_Click(object sender, RoutedEventArgs e) { GameOverlay.Visibility = Visibility.Visible; GameCanvas.Focus(); ResetGame(); _gameTimer.Start(); }
    private void CloseGame_Click(object sender, RoutedEventArgs e) { _gameTimer.Stop(); GameOverlay.Visibility = Visibility.Collapsed; }
    private void ResetGame() { _carY = 0; _carVelocity = 0; _carGrounded = true; _obstacles.Clear(); _gameScore = 0; _gameOver = false; _frameCount = 0; }
    private void GameCanvas_KeyDown(object sender, KeyEventArgs e) { if (e.Key == Key.Space) HandleGameInput(); }
    private void GameCanvas_MouseDown(object sender, MouseButtonEventArgs e) => HandleGameInput();

    private void HandleGameInput() { if (_gameOver) { ResetGame(); return; } if (_carGrounded) { _carVelocity = -12; _carGrounded = false; } }

    private void GameTimer_Tick(object? sender, EventArgs e)
    {
        if (_gameOver) { DrawGame(); return; }
        var canvasWidth = GameCanvas.ActualWidth; var canvasHeight = GameCanvas.ActualHeight;
        if (canvasWidth < 100 || canvasHeight < 100) return;
        var groundY = canvasHeight - 60;
        _carVelocity += 0.7; _carY += _carVelocity;
        if (_carY >= 0) { _carY = 0; _carVelocity = 0; _carGrounded = true; }
        _frameCount++;
        if (_frameCount % Math.Max(80, 140 - _gameScore / 10) == 0) _obstacles.Add((canvasWidth, 15 + _random.Next(20)));
        for (int i = _obstacles.Count - 1; i >= 0; i--) { var obs = _obstacles[i]; _obstacles[i] = (obs.x - 5, obs.height); if (_obstacles[i].x < -30) _obstacles.RemoveAt(i); }
        foreach (var obs in _obstacles) { if (60 + 50 > obs.x && 60 < obs.x + 25 && groundY - 25 + _carY + 25 > groundY - obs.height) { _gameOver = true; break; } }
        _gameScore++;
        DrawGame();
    }

    private void DrawGame()
    {
        GameCanvas.Children.Clear();
        var canvasWidth = GameCanvas.ActualWidth; var canvasHeight = GameCanvas.ActualHeight; var groundY = canvasHeight - 60;
        GameCanvas.Children.Add(new Line { X1 = 0, Y1 = groundY, X2 = canvasWidth, Y2 = groundY, Stroke = new SolidColorBrush(Color.FromRgb(0x33, 0x33, 0x33)), StrokeThickness = 1 });
        var car = new Rectangle { Width = 50, Height = 25, Fill = new SolidColorBrush(Color.FromRgb(0xa0, 0xa0, 0xa0)) }; Canvas.SetLeft(car, 60); Canvas.SetTop(car, groundY - 25 + _carY); GameCanvas.Children.Add(car);
        foreach (var obs in _obstacles) { var rect = new Rectangle { Width = 25, Height = obs.height, Fill = new SolidColorBrush(Color.FromRgb(0x33, 0x33, 0x33)) }; Canvas.SetLeft(rect, obs.x); Canvas.SetTop(rect, groundY - obs.height); GameCanvas.Children.Add(rect); }
        var scoreText = new TextBlock { Text = $"Distance: {_gameScore}", Foreground = new SolidColorBrush(Color.FromRgb(0xa0, 0xa0, 0xa0)), FontSize = 14 }; Canvas.SetLeft(scoreText, 20); Canvas.SetTop(scoreText, 20); GameCanvas.Children.Add(scoreText);
        if (_gameOver) { var gameOverText = new TextBlock { Text = "Finished. Click to restart.", Foreground = new SolidColorBrush(Color.FromRgb(0xa0, 0xa0, 0xa0)), FontSize = 18 }; Canvas.SetLeft(gameOverText, canvasWidth / 2 - 100); Canvas.SetTop(gameOverText, canvasHeight / 2); GameCanvas.Children.Add(gameOverText); }
    }
}
