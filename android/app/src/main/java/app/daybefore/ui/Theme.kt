package app.daybefore.ui

import androidx.compose.foundation.isSystemInDarkTheme
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.darkColorScheme
import androidx.compose.runtime.Composable
import androidx.compose.ui.graphics.Color

private val DayBeforeColors = darkColorScheme(
    primary = Color(0xFFE8E4DF),
    onPrimary = Color(0xFF1A1817),
    secondary = Color(0xFFA0A0A0),
    onSecondary = Color(0xFF1A1817),
    tertiary = Color(0xFF968D86),
    background = Color(0xFF12100E),
    onBackground = Color(0xFFE8E4DF),
    surface = Color(0xFF1A1817),
    onSurface = Color(0xFFE8E4DF),
    surfaceVariant = Color(0xFF262321),
    onSurfaceVariant = Color(0xFFA0A0A0),
    outline = Color(0xFF36312D),
    error = Color(0xFFE74C3C),
    onError = Color(0xFFFFFFFF)
)

@Composable
fun DayBeforeTheme(content: @Composable () -> Unit) {
    MaterialTheme(
        colorScheme = DayBeforeColors,
        content = content
    )
}
