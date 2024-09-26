import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/movie.dart';

class ApiService {
  static const String apiKey = "9813ce01a72ca1bd2ae25f091898b1c7";
  static const String baseUrl = "https://api.themoviedb.org/3";
  static const String imagePath = "https://image.tmdb.org/t/p/w500/";
  static const String apiUrl =
      "$baseUrl/discover/movie?sort_by=popularity.desc&api_key=$apiKey";

  Future<List<Movie>> fetchMovies() async {
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final List<dynamic> results = json.decode(response.body)['results'];
      return results.map((json) => Movie.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load movies');
    }
  }
}
