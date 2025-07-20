package com.hartvig.solutions.picsor.picsor

import android.content.ContentUris
import android.content.ContentValues
import android.os.Build
import android.os.Bundle
import android.provider.MediaStore
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "picsor.favorite"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "setFavorite") {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
                    val args = call.arguments as? Map<*, *>
                    val id = args?.get("id") as? String
                    val favorite = args?.get("favorite") as? Boolean
                    if (id != null && favorite != null) {
                        try {
                            val uri = ContentUris.withAppendedId(MediaStore.Images.Media.EXTERNAL_CONTENT_URI, id.toLong())
                            val values = ContentValues().apply {
                                put(MediaStore.Images.Media.IS_FAVORITE, if (favorite) 1 else 0)
                            }
                            val rows = contentResolver.update(uri, values, null, null)
                            android.util.Log.d("PicSor", "setFavorite: id=$id, uri=$uri, favorite=$favorite, rows updated=$rows")
                            result.success(rows > 0)
                        } catch (e: Exception) {
                            android.util.Log.e("PicSor", "setFavorite exception: id=$id, favorite=$favorite", e)
                            result.success(false)
                        }
                    } else {
                        android.util.Log.e("PicSor", "setFavorite: missing id or favorite. id=$id, favorite=$favorite")
                        result.success(false)
                    }
                } else {
                    android.util.Log.e("PicSor", "setFavorite: SDK < 30 not supported")
                    result.success(false)
                }
            } else if (call.method == "isFavorite") {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
                    val args = call.arguments as? Map<*, *>
                    val id = args?.get("id") as? String
                    if (id != null) {
                        try {
                            val uri = ContentUris.withAppendedId(MediaStore.Images.Media.EXTERNAL_CONTENT_URI, id.toLong())
                            val projection = arrayOf(MediaStore.Images.Media.IS_FAVORITE)
                            val cursor = contentResolver.query(uri, projection, null, null, null)
                            var isFavorite = false
                            if (cursor != null && cursor.moveToFirst()) {
                                val idx = cursor.getColumnIndex(MediaStore.Images.Media.IS_FAVORITE)
                                if (idx != -1) {
                                    isFavorite = cursor.getInt(idx) == 1
                                }
                                cursor.close()
                            }
                            android.util.Log.d("PicSor", "isFavorite: id=$id, uri=$uri, isFavorite=$isFavorite")
                            result.success(isFavorite)
                        } catch (e: Exception) {
                            android.util.Log.e("PicSor", "isFavorite exception: id=$id", e)
                            result.success(false)
                        }
                    } else {
                        android.util.Log.e("PicSor", "isFavorite: missing id. id=$id")
                        result.success(false)
                    }
                } else {
                    android.util.Log.e("PicSor", "isFavorite: SDK < 30 not supported")
                    result.success(false)
                }
            } else {
                result.notImplemented()
            }
        }
    }
}
