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

  @override
  void initState() {
    super.initState();
    loadBooks();
  }

  Future<void> loadBooks() async {
    setState(() => isLoading = true);
    try {
      final data = await BookService.getBooksByClass(widget.className);
      setState(() {
        books = data;
        isLoading = false;
      });
    } catch (e) {
      print('Error loading books: $e');
      setState(() => isLoading = false);
    }
  }

  Future<void> openBook(String url) async {
    String fullUrl = url;
    if (url.startsWith('/')) {
      fullUrl = '${EnvConfig.apiBaseUrl}$url';
    }
    
    final uri = Uri.parse(fullUrl);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? Center(child: CircularProgressIndicator())
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
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 4),
                              Text('Subject: ${book['subject_name'] ?? 'N/A'}'),
                              Text('Class: ${book['class_name'] ?? 'N/A'}'),
                            ],
                          ),
                          trailing: Icon(Icons.arrow_forward_ios, size: 16),
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
