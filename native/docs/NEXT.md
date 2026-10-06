### NEXT STEPS (Hard Stop Reached)

1. **Fix Clicks and Responsiveness (Step 3)**
   - Replace any DragToMoveArea/window_manager with native title bar.
   - Use standard LayoutBuilder breakpoints (width < 600 phone, 600-899 small sidebar, 900+ large sidebar).
   - Ensure all tappable items use Material/InkWell with correct hit targets and hover colors.
   - Write widget/integration tests for UI layout and click behavior.

2. **Privacy Lock (Step 4)**
   - Implement AppLifecycleState listener to lock app on hidden/paused.
   - Build /lock screen with password re-entry.

3. **Design System & Go Router (Step 5 & 6)**
   - Implement tokens.dart for colors and fonts (Inter, Gelasio).
   - Refactor navigation to use go_router with ShellRoute.

4. **Export & Porting Game (Step 7 & 8)**
   - Implement export to archive/PDF using file_selector.
   - Port the web 'take a minute' game to a Flutter CustomPainter driven by a Ticker.

5. **Icons & Release (Step 9 & 11)**
   - Configure flutter_launcher_icons.
   - Setup GitHub Actions native.yml for Android and Windows build/release.