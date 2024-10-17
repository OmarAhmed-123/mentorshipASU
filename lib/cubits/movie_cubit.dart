import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../models/movie.dart';
import '../services/api_service.dart';
import '../services/database_service.dart';
import 'package:hive/hive.dart';

part 'movie_state.dart';

class MovieCubit extends Cubit<MovieState> {
  final ApiService _apiService;
  final DatabaseService _databaseService;

  MovieCubit(this._apiService, this._databaseService) : super(MovieInitial());

  Future<void> fetchMovies() async {
    emit(MovieLoading());
    try {
      final apiMovies = await _apiService.fetchMovies();
      for (var movie in apiMovies) {
        await _databaseService.insertMovie(movie);
      }

      final box = await Hive.openBox<Movie>('movies');
      await box.clear();
      await box.addAll(apiMovies);

      emit(MovieLoaded(apiMovies));
    } catch (e) {
      emit(MovieError('Failed to fetch movies: $e'));
      await loadFromLocalStorage();
    }
  }

  Future<void> loadFromLocalStorage() async {
    try {
      final box = await Hive.openBox<Movie>('movies');
      if (box.isNotEmpty) {
        final movies = box.values.toList();
        emit(MovieLoaded(movies));
      } else {
        final movies = await _databaseService.getMovies();
        emit(MovieLoaded(movies));
      }
    } catch (e) {
      emit(MovieError('Error loading from local storage: $e'));
    }
  }

  Future<void> toggleFavorite(Movie movie) async {
    final currentState = state;
    if (currentState is MovieLoaded) {
      final updatedMovies = currentState.movies.map((m) {
        if (m.id == movie.id) {
          final updatedMovie = Movie(
            id: m.id,
            title: m.title,
            posterPath: m.posterPath,
            overview: m.overview,
            voteAverage: m.voteAverage,
            isFavorite: !m.isFavorite,
          );
          _databaseService.updateMovie(updatedMovie);
          return updatedMovie;
        }
        return m;
      }).toList();

      final box = await Hive.openBox<Movie>('movies');
      await box.put(movie.id, movie);

      emit(MovieLoaded(updatedMovies));
    }
  }
}
