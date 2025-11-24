import 'dart:typed_data';
import 'downloader.dart';

class StubFileDownloader implements FileDownloader {
  @override
  Future<void> downloadFile(String fileName, Uint8List bytes) async {
    throw UnsupportedError('Download not supported on this platform via this method');
  }
}

FileDownloader getFileDownloader() => StubFileDownloader();
