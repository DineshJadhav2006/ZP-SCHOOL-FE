import 'package:flutter/material.dart';
import '../../services/book_service.dart';
import '../../config/env_config.dart';
import 'package:url_launcher/url_launcher.dart';
import 'add_book_screen.dart';
import '../../localization/language_service.dart';

class AdminBooksScreen extends StatefulWidget {
  @override
  State<AdminBooksScreen> createState() => _AdminBooksScreenState();
}

class _AdminBooksScreenState extends State<AdminBooksScreen> {
  List<dynamic> books = [];
  List<dynamic> filteredBooks = [];
  bool isLoading = true;
  String? selectedClass;
  String? errorMessage;
  Map<int, double> downloadProgress = {};

  final List<String> classes = [
    "All", "1st", "2nd", "3rd", "4th", "5th", "6th", "7th"
  ];

  @override
  void initState() {
    super.initState();
    loadAllBooks();
  }

  Future<void> loadAllBooks() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });
    try {
      List<dynamic> allBooks = [];
      for (String className in classes.skip(1)) {
        final data = await BookService.getBooksByClass(className);
        allBooks.addAll(data);
      }
      setState(() {
        books = allBooks;
        filteredBooks = allBooks;
        isLoading = false;
      });
    } catch (e) {
      print('Error loading books: $e');
      setState(() {
        isLoading = false;
        errorMessage = e.toString().contains('SocketException') || e.toString().contains('Failed host lookup')
            ? LanguageService.text("no_internet_connection")
            : LanguageService.text("failed_to_load_books");
      });
    }
  }

  void filterByClass(String? className) {
    setState(() {
      selectedClass = className;
      if (className == null || className == "All") {
        filteredBooks = books;
      } else {
        filteredBooks = books.where((book) => book['class_name'] == className).toList();
      }
    });
  }

  Future<void> deleteBook(String bookId) async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(LanguageService.text("delete_book")),
        content: Text(LanguageService.text("are_you_sure_delete_book")),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(LanguageService.text("cancel")),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(LanguageService.text("delete"), style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      bool success = await BookService.deleteBook(bookId);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(LanguageService.text("book_deleted_success"))),
        );
        loadAllBooks();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(LanguageService.text("book_deleted_failed"))),
        );
      }
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

  Future<void> downloadBook(int index, String bookUrl, String bookName) async {
    String fullUrl = bookUrl;
    if (bookUrl.startsWith('/')) {
      fullUrl = '${EnvConfig.apiBaseUrl}$bookUrl';
    }

    setState(() => downloadProgress[index] = 0.0);

    final filePath = await BookService.downloadBook(
      bookUrl: fullUrl,
      bookName: bookName,
      onProgress: (received, total) {
        if (total != -1) {
          setState(() => downloadProgress[index] = received / total);
        }
      },
    );

    setState(() => downloadProgress.remove(index));

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(filePath != null ? '${LanguageService.text("downloaded")} $bookName' : LanguageService.text("download_failed")),
          backgroundColor: filePath != null ? Colors.green : Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(LanguageService.text("books")),
        backgroundColor: theme.primaryColor,
        actions: [
          if (selectedClass != null)
            IconButton(
              icon: Icon(Icons.clear),
              onPressed: () {
                filterByClass(null);
              },
              tooltip: "Clear Filter",
            ),
          IconButton(
            icon: Icon(selectedClass != null ? Icons.filter_alt : Icons.filter_alt_outlined),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(LanguageService.text("filter_by_class")),
                  content: Container(
                    width: double.maxFinite,
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: classes.length,
                      itemBuilder: (context, index) {
                        final className = classes[index];
                        return ListTile(
                          title: Text(className),
                          trailing: (selectedClass == className || (selectedClass == null && className == "All"))
                              ? Icon(Icons.check, color: Colors.blue)
                              : null,
                          onTap: () {
                            Navigator.pop(context);
                            filterByClass(className == "All" ? null : className);
                          },
                        );
                      },
                    ),
                  ),
                ),
              );
            },
            tooltip: "Filter by Class",
          ),
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () async {
              bool? result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => AddBookScreen()),
              );
              if (result == true) loadAllBooks();
            },
            tooltip: LanguageService.text("add_new_book"),
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 64, color: Colors.red),
                      SizedBox(height: 16),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 32),
                        child: Text(errorMessage!, style: TextStyle(fontSize: 16, color: Colors.grey), textAlign: TextAlign.center),
                      ),
                      SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: loadAllBooks,
                        icon: Icon(Icons.refresh),
                        label: Text(LanguageService.text("retry")),
                      ),
                    ],
                  ),
                )
              : filteredBooks.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.book_outlined, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(LanguageService.text("no_books_available"), style: TextStyle(fontSize: 16, color: Colors.grey)),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: loadAllBooks,
                  child: ListView.builder(
                    padding: EdgeInsets.all(16),
                    itemCount: filteredBooks.length,
                    itemBuilder: (context, index) {
                      final book = filteredBooks[index];
                      return Card(
                        margin: EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: theme.primaryColor,
                            child: Icon(Icons.book, color: Colors.white),
                          ),
                          title: Text(
                            book['book_name'] ?? LanguageService.text("unknown"),
                            style: TextStyle(fontWeight: FontWeight.bold),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 4),
                              Text(
                                '${LanguageService.text("subject")}: ${book['subject_name'] ?? 'N/A'}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                '${LanguageService.text("class_label")}: ${book['class_name'] ?? 'N/A'}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (downloadProgress.containsKey(index))
                                SizedBox(
                                  width: 30,
                                  height: 30,
                                  child: CircularProgressIndicator(
                                    value: downloadProgress[index],
                                    strokeWidth: 2,
                                  ),
                                )
                              else
                                IconButton(
                                  icon: Icon(Icons.download, color: Colors.blue),
                                  onPressed: () {
                                    if (book['book_url'] != null && book['book_url'].toString().isNotEmpty) {
                                      downloadBook(
                                        index,
                                        book['book_url'],
                                        book['book_name'] ?? 'book',
                                      );
                                    }
                                  },
                                ),
                              IconButton(
                                icon: Icon(Icons.delete_outline, color: Colors.red),
                                onPressed: () => deleteBook(book['id']),
                              ),
                            ],
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
