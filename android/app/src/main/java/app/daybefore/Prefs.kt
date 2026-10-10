package app.daybefore

import android.content.Context
import android.content.SharedPreferences
import androidx.core.content.edit

object Prefs {
    private const val PREF_NAME = "daybefore_prefs"
    private lateinit var prefs: SharedPreferences

    fun init(context: Context) {
        prefs = context.getSharedPreferences(PREF_NAME, Context.MODE_PRIVATE)
    }

    var token: String?
        get() = prefs.getString("token", null)
        set(value) = prefs.edit { putString("token", value) }

    var email: String?
        get() = prefs.getString("email", null)
        set(value) = prefs.edit { putString("email", value) }

    var salt: String?
        get() = prefs.getString("salt", null)
        set(value) = prefs.edit { putString("salt", value) }

    var wrappedKeyPwd: String?
        get() = prefs.getString("wrappedKeyPwd", null)
        set(value) = prefs.edit { putString("wrappedKeyPwd", value) }

    var lastSync: Long
        get() = prefs.getLong("lastSync", 0)
        set(value) = prefs.edit { putLong("lastSync", value) }

    fun clear() {
        prefs.edit {
            remove("token")
            remove("email")
            remove("salt")
            remove("wrappedKeyPwd")
            remove("lastSync")
        }
    }
}
