// lib/main.dart
import 'package:flutter/material.dart';
import 'models/film.dart';
import 'services/csv_service.dart';
import 'dart:math';

void main() {
  runApp(FilmTahminOyunu());
}

class FilmTahminOyunu extends StatefulWidget {
  @override
  _FilmTahminOyunuState createState() => _FilmTahminOyunuState();
}

class _FilmTahminOyunuState extends State<FilmTahminOyunu> {
  ThemeMode _themeMode = ThemeMode.light;

  void _toggleTheme() {
    setState(() {
      if (_themeMode == ThemeMode.light) {
        _themeMode = ThemeMode.dark;
      } else {
        _themeMode = ThemeMode.light;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Film Tahmin Oyunu',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.dark,
      ),
      themeMode: _themeMode,
      home: AnaSayfa(toggleTheme: _toggleTheme),
    );
  }
}

class AnaSayfa extends StatelessWidget {
  final VoidCallback toggleTheme;

  AnaSayfa({required this.toggleTheme});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Film Tahmin Oyunu'),
        actions: [
          IconButton(
            icon: Icon(Icons.brightness_6),
            onPressed: toggleTheme,
          ),
        ],
      ),
      body: Center(
        child: ElevatedButton(
          child: const Text('Oyuna Başla'),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => OyunSayfasi(toggleTheme: toggleTheme),
              ),
            );
          },
        ),
      ),
    );
  }
}

class OyunSayfasi extends StatefulWidget {
  final VoidCallback toggleTheme;

  OyunSayfasi({required this.toggleTheme});

  @override
  _OyunSayfasiState createState() => _OyunSayfasiState();
}

class _OyunSayfasiState extends State<OyunSayfasi> {
  late Future<List<Film>> filmsFuture;
  List<Film> films = [];
  Film? selectedFilm;
  int puan = 100;
  bool yearRevealed = false;
  bool genreRevealed = false;
  bool directorRevealed = false;
  bool starRevealed = false;
  TextEditingController tahminController = TextEditingController();
  String mesaj = '';

  @override
  void initState() {
    super.initState();
    filmsFuture = CSVService().loadCSV();
    filmsFuture.then((value) {
      films = value;
      setState(() {
        final random = Random();
        selectedFilm = films[random.nextInt(films.length)];
      });
    });
  }

  void ipucuAc(String ipucu) {
    setState(() {
      switch (ipucu) {
        case 'year':
          if (!yearRevealed) {
            yearRevealed = true;
            puan -= 10;
          }
          break;
        case 'genre':
          if (!genreRevealed) {
            genreRevealed = true;
            puan -= 10;
          }
          break;
        case 'director':
          if (!directorRevealed) {
            directorRevealed = true;
            puan -= 10;
          }
          break;
        case 'star':
          if (!starRevealed) {
            starRevealed = true;
            puan -= 10;
          }
          break;
      }
      if (puan < 0) puan = 0;
    });
  }

  void tahminEt() {
    if (tahminController.text.toLowerCase() == selectedFilm!.title.toLowerCase()) {
      setState(() {
        mesaj = 'Tebrikler! Doğru tahmin. Kalan puanınız: $puan';
      });
    } else {
      setState(() {
        mesaj = 'Yanlış tahmin, tekrar deneyin.';
      });
    }
  }

  void yenidenBaslat() {
    setState(() {
      puan = 100;
      yearRevealed = false;
      genreRevealed = false;
      directorRevealed = false;
      starRevealed = false;
      tahminController.clear();
      mesaj = '';
      final random = Random();
      selectedFilm = films[random.nextInt(films.length)];
    });
  }

  @override
  void dispose() {
    tahminController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (selectedFilm == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Film Tahmin Oyunu'),
          actions: [
            IconButton(
              icon: Icon(Icons.brightness_6),
              onPressed: widget.toggleTheme,
            ),
          ],
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Film Tahmin Oyunu'),
        actions: [
          IconButton(
            icon: Icon(Icons.brightness_6),
            onPressed: widget.toggleTheme,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text('Puanınız: $puan', style: const TextStyle(fontSize: 24)),
              const SizedBox(height: 5),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                alignment: WrapAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () => ipucuAc('year'),
                    child: Text(yearRevealed ? 'Yıl: ${selectedFilm!.year}' : 'Yılı Göster'),
                  ),
                  ElevatedButton(
                    onPressed: () => ipucuAc('genre'),
                    child: Text(genreRevealed ? 'Tür: ${selectedFilm!.genre}' : 'Türü Göster'),
                  ),
                  ElevatedButton(
                    onPressed: () => ipucuAc('director'),
                    child: Text(directorRevealed ? 'Yönetmen: ${selectedFilm!.director}' : 'Yönetmeni Göster'),
                  ),
                  ElevatedButton(
                    onPressed: () => ipucuAc('star'),
                    child: Text(starRevealed ? 'Başrol: ${selectedFilm!.star}' : 'Başrolü Göster'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              TextField(
                controller: tahminController,
                decoration: const InputDecoration(
                  labelText: 'Film İsmini Tahmin Edin',
                ),
              ),
              ElevatedButton(
                onPressed: tahminEt,
                child: const Text('Tahmin Et'),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: yenidenBaslat,
                child: const Text('Yeniden Başlat'),
              ),
              const SizedBox(height: 20),
              Text(
                mesaj,
                style: const TextStyle(fontSize: 18, color: Colors.green),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
