import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:desafio_tecnico2/api/books.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vocsy_epub_viewer/epub_viewer.dart';

import '../models/bookModel.dart';

class Ebooks extends StatefulWidget {
  const Ebooks({super.key});

  @override
  State<Ebooks> createState() => _EbooksState();
}

class _EbooksState extends State<Ebooks> {
  List<Books> books = [];

  @override
  void initState() {
    super.initState();
    _loadBooks();
  }

  Future<void> _loadBooks() async {
    try {
      List<Books> loadedBooks = await getBooks();
      setState(() {
        books = loadedBooks;
      });
    } catch (error) {
      throw Exception('Não foi possível buscar os livros disponíveis');
    }
  }

  Future<void> launchInBrowser(Uri url) async {
    if (!await launchUrl(
      url,
      mode: LaunchMode.externalApplication,
    )) {
      throw Exception('Não foi possível acessar a url $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Leitor de eBooks'),
            GestureDetector(
              onTap: () async {
                FilePickerResult? file = await FilePicker.platform.pickFiles(
                  allowedExtensions: ['epub'],
                  type: FileType.custom,
                );
                if (file != null) {
                  VocsyEpub.setConfig(
                    themeColor: Colors.blue,
                    identifier: "book",
                    scrollDirection: EpubScrollDirection.VERTICAL,
                    allowSharing: false,
                    enableTts: false,
                  );
                  VocsyEpub.open(file.paths[0]!);
                }
              },
              child: Row(
                children: const [
                  Icon(Icons.book),
                  Padding(
                    padding: EdgeInsets.only(left: 5),
                    child: Text('Ler'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: GridView.count(
        mainAxisSpacing: 2,
        crossAxisSpacing: 5,
        crossAxisCount: 2,
        children: books
            .map(
              (book) => SizedBox(
                child: Column(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          book.model(context, book.title, book.downloadUrl);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: NetworkImage(book.coverUrl),
                              fit: BoxFit.fitHeight,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 5),
                      child: RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style: const TextStyle(color: Colors.black),
                          children: [
                            TextSpan(text: book.title),
                            TextSpan(text: '\n\n${book.author}')
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}
