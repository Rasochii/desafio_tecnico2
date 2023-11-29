import 'package:http/http.dart' as http;
import 'dart:convert';

import '../models/bookModel.dart';

Future<List<Books>> getBooks() async {
  try {
    final response =
        await http.get(Uri.parse("https://escribo.com/books.json"));

    if (response.statusCode == 200) {
      List<dynamic> decodedList = json.decode(response.body);
      List<Books> booksList =
          decodedList.map((item) => Books.fromJson(item)).toList();
      return booksList;
    } else {
      throw Exception('Falha na requisição: ${response.statusCode}');
    }
  } catch (error) {
    throw Exception('Error: $error');
  }
}
