import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'models/movie.dart';
import 'cubits/movie_cubit.dart';
import 'views/movie_list_view.dart';
import 'services/api_service.dart';
import 'services/database_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize sqflite_ffi
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  await Hive.initFlutter();
  Hive.registerAdapter(MovieAdapter());

  final apiService = ApiService();
  final databaseService = DatabaseService();

  runApp(MyApp(apiService: apiService, databaseService: databaseService));
}

class MyApp extends StatelessWidget {
  final ApiService apiService;
  final DatabaseService databaseService;

  const MyApp(
      {Key? key, required this.apiService, required this.databaseService})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MovieCubit(apiService, databaseService),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Movie App',
        theme: ThemeData(
          scaffoldBackgroundColor: Colors.grey[100],
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.indigo,
            elevation: 0,
          ),
          colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.indigo)
              .copyWith(secondary: Colors.pinkAccent),
        ),
        home: const MovieListView(),
      ),
    );
  }
}
