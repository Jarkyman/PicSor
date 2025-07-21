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
    private val ALBUMS_CHANNEL = "picsor.albums"

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
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, ALBUMS_CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "addToAlbum") {
                val args = call.arguments as? Map<*, *>
                val id = args?.get("id") as? String
                val albumName = args?.get("album") as? String
                if (id == null || albumName == null) {
                    result.success(false)
                    return@setMethodCallHandler
                }
                try {
                    // Find the asset in MediaStore
                    val projection = arrayOf(
                        MediaStore.Images.Media._ID,
                        MediaStore.Images.Media.DATA,
                        MediaStore.Images.Media.DISPLAY_NAME
                    )
                    val selection = MediaStore.Images.Media._ID + "=?"
                    val cursor = contentResolver.query(
                        MediaStore.Images.Media.EXTERNAL_CONTENT_URI,
                        projection,
                        selection,
                        arrayOf(id),
                        null
                    )
                    if (cursor != null && cursor.moveToFirst()) {
                        val dataIdx = cursor.getColumnIndex(MediaStore.Images.Media.DATA)
                        val nameIdx = cursor.getColumnIndex(MediaStore.Images.Media.DISPLAY_NAME)
                        val filePath = if (dataIdx != -1) cursor.getString(dataIdx) else null
                        val fileName = if (nameIdx != -1) cursor.getString(nameIdx) else "image.jpg"
                        cursor.close()
                        if (filePath != null) {
                            val albumDir = android.os.Environment.getExternalStoragePublicDirectory(android.os.Environment.DIRECTORY_DCIM).absolutePath + "/PicSor/" + albumName
                            val albumFile = java.io.File(albumDir)
                            if (!albumFile.exists()) albumFile.mkdirs()
                            val destFile = java.io.File(albumFile, fileName)
                            val srcFile = java.io.File(filePath)
                            srcFile.copyTo(destFile, overwrite = true)
                            // Update MediaStore
                            val values = ContentValues().apply {
                                put(MediaStore.Images.Media.DATA, destFile.absolutePath)
                                put(MediaStore.Images.Media.RELATIVE_PATH, "DCIM/PicSor/$albumName")
                            }
                            contentResolver.insert(MediaStore.Images.Media.EXTERNAL_CONTENT_URI, values)
                            result.success(true)
                            return@setMethodCallHandler
                        }
                    }
                    result.success(false)
                } catch (e: Exception) {
                    android.util.Log.e("PicSor", "addToAlbum exception: id=$id, album=$albumName", e)
                    result.success(false)
                }
            } else if (call.method == "getAlbums") {
                try {
                    val albumRoot = android.os.Environment.getExternalStoragePublicDirectory(android.os.Environment.DIRECTORY_DCIM).absolutePath + "/PicSor/"
                    val albumFile = java.io.File(albumRoot)
                    val albums = if (albumFile.exists() && albumFile.isDirectory) {
                        albumFile.listFiles()?.filter { it.isDirectory }?.map { it.name } ?: listOf<String>()
                    } else {
                        listOf<String>()
                    }
                    result.success(albums)
                } catch (e: Exception) {
                    android.util.Log.e("PicSor", "getAlbums exception", e)
                    result.success(listOf<String>())
                }
            } else if (call.method == "createAlbum") {
                val args = call.arguments as? Map<*, *>
                val albumName = args?.get("album") as? String
                if (albumName == null) {
                    result.success(false)
                    return@setMethodCallHandler
                }
                try {
                    val albumRoot = android.os.Environment.getExternalStoragePublicDirectory(android.os.Environment.DIRECTORY_DCIM).absolutePath + "/PicSor/"
                    val albumFile = java.io.File(albumRoot, albumName)
                    if (!albumFile.exists()) {
                        val created = albumFile.mkdirs()
                        result.success(created)
                    } else {
                        result.success(true) // Already exists
                    }
                } catch (e: Exception) {
                    android.util.Log.e("PicSor", "createAlbum exception", e)
                    result.success(false)
                }
            } else {
                result.notImplemented()
            }
        }
    }
}
