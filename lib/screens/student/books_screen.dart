import 'package:flutter/material.dart';
import '../../services/book_service.dart';
import '../../config/env_config.dart';
import 'package:url_launcher/url_launcher.dart';

class BooksScreen extends StatefulWidget {
  final String className;

  const BooksScreen({required this.className});

  @override
  State<BooksScreen> createState() => _BooksScreenState();
}

class _BooksScreenState extends State<BooksScreen> {
  List<dynamic> books = [];
  bool isLoading = true;
  String? errorMessage;
  Map<int, double> downloadProgress = {};

  @override
  void initState() {
    super.initState();
    loadBooks();
  }

  Future<void> loadBooks() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });
    try {
      final data = await BookService.getBooksByClass(widget.className);
      setState(() {
        books = data;
        isLoading = false;
      });
    } catch (e) {
      print('Error loading books: $e');
      setState(() {
        isLoading = false;
        errorMessage = e.toString().contains('SocketException') || e.toString().contains('Failed host lookup')
            ? 'No internet connection. Please check your network.'
            : 'Failed to load books. Please try again.';
      });
    }
  }

  Future<void> openBook(String url) async {
    if (url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Book URL not available'), backgroundColor: Colors.red),
      );
      return;
    }
    
    String fullUrl = url;
    if (url.startsWith('/')) {
      fullUrl = '${EnvConfig.apiBaseUrl}$url';
    }
    
    try {
      final uri = Uri.parse(fullUrl);
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to open book'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> downloadBook(int index, String bookUrl, String bookName) async {
    if (bookUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Book URL not available'), backgroundColor: Colors.red),
      );
      return;
    }
    
    String fullUrl = bookUrl;
    if (bookUrl.startsWith('/')) {
      fullUrl = '${EnvConfig.apiBaseUrl}$bookUrl';
    }

    setState(() => downloadProgress[index] = 0.0);

    final filePath = await BookService.downloadBook(
      bookUrl: fullUrl,
      bookName: bookName,
      onProgress: (received, total) {
        if (total != -1 && mounted) {
          setState(() => downloadProgress[index] = received / total);
        }
      },
    );

    if (mounted) {
      setState(() => downloadProgress.remove(index));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(filePath != null ? 'Downloaded: $bookName' : 'Download failed'),
          backgroundColor: filePath != null ? Colors.green : Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 64, color: Colors.red),
                      SizedBox(height: 16),
                      Text(errorMessage!, style: TextStyle(fontSize: 16, color: Colors.grey), textAlign: TextAlign.center),
                      SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: loadBooks,
                        icon: Icon(Icons.refresh),
                        label: Text('Retry'),
                      ),
                    ],
                  ),
                )
              : books.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.book_outlined, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text('No books available', style: TextStyle(fontSize: 16, color: Colors.grey)),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                  onRefresh: loadBooks,
                  child: ListView.builder(
                    padding: EdgeInsets.all(16),
                    itemCount: books.length,
                    itemBuilder: (context, index) {
                      final book = books[index];
                      return Card(
                        margin: EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Theme.of(context).primaryColor,
                            child: Icon(Icons.book, color: Colors.white),
                          ),
                          title: Text(
                            book['book_name'] ?? 'Unknown',
                            style: TextStyle(fontWeight: FontWeight.bold),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 4),
                              Text(
                                'Subject: ${book['subject_name'] ?? 'N/A'}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                'Class: ${book['class_name'] ?? 'N/A'}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                          trailing: downloadProgress.containsKey(index)
                              ? SizedBox(
                                  width: 40,
                                  height: 40,
                                  child: CircularProgressIndicator(
                                    value: downloadProgress[index],
                                    strokeWidth: 3,
                                  ),
                                )
                              : IconButton(
                                  icon: Icon(Icons.download, color: Colors.blue),
                                  onPressed: () {
                                    if (book['book_url'] != null) {
                                      downloadBook(
                                        index,
                                        book['book_url'],
                                        book['book_name'] ?? 'book',
                                      );
                                    }
                                  },
                                ),
                          onTap: () {
                            if (book['book_url'] != null) {
                              openBook(book['book_url']);
                            }
                          },
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
