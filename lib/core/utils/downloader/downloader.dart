import 'dart:typed_data';

import 'downloader_stub.dart'
    if (dart.library.html) 'downloader_web.dart' as impl;

/// Interface pour le téléchargement de fichiers
abstract class FileDownloader {
  Future<void> downloadFile(String fileName, Uint8List bytes);
}

/// Factory pour obtenir l'instance appropriée
FileDownloader getFileDownloader() => impl.getFileDownloader();


