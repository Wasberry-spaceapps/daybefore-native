package app.daybefore

import android.content.Context
import androidx.room.*
import kotlinx.coroutines.flow.Flow

@Dao
interface JournalEntryDao {
    @Query("SELECT * FROM journal_entries ORDER BY createdAt DESC")
    fun getAll(): Flow<List<JournalEntry>>

    @Query("SELECT * FROM journal_entries WHERE id = :id")
    suspend fun getById(id: String): JournalEntry?

    @Query("SELECT * FROM journal_entries WHERE updatedAt > :since")
    suspend fun getUpdatedAfter(since: Long): List<JournalEntry>

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insert(entry: JournalEntry)

    @Delete
    suspend fun delete(entry: JournalEntry)

    @Query("DELETE FROM journal_entries WHERE id = :id")
    suspend fun deleteById(id: String)
}

@Dao
interface CorePointDao {
    @Query("SELECT * FROM core_points ORDER BY createdAt ASC")
    fun getAll(): Flow<List<CorePoint>>

    @Query("SELECT * FROM core_points WHERE id = :id")
    suspend fun getById(id: String): CorePoint?

    @Query("SELECT * FROM core_points WHERE updatedAt > :since")
    suspend fun getUpdatedAfter(since: Long): List<CorePoint>

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insert(point: CorePoint)

    @Query("DELETE FROM core_points WHERE id = :id")
    suspend fun deleteById(id: String)
}

@Dao
interface IssueDao {
    @Query("SELECT * FROM issues WHERE isArchived = 0 ORDER BY createdAt ASC")
    fun getAll(): Flow<List<Issue>>

    @Query("SELECT * FROM issues WHERE id = :id")
    suspend fun getById(id: String): Issue?

    @Query("SELECT * FROM issues WHERE updatedAt > :since")
    suspend fun getUpdatedAfter(since: Long): List<Issue>

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insert(issue: Issue)

    @Query("DELETE FROM issues WHERE id = :id")
    suspend fun deleteById(id: String)
}

@Dao
interface IssueEntryDao {
    @Query("SELECT * FROM issue_entries WHERE issueId = :issueId ORDER BY createdAt ASC")
    fun getByIssueId(issueId: String): Flow<List<IssueEntry>>

    @Query("SELECT * FROM issue_entries WHERE updatedAt > :since")
    suspend fun getUpdatedAfter(since: Long): List<IssueEntry>

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insert(entry: IssueEntry)

    @Query("DELETE FROM issue_entries WHERE id = :id")
    suspend fun deleteById(id: String)
}

@Database(
    entities = [JournalEntry::class, CorePoint::class, Issue::class, IssueEntry::class],
    version = 1,
    exportSchema = false
)
abstract class AppDatabase : RoomDatabase() {
    abstract fun journalEntryDao(): JournalEntryDao
    abstract fun corePointDao(): CorePointDao
    abstract fun issueDao(): IssueDao
    abstract fun issueEntryDao(): IssueEntryDao

    companion object {
        @Volatile
        private var INSTANCE: AppDatabase? = null

        fun getInstance(context: Context): AppDatabase {
            return INSTANCE ?: synchronized(this) {
                val instance = Room.databaseBuilder(
                    context.applicationContext,
                    AppDatabase::class.java,
                    "daybefore.db"
                ).build()
                INSTANCE = instance
                instance
            }
        }
    }
}
