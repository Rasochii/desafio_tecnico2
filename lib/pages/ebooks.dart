import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:desafio_tecnico2/api/books.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vocsy_epub_viewer/epub_viewer.dart';

import '../models/bookModel.dart';

class Ebooks extends StatefulWidget {
  const Ebooks({super.key});

  @override
  State<Ebooks> createState() => _EbooksState();
}

class _EbooksState extends State<Ebooks> with SingleTickerProviderStateMixin {
  List<Books> books = [];
  List<int> favorites = [];
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _loadBooks();
    _tabController = TabController(length: 3, vsync: this);
    carregarFavs();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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

  Future<void> salvarLista(String key, List<int> value) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String serializedList = value.join(",");
    pref.setString(key, serializedList);
  }

  Future<String?> carregarLista(String key) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    return pref.getString(key);
  }

  Future<void>? carregarFavs() async {
    String? value = await carregarLista('favoritos');

    if (value != null) {
      List<String>? stringList = value.split(",");
      List<int>? intList = stringList.map((e) => int.parse(e)).toList();
      setState(() {
        favorites = intList;
      });
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
              child: const Row(
                children: [
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
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(
              text: 'Geral',
              icon: Icon(Icons.library_books),
            ),
            Tab(
              text: 'Favoritos',
              icon: Icon(Icons.favorite),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          GridView.count(
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
                              child: Align(
                                alignment: Alignment.topRight,
                                child: IconButton.filled(
                                  onPressed: () {
                                    if (favorites.contains(book.id)) {
                                      setState(() {
                                        favorites.removeWhere(
                                            (element) => element == book.id);
                                      });
                                      salvarLista("favoritos", favorites);
                                    } else {
                                      setState(() {
                                        favorites.add(book.id);
                                      });

                                      salvarLista('favoritos', favorites);
                                    }
                                  },
                                  isSelected: favorites.contains(book.id),
                                  selectedIcon:
                                      const Icon(Icons.bookmark_outlined),
                                  icon: const Icon(Icons.bookmark_outline),
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
          GridView.count(
            mainAxisSpacing: 2,
            crossAxisSpacing: 5,
            crossAxisCount: 2,
            children: books
                .where((book) => (favorites.contains(book.id)))
                .map((book) => SizedBox(
                      child: Column(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                book.model(
                                    context, book.title, book.downloadUrl);
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: NetworkImage(book.coverUrl),
                                    fit: BoxFit.fitHeight,
                                  ),
                                ),
                                child: Align(
                                  alignment: Alignment.topRight,
                                  child: IconButton.filled(
                                    onPressed: () {
                                      if (favorites.contains(book.id)) {
                                        setState(() {
                                          favorites.removeWhere(
                                              (element) => element == book.id);
                                        });
                                        salvarLista("favoritos", favorites);
                                      } else {
                                        setState(() {
                                          favorites.add(book.id);
                                        });

                                        salvarLista('favoritos', favorites);
                                      }
                                    },
                                    isSelected: favorites.contains(book.id),
                                    selectedIcon:
                                        const Icon(Icons.bookmark_outlined),
                                    icon: const Icon(Icons.bookmark_outline),
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
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }
}
