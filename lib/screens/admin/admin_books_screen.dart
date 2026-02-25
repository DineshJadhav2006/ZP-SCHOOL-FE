import 'package:flutter/material.dart';
import '../../services/book_service.dart';
import '../../config/env_config.dart';
import 'package:url_launcher/url_launcher.dart';
import 'add_book_screen.dart';

class AdminBooksScreen extends StatefulWidget {
  @override
  State<AdminBooksScreen> createState() => _AdminBooksScreenState();
}

class _AdminBooksScreenState extends State<AdminBooksScreen> {
  List<dynamic> books = [];
  List<dynamic> filteredBooks = [];
  bool isLoading = true;
  String? selectedClass;

  final List<String> classes = [
    "All", "1st", "2nd", "3rd", "4th", "5th", "6th", "7th", "8th", "9th", "10th"
  ];

  @override
  void initState() {
    super.initState();
    loadAllBooks();
  }

  Future<void> loadAllBooks() async {
    setState(() => isLoading = true);
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
      setState(() => isLoading = false);
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
        title: Text("Delete Book"),
        content: Text("Are you sure you want to delete this book?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      bool success = await BookService.deleteBook(bookId);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Book Deleted Successfully")),
        );
        loadAllBooks();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to Delete Book")),
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text("Books"),
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
                  title: Text("Filter by Class"),
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
            tooltip: "Add New Book",
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : filteredBooks.isEmpty
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
                          trailing: IconButton(
                            icon: Icon(Icons.delete_outline, color: Colors.red),
                            onPressed: () => deleteBook(book['id']),
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
