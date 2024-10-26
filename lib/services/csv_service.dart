// lib/services/csv_service.dart
import 'package:flutter/services.dart' show rootBundle;
import 'package:csv/csv.dart';
import '../models/film.dart';
import 'package:charset_converter/charset_converter.dart';

class CSVService {
  Future<List<Film>> loadCSV() async {
    try {
      // Dosyayı byte olarak yükleyin
      final rawData = await rootBundle.load('assets/imdb_top_250.csv');
      final list = rawData.buffer.asUint8List();

      // Doğru kodlamayla string'e dönüştürün (örneğin, windows-1254)
      String csvData = await CharsetConverter.decode('windows-1254', list);

      // CSV verisini dönüştürün
      List<List<dynamic>> listData = const CsvToListConverter(
        fieldDelimiter: ';',
        eol: '\n',
      ).convert(csvData);

      List<Film> films = [];
      for (var i = 1; i < listData.length; i++) {
        var row = listData[i];
        if (row.length >= 8) {
          films.add(Film(
            no: row[0].toString(),
            title: row[1],
            year: row[2].toString(),
            genre: row[3],
            origin: row[4],
            director: row[5],
            star: row[6],
            imdbLink: row[7],
          ));
        }
      }
      return films;
    } catch (e, stacktrace) {
      print('CSV dosyası yüklenirken hata oluştu: $e');
      print(stacktrace);
      rethrow;
    }
  }
}
