import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

Future<String?> downloadBookPlatform({
  required String bookUrl,
  required String bookName,
  Function(int, int)? onProgress,
}) async {
  try {
    final dir = await getApplicationDocumentsDirectory();
    final fileName = '${bookName.replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}.pdf';
    final filePath = '${dir.path}/$fileName';

    final dio = Dio();
    await dio.download(bookUrl, filePath, onReceiveProgress: onProgress);
    return filePath;
  } catch (e) {
    print('Error downloading book: $e');
    return null;
  }
}
