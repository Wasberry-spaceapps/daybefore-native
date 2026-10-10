package app.daybefore

import android.content.Intent
import android.net.Uri
import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.compose.foundation.Canvas
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.geometry.Size
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.input.PasswordVisualTransformation
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.lifecycle.Lifecycle
import androidx.lifecycle.LifecycleEventObserver
import androidx.lifecycle.compose.LocalLifecycleOwner
import app.daybefore.ui.DayBeforeTheme
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch
import java.util.UUID

class MainActivity : ComponentActivity() {
    private lateinit var db: AppDatabase

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        Prefs.init(this)
        db = AppDatabase.getInstance(this)

        setContent {
            DayBeforeTheme {
                Surface(
                    modifier = Modifier.fillMaxSize(),
                    color = MaterialTheme.colorScheme.background
                ) {
                    var isLoggedIn by remember { mutableStateOf(!Prefs.token.isNullOrEmpty()) }

                    if (isLoggedIn) {
                        MainScreen(
                            db = db,
                            onLogout = {
                                Prefs.clear()
                                isLoggedIn = false
                            },
                            onManageSubscription = {
                                val scope = kotlinx.coroutines.MainScope()
                                scope.launch {
                                    val token = Prefs.token ?: return@launch
                                    val url = ApiService.getPortalUrl(token)
                                    val intent = Intent(Intent.ACTION_VIEW, Uri.parse(
                                        url ?: "https://daybefore.app"
                                    ))
                                    startActivity(intent)
                                }
                            }
                        )
                    } else {
                        AuthScreen(onSuccess = { isLoggedIn = true })
                    }
                }
            }
        }
    }
}

@Composable
fun AuthScreen(onSuccess: () -> Unit) {
    var isLogin by remember { mutableStateOf(true) }
    var email by remember { mutableStateOf("") }
    var password by remember { mutableStateOf("") }
    var error by remember { mutableStateOf("") }
    var loading by remember { mutableStateOf(false) }
    var recoveryKey by remember { mutableStateOf<String?>(null) }
    val scope = rememberCoroutineScope()

    if (recoveryKey != null) {
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(32.dp)
                .verticalScroll(rememberScrollState()),
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.Center
        ) {
            Text("Your Recovery Key", fontSize = 22.sp, fontWeight = FontWeight.Medium)
            Spacer(Modifier.height(16.dp))
            Text(
                "This key is the only way to recover your journal if you forget your password. Write it down or keep it somewhere safe.",
                color = MaterialTheme.colorScheme.tertiary,
                fontSize = 14.sp
            )
            Spacer(Modifier.height(24.dp))
            Surface(
                color = MaterialTheme.colorScheme.surfaceVariant,
                shape = MaterialTheme.shapes.medium
            ) {
                Text(
                    recoveryKey!!,
                    modifier = Modifier.padding(24.dp),
                    fontSize = 16.sp,
                    fontWeight = FontWeight.Medium
                )
            }
            Spacer(Modifier.height(32.dp))
            Button(
                onClick = { onSuccess() },
                colors = ButtonDefaults.buttonColors(
                    containerColor = MaterialTheme.colorScheme.primary,
                    contentColor = MaterialTheme.colorScheme.onPrimary
                )
            ) {
                Text("I have saved this")
            }
        }
        return
    }

    Column(
        modifier = Modifier
            .fillMaxSize()
            .padding(32.dp)
            .verticalScroll(rememberScrollState()),
        verticalArrangement = Arrangement.Center
    ) {
        Text("Day Before", fontSize = 28.sp, fontWeight = FontWeight.Medium)
        Spacer(Modifier.height(48.dp))
        Text(if (isLogin) "Log In" else "Create Account", fontSize = 18.sp, fontWeight = FontWeight.Medium)
        Spacer(Modifier.height(24.dp))

        if (error.isNotEmpty()) {
            Text(error, color = MaterialTheme.colorScheme.error, fontSize = 13.sp)
            Spacer(Modifier.height(16.dp))
        }

        OutlinedTextField(
            value = email,
            onValueChange = { email = it },
            label = { Text("Email address") },
            singleLine = true,
            modifier = Modifier.fillMaxWidth(),
            colors = OutlinedTextFieldDefaults.colors(
                focusedBorderColor = MaterialTheme.colorScheme.outline,
                unfocusedBorderColor = MaterialTheme.colorScheme.outline
            )
        )
        Spacer(Modifier.height(16.dp))
        OutlinedTextField(
            value = password,
            onValueChange = { password = it },
            label = { Text("Passphrase") },
            singleLine = true,
            visualTransformation = PasswordVisualTransformation(),
            modifier = Modifier.fillMaxWidth(),
            colors = OutlinedTextFieldDefaults.colors(
                focusedBorderColor = MaterialTheme.colorScheme.outline,
                unfocusedBorderColor = MaterialTheme.colorScheme.outline
            )
        )
        Spacer(Modifier.height(24.dp))

        OutlinedButton(
            onClick = {
                if (email.isBlank() || password.isBlank()) {
                    error = "Please enter email and password."
                    return@OutlinedButton
                }
                loading = true
                error = ""
                scope.launch {
                    try {
                        val passwordHash = CryptoService.hashPassword(password)
                        if (isLogin) {
                            val result = ApiService.login(email, passwordHash)
                            if (result.error != null) {
                                error = result.error!!
                            } else {
                                Prefs.token = result.token
                                Prefs.salt = result.salt
                                Prefs.email = email

                                val saltBytes = try {
                                    android.util.Base64.decode(result.salt, android.util.Base64.NO_WRAP)
                                } catch (e: Exception) {
                                    "daybefore-salt".toByteArray()
                                }

                                val pwdKey = CryptoService.deriveKey(password, saltBytes)
                                if (!result.wrappedKeyPwd.isNullOrEmpty()) {
                                    Prefs.wrappedKeyPwd = result.wrappedKeyPwd
                                    onSuccess()
                                } else {
                                    val newRecoveryKey = CryptoService.generateRecoveryKey()
                                    val recKey = CryptoService.deriveRecoveryKey(newRecoveryKey)
                                    val wrappedPwd = CryptoService.wrapDataKey(pwdKey, pwdKey)
                                    val wrappedRec = CryptoService.wrapDataKey(pwdKey, recKey)
                                    Prefs.wrappedKeyPwd = wrappedPwd
                                    try { ApiService.migrateV2(result.token, wrappedPwd, wrappedRec) } catch (_: Exception) {}
                                    recoveryKey = newRecoveryKey
                                }
                            }
                        } else {
                            val salt = CryptoService.generateSalt()
                            val saltB64 = android.util.Base64.encodeToString(salt, android.util.Base64.NO_WRAP)
                            val pwdKey = CryptoService.deriveKey(password, salt)
                            val dataKey = CryptoService.generateDataKey()
                            val newRecoveryKey = CryptoService.generateRecoveryKey()
                            val recKey = CryptoService.deriveRecoveryKey(newRecoveryKey)
                            val wrappedPwd = CryptoService.wrapDataKey(dataKey, pwdKey)
                            val wrappedRec = CryptoService.wrapDataKey(dataKey, recKey)

                            val result = ApiService.register(email, passwordHash, saltB64, wrappedPwd, wrappedRec)
                            if (result.error != null) {
                                error = result.error!!
                            } else {
                                Prefs.token = result.token
                                Prefs.salt = saltB64
                                Prefs.email = email
                                Prefs.wrappedKeyPwd = wrappedPwd
                                recoveryKey = newRecoveryKey
                            }
                        }
                    } catch (e: Exception) {
                        error = e.message ?: "An error occurred"
                    } finally {
                        loading = false
                    }
                }
            },
            modifier = Modifier.fillMaxWidth(),
            enabled = !loading
        ) {
            Text(if (loading) "Processing..." else if (isLogin) "Log In" else "Register")
        }

        Spacer(Modifier.height(24.dp))
        TextButton(onClick = { isLogin = !isLogin; error = "" }) {
            Text(
                if (isLogin) "Don't have an account? Register" else "Already have an account? Log In",
                color = MaterialTheme.colorScheme.tertiary
            )
        }
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun MainScreen(
    db: AppDatabase,
    onLogout: () -> Unit,
    onManageSubscription: () -> Unit
) {
    val scope = rememberCoroutineScope()
    val journalEntries by db.journalEntryDao().getAll().collectAsState(initial = emptyList())
    val corePoints by db.corePointDao().getAll().collectAsState(initial = emptyList())
    val issues by db.issueDao().getAll().collectAsState(initial = emptyList())

    var activeType by remember { mutableStateOf<String?>(null) }
    var activeId by remember { mutableStateOf<String?>(null) }
    var editorContent by remember { mutableStateOf("") }
    var editorTitle by remember { mutableStateOf("") }
    var showSidebar by remember { mutableStateOf(true) }

    var journalCollapsed by remember { mutableStateOf(false) }
    var coreCollapsed by remember { mutableStateOf(false) }
    var issuesCollapsed by remember { mutableStateOf(false) }

    var newCoreName by remember { mutableStateOf<String?>(null) }
    var newIssueName by remember { mutableStateOf<String?>(null) }

    var pendingDelete by remember { mutableStateOf<Triple<String, String, String>?>(null) }
    var showGame by remember { mutableStateOf(false) }

    // Lock on background/pause
    var isLocked by remember { mutableStateOf(false) }
    val lifecycleOwner = LocalLifecycleOwner.current
    DisposableEffect(lifecycleOwner) {
        val observer = LifecycleEventObserver { _, event ->
            if (event == Lifecycle.Event.ON_PAUSE) {
                isLocked = true
            }
        }
        lifecycleOwner.lifecycle.addObserver(observer)
        onDispose { lifecycleOwner.lifecycle.removeObserver(observer) }
    }

    LaunchedEffect(pendingDelete) {
        if (pendingDelete != null) {
            delay(5000)
            val (type, id, _) = pendingDelete!!
            when (type) {
                "journal" -> db.journalEntryDao().deleteById(id)
                "core" -> db.corePointDao().deleteById(id)
                "issue" -> db.issueDao().deleteById(id)
            }
            pendingDelete = null
        }
    }

    fun openEntry(type: String, id: String, content: String, title: String = "") {
        activeType = type
        activeId = id
        editorContent = content
        editorTitle = title
    }

    fun saveContent() {
        val id = activeId ?: return
        val now = System.currentTimeMillis()
        scope.launch {
            when (activeType) {
                "journal" -> {
                    val entry = db.journalEntryDao().getById(id) ?: return@launch
                    db.journalEntryDao().insert(entry.copy(content = editorContent, updatedAt = now))
                }
                "core" -> {
                    val point = db.corePointDao().getById(id) ?: return@launch
                    db.corePointDao().insert(point.copy(content = editorContent, name = editorTitle, updatedAt = now))
                }
                "issue" -> {
                    val issue = db.issueDao().getById(id) ?: return@launch
                    db.issueDao().insert(issue.copy(content = editorContent, name = editorTitle, updatedAt = now))
                }
            }
        }
    }

    LaunchedEffect(editorContent, editorTitle) {
        delay(1000)
        saveContent()
    }

    Box(modifier = Modifier.fillMaxSize()) {
        Row(modifier = Modifier.fillMaxSize()) {
            if (showSidebar) {
                Column(
                    modifier = Modifier
                        .width(280.dp)
                        .fillMaxHeight()
                        .background(MaterialTheme.colorScheme.background)
                        .padding(24.dp)
                ) {
                    Row(
                        modifier = Modifier.fillMaxWidth(),
                        horizontalArrangement = Arrangement.SpaceBetween,
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        Text("Day Before", color = MaterialTheme.colorScheme.secondary, fontSize = 13.sp)
                        TextButton(onClick = {
                            scope.launch {
                                val entry = JournalEntry()
                                db.journalEntryDao().insert(entry)
                                openEntry("journal", entry.id, "", entry.displayDate)
                            }
                        }) {
                            Text("New Entry", fontWeight = FontWeight.Bold)
                        }
                    }

                    Spacer(Modifier.height(16.dp))

                    LazyColumn(modifier = Modifier.weight(1f)) {
                        item {
                            SectionHeader("JOURNAL HISTORY", journalCollapsed) { journalCollapsed = !journalCollapsed }
                        }
                        if (!journalCollapsed) {
                            items(journalEntries) { entry ->
                                EntryItem(
                                    title = entry.displayDate,
                                    subtitle = entry.snippet,
                                    isActive = activeType == "journal" && activeId == entry.id,
                                    onClick = { openEntry("journal", entry.id, entry.content, entry.displayDate) }
                                )
                            }
                        }

                        item {
                            SectionHeader("CORE POINTS", coreCollapsed, showAdd = true, onAdd = { newCoreName = "" }) { coreCollapsed = !coreCollapsed }
                        }
                        if (!coreCollapsed) {
                            if (newCoreName != null) {
                                item {
                                    OutlinedTextField(
                                        value = newCoreName!!,
                                        onValueChange = { newCoreName = it },
                                        placeholder = { Text("Name...") },
                                        singleLine = true,
                                        modifier = Modifier.fillMaxWidth().padding(vertical = 4.dp),
                                        colors = OutlinedTextFieldDefaults.colors(
                                            focusedBorderColor = MaterialTheme.colorScheme.primary,
                                            unfocusedBorderColor = MaterialTheme.colorScheme.outline
                                        )
                                    )
                                }
                                item {
                                    Row(horizontalArrangement = Arrangement.End, modifier = Modifier.fillMaxWidth()) {
                                        TextButton(onClick = {
                                            val name = newCoreName?.trim() ?: ""
                                            if (name.isNotEmpty()) {
                                                scope.launch {
                                                    val pt = CorePoint(name = name)
                                                    db.corePointDao().insert(pt)
                                                    openEntry("core", pt.id, "", pt.name)
                                                }
                                            }
                                            newCoreName = null
                                        }) { Text("Add") }
                                        TextButton(onClick = { newCoreName = null }) { Text("Cancel") }
                                    }
                                }
                            }
                            items(corePoints) { point ->
                                EntryItem(
                                    title = point.name,
                                    subtitle = point.snippet,
                                    isActive = activeType == "core" && activeId == point.id,
                                    onClick = { openEntry("core", point.id, point.content, point.name) }
                                )
                            }
                        }

                        item {
                            SectionHeader("ISSUES", issuesCollapsed, showAdd = true, onAdd = { newIssueName = "" }) { issuesCollapsed = !issuesCollapsed }
                        }
                        if (!issuesCollapsed) {
                            if (newIssueName != null) {
                                item {
                                    OutlinedTextField(
                                        value = newIssueName!!,
                                        onValueChange = { newIssueName = it },
                                        placeholder = { Text("Issue name...") },
                                        singleLine = true,
                                        modifier = Modifier.fillMaxWidth().padding(vertical = 4.dp),
                                        colors = OutlinedTextFieldDefaults.colors(
                                            focusedBorderColor = MaterialTheme.colorScheme.primary,
                                            unfocusedBorderColor = MaterialTheme.colorScheme.outline
                                        )
                                    )
                                }
                                item {
                                    Row(horizontalArrangement = Arrangement.End, modifier = Modifier.fillMaxWidth()) {
                                        TextButton(onClick = {
                                            val name = newIssueName?.trim() ?: ""
                                            if (name.isNotEmpty()) {
                                                scope.launch {
                                                    val issue = Issue(name = name)
                                                    db.issueDao().insert(issue)
                                                    openEntry("issue", issue.id, "", issue.name)
                                                }
                                            }
                                            newIssueName = null
                                        }) { Text("Add") }
                                        TextButton(onClick = { newIssueName = null }) { Text("Cancel") }
                                    }
                                }
                            }
                            items(issues) { issue ->
                                EntryItem(
                                    title = issue.name,
                                    subtitle = issue.snippet,
                                    isActive = activeType == "issue" && activeId == issue.id,
                                    onClick = { openEntry("issue", issue.id, issue.content ?: "", issue.name) }
                                )
                            }
                        }
                    }

                    TextButton(onClick = { showGame = true }) {
                        Text("take a minute", color = MaterialTheme.colorScheme.secondary, fontSize = 13.sp)
                    }
                    HorizontalDivider(color = MaterialTheme.colorScheme.outline)
                    Spacer(Modifier.height(8.dp))
                    TextButton(onClick = onManageSubscription) { Text("Manage Subscription", color = MaterialTheme.colorScheme.secondary, fontSize = 13.sp) }
                    TextButton(onClick = onLogout) { Text("Log Out", color = MaterialTheme.colorScheme.secondary, fontSize = 13.sp) }
                }

                VerticalDivider(color = MaterialTheme.colorScheme.outline)
            }

            Column(
                modifier = Modifier
                    .weight(1f)
                    .fillMaxHeight()
            ) {
                // Sidebar toggle
                Row(
                    modifier = Modifier.fillMaxWidth().padding(horizontal = 8.dp, vertical = 4.dp),
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    IconButton(onClick = { showSidebar = !showSidebar }) {
                        Text(if (showSidebar) "◀" else "▶", color = MaterialTheme.colorScheme.secondary, fontSize = 14.sp)
                    }
                }

                Column(modifier = Modifier.weight(1f).fillMaxWidth().padding(horizontal = 24.dp).padding(bottom = 24.dp)) {
                    if (activeId != null) {
                        Row(
                            modifier = Modifier.fillMaxWidth(),
                            horizontalArrangement = Arrangement.SpaceBetween,
                            verticalAlignment = Alignment.CenterVertically
                        ) {
                            if (activeType == "journal") {
                                Text(editorTitle.replace(" ", "_") + ".md", fontSize = 15.sp)
                            } else {
                                OutlinedTextField(
                                    value = editorTitle,
                                    onValueChange = { editorTitle = it },
                                    singleLine = true,
                                    modifier = Modifier.weight(1f),
                                    colors = OutlinedTextFieldDefaults.colors(
                                        focusedBorderColor = Color.Transparent,
                                        unfocusedBorderColor = Color.Transparent
                                    )
                                )
                            }
                            Row(verticalAlignment = Alignment.CenterVertically) {
                                Text("Autosaved", color = MaterialTheme.colorScheme.secondary, fontSize = 13.sp)
                                Spacer(Modifier.width(16.dp))
                                TextButton(onClick = {
                                    if (activeId != null && activeType != null) {
                                        pendingDelete = Triple(activeType!!, activeId!!, editorTitle)
                                        activeType = null
                                        activeId = null
                                    }
                                }) { Text("Delete") }
                            }
                        }
                        Spacer(Modifier.height(16.dp))
                        OutlinedTextField(
                            value = editorContent,
                            onValueChange = { editorContent = it },
                            modifier = Modifier.fillMaxSize(),
                            colors = OutlinedTextFieldDefaults.colors(
                                focusedBorderColor = Color.Transparent,
                                unfocusedBorderColor = Color.Transparent
                            )
                        )
                    } else {
                        Box(modifier = Modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
                            TextButton(onClick = {
                                scope.launch {
                                    val entry = JournalEntry()
                                    db.journalEntryDao().insert(entry)
                                    openEntry("journal", entry.id, "", entry.displayDate)
                                }
                            }) {
                                Text("+ Create New Entry", fontSize = 19.sp)
                            }
                        }
                    }
                }
            }
        }

        if (pendingDelete != null) {
            Snackbar(
                modifier = Modifier.padding(16.dp).align(Alignment.BottomCenter),
                action = {
                    TextButton(onClick = { pendingDelete = null }) { Text("Undo") }
                }
            ) {
                Text("Deleting \"${pendingDelete!!.third}\"...")
            }
        }

        // Lock overlay
        if (isLocked) {
            var lockPassword by remember { mutableStateOf("") }
            var lockError by remember { mutableStateOf("") }
            Box(
                modifier = Modifier.fillMaxSize().background(Color(0xFF1a1817)),
                contentAlignment = Alignment.Center
            ) {
                Column(
                    modifier = Modifier.width(280.dp),
                    horizontalAlignment = Alignment.CenterHorizontally
                ) {
                    Text("Day Before", fontSize = 24.sp, fontWeight = FontWeight.Medium)
                    Spacer(Modifier.height(8.dp))
                    Text("Enter your password to continue.", fontSize = 13.sp, color = MaterialTheme.colorScheme.secondary)
                    Spacer(Modifier.height(24.dp))
                    OutlinedTextField(
                        value = lockPassword,
                        onValueChange = { lockPassword = it },
                        placeholder = { Text("Passphrase") },
                        singleLine = true,
                        visualTransformation = PasswordVisualTransformation(),
                        modifier = Modifier.fillMaxWidth()
                    )
                    if (lockError.isNotEmpty()) {
                        Spacer(Modifier.height(4.dp))
                        Text(lockError, color = MaterialTheme.colorScheme.error, fontSize = 12.sp)
                    }
                    Spacer(Modifier.height(16.dp))
                    Button(
                        onClick = {
                            val salt = Prefs.salt ?: ""
                            val wrapped = Prefs.wrappedKeyPwd ?: ""
                            try {
                                val saltBytes = android.util.Base64.decode(salt, android.util.Base64.NO_WRAP)
                                val pwdKey = CryptoService.deriveKey(lockPassword, saltBytes)
                                CryptoService.unwrapDataKey(wrapped, pwdKey)
                                isLocked = false
                                lockPassword = ""
                                lockError = ""
                            } catch (e: Exception) {
                                lockError = "That password did not match."
                            }
                        },
                        modifier = Modifier.fillMaxWidth()
                    ) { Text("Unlock") }
                    TextButton(onClick = onLogout) { Text("← Go Home", color = MaterialTheme.colorScheme.secondary) }
                }
            }
        }

        // Game overlay
        if (showGame) {
            GameOverlay(onClose = { showGame = false })
        }
    }
}

@Composable
fun SectionHeader(
    title: String,
    collapsed: Boolean,
    showAdd: Boolean = false,
    onAdd: () -> Unit = {},
    onToggle: () -> Unit
) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .padding(vertical = 8.dp),
        horizontalArrangement = Arrangement.SpaceBetween,
        verticalAlignment = Alignment.CenterVertically
    ) {
        Text(title, fontWeight = FontWeight.Bold, fontSize = 11.sp)
        Row {
            if (showAdd) {
                TextButton(onClick = onAdd) { Text("+", fontSize = 16.sp) }
            }
            TextButton(onClick = onToggle) {
                Text(if (collapsed) "show" else "hide", color = MaterialTheme.colorScheme.secondary, fontSize = 13.sp)
            }
        }
    }
}

@Composable
fun EntryItem(
    title: String,
    subtitle: String,
    isActive: Boolean,
    onClick: () -> Unit
) {
    Column(
        modifier = Modifier
            .fillMaxWidth()
            .clickable(onClick = onClick)
            .background(if (isActive) MaterialTheme.colorScheme.surfaceVariant else Color.Transparent)
            .padding(8.dp)
    ) {
        Text(
            title,
            fontWeight = if (isActive) FontWeight.Bold else FontWeight.Normal,
            fontSize = 13.sp,
            color = if (isActive) MaterialTheme.colorScheme.primary else MaterialTheme.colorScheme.onSurface
        )
        Text(subtitle, fontSize = 12.sp, color = MaterialTheme.colorScheme.secondary)
    }
}

@Composable
fun GameOverlay(onClose: () -> Unit) {
    var carY by remember { mutableFloatStateOf(0f) }
    var carVelocity by remember { mutableFloatStateOf(0f) }
    var carGrounded by remember { mutableStateOf(true) }
    var obstacles by remember { mutableStateOf(listOf<Pair<Float, Float>>()) }
    var score by remember { mutableIntStateOf(0) }
    var gameOver by remember { mutableStateOf(false) }
    var frameCount by remember { mutableIntStateOf(0) }
    val random = remember { java.util.Random() }

    LaunchedEffect(Unit) {
        while (true) {
            delay(16L)
            if (gameOver) continue
            var vel = carVelocity + 0.7f
            var y = carY + vel
            val grounded: Boolean
            if (y >= 0f) { y = 0f; vel = 0f; grounded = true } else { grounded = false }
            carY = y; carVelocity = vel; carGrounded = grounded
            frameCount++
            val speed = 5f + score / 200f
            val newObs = obstacles.map { (x, h) -> Pair(x - speed, h) }.filter { it.first > -60f }
            val interval = maxOf(60, 120 - score / 10)
            val spawnedObs = if (frameCount % interval == 0) newObs + Pair(1000f, 20f + random.nextInt(30).toFloat()) else newObs
            var over = false
            for ((ox, oh) in spawnedObs) {
                if (110f > ox && 60f < ox + 25f && carY + 25f > -oh) { over = true; break }
            }
            obstacles = spawnedObs
            if (over) gameOver = true
            if (!over) score++
        }
    }

    Box(
        modifier = Modifier
            .fillMaxSize()
            .background(Color(0xFF12100E))
            .clickable {
                if (gameOver) {
                    carY = 0f; carVelocity = 0f; carGrounded = true
                    obstacles = listOf(); score = 0; gameOver = false; frameCount = 0
                } else if (carGrounded) {
                    carVelocity = -18f; carGrounded = false
                }
            }
    ) {
        Canvas(modifier = Modifier.fillMaxSize()) {
            val groundY = size.height - 120f
            drawLine(Color(0xFF333333), Offset(0f, groundY), Offset(size.width, groundY), strokeWidth = 2f)
            drawRect(
                Color(0xFFA0A0A0),
                topLeft = Offset(60f, groundY - 50f + carY),
                size = Size(50f, 25f)
            )
            for ((ox, oh) in obstacles) {
                drawRect(Color(0xFF555555), topLeft = Offset(ox, groundY - oh), size = Size(25f, oh))
            }
        }
        Text(
            "Distance: $score",
            color = Color(0xFFA0A0A0),
            fontSize = 14.sp,
            modifier = Modifier.padding(20.dp)
        )
        if (gameOver) {
            Text(
                "Finished. Tap to restart.",
                color = Color(0xFFA0A0A0),
                fontSize = 16.sp,
                modifier = Modifier.align(Alignment.Center)
            )
        }
        TextButton(
            onClick = onClose,
            modifier = Modifier.align(Alignment.TopEnd).padding(16.dp)
        ) {
            Text("close", color = MaterialTheme.colorScheme.secondary)
        }
    }
}
