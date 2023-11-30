import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class Books {
  int id;
  String title;
  String author;
  String coverUrl;
  String downloadUrl;

  Books(this.id, this.title, this.author, this.coverUrl, this.downloadUrl);

  factory Books.fromJson(Map<String, dynamic> json) {
    return Books(
      json['id'],
      json['title'],
      json['author'],
      json['cover_url'],
      json['download_url'],
    );
  }

  Future<void> _downloadBook(String title, String url) async {
    if (!await launchUrl(
      Uri.parse(url),
      mode: LaunchMode.externalApplication,
    )) {
      throw Exception('Não foi possível baixar o livro $title');
    }
  }

  Future<void> model(BuildContext context, String title, String url) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Container(
            color: Colors.white,
            width: 300,
            height: 200,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text(
                    title,
                    textAlign: TextAlign.center,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      _downloadBook(title, url);
                    },
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all<Color>(Colors.white),
                      foregroundColor:
                          MaterialStateProperty.all<Color>(Colors.blue),
                      side: MaterialStateProperty.all<BorderSide>(
                        const BorderSide(
                          color: Colors.blue,
                        ),
                      ),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                      ),
                    ),
                    child: const Text('Baixar eBook'),
                  ),
                  const Text(
                    'É necessário o download do eBook para leitura pelo app.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color.fromARGB(101, 0, 0, 0),
                    ),
                    textAlign: TextAlign.center,
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
