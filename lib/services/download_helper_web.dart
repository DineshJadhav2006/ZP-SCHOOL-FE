import 'dart:html' as html;
import 'package:dio/dio.dart';

Future<String?> downloadBookPlatform({
  required String bookUrl,
  required String bookName,
  Function(int, int)? onProgress,
}) async {
  try {
    final dio = Dio();
    final response = await dio.get(
      bookUrl,
      options: Options(responseType: ResponseType.bytes),
      onReceiveProgress: onProgress,
    );

    final bytes = response.data as List<int>;
    final blob = html.Blob([bytes]);
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..setAttribute('download', '$bookName.pdf')
      ..click();
    html.Url.revokeObjectUrl(url);
    return bookName;
  } catch (e) {
    print('Error downloading book: $e');
    return null;
  }
}
