Future<String?> downloadBookPlatform({
  required String bookUrl,
  required String bookName,
  Function(int, int)? onProgress,
}) async {
  throw UnsupportedError('Platform not supported');
}
