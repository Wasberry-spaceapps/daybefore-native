package app.daybefore

import androidx.room.*
import java.text.SimpleDateFormat
import java.util.*

@Entity(tableName = "journal_entries")
data class JournalEntry(
    @PrimaryKey val id: String = UUID.randomUUID().toString(),
    val content: String = "",
    val createdAt: Long = System.currentTimeMillis(),
    val updatedAt: Long = System.currentTimeMillis()
) {
    val displayDate: String
        get() {
            val sdf = SimpleDateFormat("yyyy-MM-dd HHmm", Locale.getDefault())
            return sdf.format(Date(createdAt))
        }
    val snippet: String
        get() = content.take(30).ifEmpty { "..." }
}

@Entity(tableName = "core_points")
data class CorePoint(
    @PrimaryKey val id: String = UUID.randomUUID().toString(),
    val name: String = "",
    val content: String = "",
    val createdAt: Long = System.currentTimeMillis(),
    val updatedAt: Long = System.currentTimeMillis()
) {
    val snippet: String
        get() = content.take(30).ifEmpty { "..." }
}

@Entity(tableName = "issues")
data class Issue(
    @PrimaryKey val id: String = UUID.randomUUID().toString(),
    val name: String = "",
    val content: String? = null,
    val isArchived: Boolean = false,
    val createdAt: Long = System.currentTimeMillis(),
    val updatedAt: Long = System.currentTimeMillis()
) {
    val snippet: String
        get() = (content ?: "").take(30).ifEmpty { "..." }
}

@Entity(tableName = "issue_entries")
data class IssueEntry(
    @PrimaryKey val id: String = UUID.randomUUID().toString(),
    val issueId: String = "",
    val content: String = "",
    val createdAt: Long = System.currentTimeMillis(),
    val updatedAt: Long = System.currentTimeMillis()
)
