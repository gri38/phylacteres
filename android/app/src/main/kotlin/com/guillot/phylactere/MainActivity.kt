package com.guillot.phylactere

import android.content.ContentValues
import android.content.Intent
import android.media.MediaScannerConnection
import android.os.Build
import android.os.Environment
import android.provider.MediaStore
import androidx.core.content.FileProvider
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.FileOutputStream

class MainActivity : FlutterActivity() {
    private val preferredOutputFolderName = "Phylactères"
    private val outputFolderCandidates = listOf(
        "Phylactere",
        "Phylacteres",
        preferredOutputFolderName
    )

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "com.guillot.phylactere/media"
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "scanFile" -> {
                    val path = call.argument<String>("path")
                    if (path.isNullOrBlank()) {
                        result.error("missing_path", "Path argument is required.", null)
                        return@setMethodCallHandler
                    }

                    MediaScannerConnection.scanFile(
                        this,
                        arrayOf(path),
                        null,
                        null
                    )
                    result.success(null)
                }

                "saveImage" -> {
                    val bytes = call.argument<ByteArray>("bytes")
                    val sourcePath = call.argument<String>("sourcePath")
                    val extension = call.argument<String>("extension")
                    val mimeType = call.argument<String>("mimeType")

                    if (
                        bytes == null ||
                        sourcePath.isNullOrBlank() ||
                        extension.isNullOrBlank() ||
                        mimeType.isNullOrBlank()
                    ) {
                        result.error(
                            "missing_args",
                            "bytes, sourcePath, extension and mimeType are required.",
                            null
                        )
                        return@setMethodCallHandler
                    }

                    saveImage(bytes, sourcePath, extension, mimeType, result)
                }

                "shareImage" -> {
                    val bytes = call.argument<ByteArray>("bytes")
                    val fileName = call.argument<String>("fileName")
                    val mimeType = call.argument<String>("mimeType")

                    if (bytes == null || fileName.isNullOrBlank() || mimeType.isNullOrBlank()) {
                        result.error(
                            "missing_args",
                            "bytes, fileName and mimeType are required.",
                            null
                        )
                        return@setMethodCallHandler
                    }

                    shareImage(bytes, fileName, mimeType, result)
                }

                else -> result.notImplemented()
            }
        }
    }

    private fun saveImage(
        bytes: ByteArray,
        sourcePath: String,
        extension: String,
        mimeType: String,
        result: MethodChannel.Result
    ) {
        try {
            val sourceFile = File(sourcePath)
            val normalizedExtension = normalizeExtension(extension)
            val baseName = "${sourceFile.nameWithoutExtension}_phylactere"
            val outputFolderName = resolveOutputFolderName()
            val relativePath = "${Environment.DIRECTORY_PICTURES}/$outputFolderName/"

            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                val fileName = nextAvailableMediaStoreFileName(
                    relativePath,
                    baseName,
                    normalizedExtension
                )
                saveImageToMediaStore(
                    bytes,
                    fileName,
                    mimeType,
                    relativePath,
                    result
                )
                return
            }

            val picturesDir = Environment.getExternalStoragePublicDirectory(
                Environment.DIRECTORY_PICTURES
            )
            val outputDir = File(picturesDir, outputFolderName)
            if (!outputDir.exists() && !outputDir.mkdirs()) {
                result.error("save_failed", "Unable to create the output folder.", null)
                return
            }

            val outputFile = nextAvailableSiblingFile(outputDir, baseName, normalizedExtension)
            FileOutputStream(outputFile).use { output ->
                output.write(bytes)
                output.flush()
            }
            MediaScannerConnection.scanFile(
                this,
                arrayOf(outputFile.absolutePath),
                arrayOf(mimeType),
                null
            )
            result.success(outputFile.absolutePath)
        } catch (error: Exception) {
            result.error("save_failed", error.message, null)
        }
    }

    private fun saveImageToMediaStore(
        bytes: ByteArray,
        fileName: String,
        mimeType: String,
        relativePath: String,
        result: MethodChannel.Result
    ) {
        try {
                val resolver = applicationContext.contentResolver
                val values = ContentValues().apply {
                    put(MediaStore.Images.Media.DISPLAY_NAME, fileName)
                    put(MediaStore.Images.Media.MIME_TYPE, mimeType)
                    put(MediaStore.Images.Media.RELATIVE_PATH, relativePath)
                    put(MediaStore.Images.Media.IS_PENDING, 1)
                }

                val uri = resolver.insert(MediaStore.Images.Media.EXTERNAL_CONTENT_URI, values)
                if (uri == null) {
                    result.error("save_failed", "Unable to create a gallery entry.", null)
                    return
                }

                try {
                    resolver.openOutputStream(uri)?.use { output ->
                        output.write(bytes)
                        output.flush()
                    } ?: throw IllegalStateException("Unable to open the gallery output stream.")

                    val publishValues = ContentValues().apply {
                        put(MediaStore.Images.Media.IS_PENDING, 0)
                    }
                    resolver.update(uri, publishValues, null, null)
                    result.success("$relativePath$fileName")
                } catch (error: Exception) {
                    resolver.delete(uri, null, null)
                    result.error("save_failed", error.message, null)
                }
        } catch (error: Exception) {
            result.error("save_failed", error.message, null)
        }
    }

    private fun normalizeExtension(extension: String): String {
        return if (extension.startsWith(".")) extension else ".$extension"
    }

    private fun resolveOutputFolderName(): String {
        val picturesDir = Environment.getExternalStoragePublicDirectory(
            Environment.DIRECTORY_PICTURES
        )

        var bestExistingFolderName: String? = null
        var bestExistingFolderScore = -1
        for (folderName in outputFolderCandidates) {
            val directory = File(picturesDir, folderName)
            if (!directory.exists() || !directory.isDirectory) {
                continue
            }
            val score = safeEntryCount(directory)
            if (score > bestExistingFolderScore) {
                bestExistingFolderName = folderName
                bestExistingFolderScore = score
            }
        }
        if (bestExistingFolderName != null) {
            return bestExistingFolderName
        }

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            var bestMediaStoreFolderName: String? = null
            var bestMediaStoreFolderScore = -1
            for (folderName in outputFolderCandidates) {
                val relativePath = "${Environment.DIRECTORY_PICTURES}/$folderName/"
                val score = mediaStoreEntryCount(relativePath)
                if (score > bestMediaStoreFolderScore) {
                    bestMediaStoreFolderName = folderName
                    bestMediaStoreFolderScore = score
                }
            }
            if (bestMediaStoreFolderName != null && bestMediaStoreFolderScore > 0) {
                return bestMediaStoreFolderName
            }
        }

        return preferredOutputFolderName
    }

    private fun safeEntryCount(directory: File): Int {
        return try {
            directory.list()?.size ?: 0
        } catch (_: SecurityException) {
            0
        }
    }

    private fun mediaStoreEntryCount(relativePath: String): Int {
        val resolver = applicationContext.contentResolver
        resolver.query(
            MediaStore.Images.Media.EXTERNAL_CONTENT_URI,
            arrayOf(MediaStore.Images.Media._ID),
            "${MediaStore.Images.Media.RELATIVE_PATH} = ?",
            arrayOf(relativePath),
            null
        )?.use { cursor ->
            return cursor.count
        }
        return 0
    }

    private fun nextAvailableSiblingFile(
        parentDir: File,
        baseName: String,
        extension: String
    ): File {
        var index = 1
        while (true) {
            val fileName = "${baseName}_${index.toString().padStart(3, '0')}$extension"
            val candidate = File(parentDir, fileName)
            if (!candidate.exists()) {
                return candidate
            }
            index++
        }
    }

    private fun nextAvailableMediaStoreFileName(
        relativePath: String,
        baseName: String,
        extension: String
    ): String {
        val resolver = applicationContext.contentResolver
        val existingNames = mutableSetOf<String>()
        resolver.query(
            MediaStore.Images.Media.EXTERNAL_CONTENT_URI,
            arrayOf(MediaStore.Images.Media.DISPLAY_NAME),
            "${MediaStore.Images.Media.RELATIVE_PATH} = ?",
            arrayOf(relativePath),
            null
        )?.use { cursor ->
            val displayNameIndex = cursor.getColumnIndex(MediaStore.Images.Media.DISPLAY_NAME)
            while (cursor.moveToNext()) {
                existingNames += cursor.getString(displayNameIndex)
            }
        }

        var index = 1
        while (true) {
            val fileName = "${baseName}_${index.toString().padStart(3, '0')}$extension"
            if (!existingNames.contains(fileName)) {
                return fileName
            }
            index++
        }
    }

    private fun shareImage(
        bytes: ByteArray,
        fileName: String,
        mimeType: String,
        result: MethodChannel.Result
    ) {
        try {
            val shareDir = File(cacheDir, "shared_images")
            if (!shareDir.exists()) {
                shareDir.mkdirs()
            }

            val shareFile = File(shareDir, fileName)
            FileOutputStream(shareFile).use { output ->
                output.write(bytes)
                output.flush()
            }

            val uri = FileProvider.getUriForFile(
                this,
                "${applicationContext.packageName}.fileprovider",
                shareFile
            )
            val shareIntent = Intent(Intent.ACTION_SEND).apply {
                type = mimeType
                putExtra(Intent.EXTRA_STREAM, uri)
                addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
            }

            startActivity(Intent.createChooser(shareIntent, "Partager l'image"))
            result.success(null)
        } catch (error: Exception) {
            result.error("share_failed", error.message, null)
        }
    }
}
