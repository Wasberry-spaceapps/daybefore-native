package app.daybefore.ui

import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Typography
import androidx.compose.material3.darkColorScheme
import androidx.compose.runtime.Composable
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.Font
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.sp
import app.daybefore.R

private val NewsreaderFamily = FontFamily(
    Font(R.font.newsreader_regular, FontWeight.Normal),
    Font(R.font.newsreader_medium, FontWeight.Medium),
)

private val InterFamily = FontFamily(
    Font(R.font.inter_regular, FontWeight.Normal),
    Font(R.font.inter_medium, FontWeight.Medium),
)

private val DayBeforeTypography = Typography(
    bodyLarge = TextStyle(fontFamily = NewsreaderFamily, fontWeight = FontWeight.Normal, fontSize = 17.sp, lineHeight = 26.sp),
    bodyMedium = TextStyle(fontFamily = NewsreaderFamily, fontWeight = FontWeight.Normal, fontSize = 15.sp, lineHeight = 22.sp),
    bodySmall = TextStyle(fontFamily = InterFamily, fontWeight = FontWeight.Normal, fontSize = 13.sp),
    labelLarge = TextStyle(fontFamily = InterFamily, fontWeight = FontWeight.Medium, fontSize = 14.sp),
    labelMedium = TextStyle(fontFamily = InterFamily, fontWeight = FontWeight.Normal, fontSize = 12.sp),
    labelSmall = TextStyle(fontFamily = InterFamily, fontWeight = FontWeight.Normal, fontSize = 11.sp),
    titleLarge = TextStyle(fontFamily = NewsreaderFamily, fontWeight = FontWeight.Normal, fontSize = 22.sp),
    titleMedium = TextStyle(fontFamily = NewsreaderFamily, fontWeight = FontWeight.Medium, fontSize = 18.sp),
    titleSmall = TextStyle(fontFamily = InterFamily, fontWeight = FontWeight.Medium, fontSize = 14.sp),
    headlineLarge = TextStyle(fontFamily = NewsreaderFamily, fontWeight = FontWeight.Normal, fontSize = 28.sp),
    headlineMedium = TextStyle(fontFamily = NewsreaderFamily, fontWeight = FontWeight.Normal, fontSize = 24.sp),
)

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
        typography = DayBeforeTypography,
        content = content
    )
}
