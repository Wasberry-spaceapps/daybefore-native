package app.daybefore.daybefore

import android.content.ContentUris
import android.content.ContentValues
import android.content.Context
import android.provider.MediaStore
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class BackupChannel(private val context: Context) : MethodChannel.MethodCallHandler {
    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "writeBackup" -> {
                val accountId = call.argument<String>("accountId")!!
                val data = call.argument<ByteArray>("data")!!
                val fileName = call.argument<String>("fileName")!!
                writeToMediaStore(data, fileName, result)
            }
            "listBackups" -> {
                val accountId = call.argument<String>("accountId")!!
                listFromMediaStore(accountId, result)
            }
            "readBackup" -> {
                val fileName = call.argument<String>("fileName")!!
                readFromMediaStore(fileName, result)
            }
            "deleteBackup" -> {
                val fileName = call.argument<String>("fileName")!!
                deleteFromMediaStore(fileName, result)
            }
            else -> result.notImplemented()
        }
    }

    private fun writeToMediaStore(data: ByteArray, fileName: String, result: MethodChannel.Result) {
        try {
            val values = ContentValues().apply {
                put(MediaStore.Downloads.DISPLAY_NAME, fileName)
                put(MediaStore.Downloads.MIME_TYPE, "application/octet-stream")
                put(MediaStore.Downloads.RELATIVE_PATH, "Documents/DayBefore")
            }
            val uri = context.contentResolver.insert(MediaStore.Downloads.EXTERNAL_CONTENT_URI, values)
            if (uri != null) {
                context.contentResolver.openOutputStream(uri)?.use { it.write(data) }
                result.success(true)
            } else {
                result.error("WRITE_FAILED", "Could not create file in MediaStore", null)
            }
        } catch (e: Exception) {
            result.error("WRITE_FAILED", e.message, null)
        }
    }

    private fun listFromMediaStore(accountId: String, result: MethodChannel.Result) {
        val backups = mutableListOf<Map<String, Any>>()
        val selection = "${MediaStore.Downloads.DISPLAY_NAME} LIKE ?"
        val args = arrayOf("DayBefore-backup-${accountId}-%")
        context.contentResolver.query(
            MediaStore.Downloads.EXTERNAL_CONTENT_URI,
            arrayOf(MediaStore.Downloads.DISPLAY_NAME, MediaStore.Downloads.SIZE, MediaStore.Downloads.DATE_MODIFIED),
            selection, args, "${MediaStore.Downloads.DATE_MODIFIED} DESC"
        )?.use { cursor ->
            while (cursor.moveToNext()) {
                backups.add(mapOf(
                    "name" to cursor.getString(0),
                    "size" to cursor.getLong(1),
                    "modified" to cursor.getLong(2) * 1000L
                ))
            }
        }
        result.success(backups)
    }

    private fun readFromMediaStore(fileName: String, result: MethodChannel.Result) {
        val selection = "${MediaStore.Downloads.DISPLAY_NAME} = ?"
        val args = arrayOf(fileName)
        context.contentResolver.query(
            MediaStore.Downloads.EXTERNAL_CONTENT_URI,
            arrayOf(MediaStore.Downloads._ID),
            selection, args, null
        )?.use { cursor ->
            if (cursor.moveToFirst()) {
                val id = cursor.getLong(0)
                val uri = ContentUris.withAppendedId(MediaStore.Downloads.EXTERNAL_CONTENT_URI, id)
                val data = context.contentResolver.openInputStream(uri)?.readBytes()
                result.success(data)
                return
            }
        }
        result.error("NOT_FOUND", "Backup not found: $fileName", null)
    }

    private fun deleteFromMediaStore(fileName: String, result: MethodChannel.Result) {
        val selection = "${MediaStore.Downloads.DISPLAY_NAME} = ?"
        val args = arrayOf(fileName)
        val deleted = context.contentResolver.delete(
            MediaStore.Downloads.EXTERNAL_CONTENT_URI, selection, args
        )
        result.success(deleted > 0)
    }
}
