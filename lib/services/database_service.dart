import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/movie.dart';

class DatabaseService {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initDatabase();
    return _database!;
  }

  Future<Database> initDatabase() async {
    String path = join(await getDatabasesPath(), 'movie_database.db');
    return await openDatabase(path, version: 1, onCreate: _createDb);
  }

  Future<void> _createDb(Database db, int version) async {
    await db.execute('''
      CREATE TABLE movies(
        id INTEGER PRIMARY KEY,
        title TEXT,
        posterPath TEXT,
        overview TEXT,
        voteAverage REAL,
        isFavorite INTEGER
      )
    ''');
  }

  Future<void> insertMovie(Movie movie) async {
    final db = await database;
    await db.insert(
        'movies',
        {
          'id': movie.id,
          'title': movie.title,
          'posterPath': movie.posterPath,
          'overview': movie.overview,
          'voteAverage': movie.voteAverage,
          'isFavorite': movie.isFavorite ? 1 : 0,
        },
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> updateMovie(Movie movie) async {
    final db = await database;
    await db.update(
      'movies',
      {
        'title': movie.title,
        'posterPath': movie.posterPath,
        'overview': movie.overview,
        'voteAverage': movie.voteAverage,
        'isFavorite': movie.isFavorite ? 1 : 0,
      },
      where: 'id = ?',
      whereArgs: [movie.id],
    );
  }

  Future<List<Movie>> getMovies() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('movies');
    return List.generate(maps.length, (i) {
      return Movie(
        id: maps[i]['id'],
        title: maps[i]['title'],
        posterPath: maps[i]['posterPath'],
        overview: maps[i]['overview'],
        voteAverage: maps[i]['voteAverage'],
        isFavorite: maps[i]['isFavorite'] == 1,
      );
    });
  }
}
