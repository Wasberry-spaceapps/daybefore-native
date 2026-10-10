package app.daybefore

import com.google.gson.Gson
import com.google.gson.annotations.SerializedName
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import okhttp3.MediaType.Companion.toMediaType
import okhttp3.OkHttpClient
import okhttp3.Request
import okhttp3.RequestBody.Companion.toRequestBody
import java.util.concurrent.TimeUnit

data class LoginResponse(
    val token: String = "",
    val salt: String? = null,
    val wrappedKeyPwd: String? = null,
    val error: String? = null
)

data class AccountInfo(
    val subscriptionStatus: String? = null
)

data class PortalResponse(
    val url: String? = null
)

data class SyncItem(
    @SerializedName("record_id") val recordId: String = "",
    @SerializedName("encrypted_data") val encryptedData: String = "",
    @SerializedName("updated_at") val updatedAt: Long = 0
)

data class SyncResponse(
    val items: List<SyncItem> = emptyList()
)

data class ResetResponse(
    val wrappedKeyRecovery: String? = null,
    val salt: String? = null,
    val error: String? = null
)

object ApiService {
    private const val API_URL = "https://daybefore-backend.officialmutairu.workers.dev/api"
    private val client = OkHttpClient.Builder()
        .connectTimeout(30, TimeUnit.SECONDS)
        .readTimeout(30, TimeUnit.SECONDS)
        .build()
    private val gson = Gson()
    private val JSON = "application/json".toMediaType()

    suspend fun login(email: String, passwordHash: String): LoginResponse = withContext(Dispatchers.IO) {
        val body = gson.toJson(mapOf("email" to email, "passwordHash" to passwordHash))
        val request = Request.Builder()
            .url("$API_URL/auth/login")
            .post(body.toRequestBody(JSON))
            .build()
        val response = client.newCall(request).execute()
        gson.fromJson(response.body?.string(), LoginResponse::class.java) ?: LoginResponse(error = "Failed")
    }

    suspend fun register(
        email: String, passwordHash: String, salt: String,
        wrappedKeyPwd: String, wrappedKeyRecovery: String
    ): LoginResponse = withContext(Dispatchers.IO) {
        val body = gson.toJson(mapOf(
            "email" to email, "passwordHash" to passwordHash, "salt" to salt,
            "wrappedKeyPwd" to wrappedKeyPwd, "wrappedKeyRecovery" to wrappedKeyRecovery
        ))
        val request = Request.Builder()
            .url("$API_URL/auth/register")
            .post(body.toRequestBody(JSON))
            .build()
        val response = client.newCall(request).execute()
        gson.fromJson(response.body?.string(), LoginResponse::class.java) ?: LoginResponse(error = "Failed")
    }

    suspend fun getAccountInfo(token: String): AccountInfo? = withContext(Dispatchers.IO) {
        val request = Request.Builder()
            .url("$API_URL/account/me")
            .addHeader("Authorization", "Bearer $token")
            .build()
        val response = client.newCall(request).execute()
        if (!response.isSuccessful) null
        else gson.fromJson(response.body?.string(), AccountInfo::class.java)
    }

    suspend fun getPortalUrl(token: String): String? = withContext(Dispatchers.IO) {
        val request = Request.Builder()
            .url("$API_URL/portal")
            .addHeader("Authorization", "Bearer $token")
            .post("".toRequestBody(JSON))
            .build()
        val response = client.newCall(request).execute()
        if (!response.isSuccessful) null
        else gson.fromJson(response.body?.string(), PortalResponse::class.java)?.url
    }

    suspend fun fetchSyncItems(token: String, collection: String, since: Long): List<SyncItem> = withContext(Dispatchers.IO) {
        val request = Request.Builder()
            .url("$API_URL/sync/$collection?since=$since")
            .addHeader("Authorization", "Bearer $token")
            .build()
        val response = client.newCall(request).execute()
        if (!response.isSuccessful) emptyList()
        else gson.fromJson(response.body?.string(), SyncResponse::class.java)?.items ?: emptyList()
    }

    suspend fun pushSyncItems(token: String, collection: String, items: List<SyncItem>): Boolean = withContext(Dispatchers.IO) {
        val body = gson.toJson(mapOf("items" to items))
        val request = Request.Builder()
            .url("$API_URL/sync/$collection")
            .addHeader("Authorization", "Bearer $token")
            .post(body.toRequestBody(JSON))
            .build()
        client.newCall(request).execute().isSuccessful
    }

    suspend fun migrateV2(token: String, wrappedKeyPwd: String, wrappedKeyRecovery: String) = withContext(Dispatchers.IO) {
        val body = gson.toJson(mapOf("wrappedKeyPwd" to wrappedKeyPwd, "wrappedKeyRecovery" to wrappedKeyRecovery))
        val request = Request.Builder()
            .url("$API_URL/auth/migrate-v2")
            .addHeader("Authorization", "Bearer $token")
            .post(body.toRequestBody(JSON))
            .build()
        client.newCall(request).execute()
    }

    suspend fun resetPassword(email: String, recoveryKey: String): ResetResponse = withContext(Dispatchers.IO) {
        val body = gson.toJson(mapOf("email" to email.trim().lowercase(), "recoveryKey" to recoveryKey.trim()))
        val request = Request.Builder()
            .url("$API_URL/auth/reset-password")
            .post(body.toRequestBody(JSON))
            .build()
        val response = client.newCall(request).execute()
        gson.fromJson(response.body?.string(), ResetResponse::class.java) ?: ResetResponse(error = "Failed")
    }
}
