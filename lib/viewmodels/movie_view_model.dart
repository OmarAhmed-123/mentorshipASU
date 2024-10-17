// ignore_for_file: avoid_print

import 'package:flutter/foundation.dart';
import '../models/movie.dart';
import '../services/api_service.dart';
import '../services/database_service.dart';
import 'package:hive/hive.dart';

class MovieViewModel extends ChangeNotifier {
  final ApiService apiService;
  final DatabaseService databaseService;
  List<Movie> _movies = [];
  bool _isLoading = false;

  MovieViewModel({required this.apiService, required this.databaseService});

  List<Movie> get movies => _movies;
  bool get isLoading => _isLoading;

  Future<void> fetchMovies() async {
    _isLoading = true;
    notifyListeners();

    try {
      final apiMovies = await apiService.fetchMovies();
      _movies = apiMovies;

      // Save to SQLite
      for (var movie in _movies) {
        await databaseService.insertMovie(movie);
      }

      // Save to Hive
      final box = await Hive.openBox<Movie>('movies');
      await box.clear();
      await box.addAll(_movies);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print('Error fetching movies: $e');
      _isLoading = false;
      notifyListeners();

      // Try to load from local storage
      await loadFromLocalStorage();
    }
  }

  Future<void> loadFromLocalStorage() async {
    try {
      // Try loading from Hive first
      final box = await Hive.openBox<Movie>('movies');
      if (box.isNotEmpty) {
        _movies = box.values.toList();
      } else {
        // If Hive is empty, try loading from SQLite
        _movies = await databaseService.getMovies();
      }
      notifyListeners();
    } catch (e) {
      print('Error loading from local storage: $e');
    }
  }

  Future<void> toggleFavorite(Movie movie) async {
    final index = _movies.indexWhere((m) => m.id == movie.id);
    if (index != -1) {
      _movies[index].isFavorite = !_movies[index].isFavorite;
      await databaseService.updateMovie(_movies[index]);
      final box = await Hive.openBox<Movie>('movies');
      await box.put(movie.id, _movies[index]);
      notifyListeners();
    }
  }

  List<Movie> get favoriteMovies =>
      _movies.where((movie) => movie.isFavorite).toList();
}
