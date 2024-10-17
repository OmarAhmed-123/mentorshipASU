// ignore_for_file: use_super_parameters, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubits/movie_cubit.dart';
import '../models/movie.dart';
import '../services/api_service.dart';

class MovieListView extends StatefulWidget {
  const MovieListView({Key? key}) : super(key: key);

  @override
  _MovieListViewState createState() => _MovieListViewState();
}

class _MovieListViewState extends State<MovieListView> {
  @override
  void initState() {
    super.initState();
    context.read<MovieCubit>().fetchMovies();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Movies', style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.deepPurple,
          bottom: const TabBar(
            tabs: [
              Tab(text: 'All Movies'),
              Tab(text: 'Favorites'),
            ],
            indicatorColor: Colors.amberAccent,
            labelColor: Colors.amberAccent,
            unselectedLabelColor: Colors.white70,
          ),
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.deepPurple.shade200, Colors.indigo.shade100],
            ),
          ),
          child: TabBarView(
            children: [
              _buildMovieList(context, false),
              _buildMovieList(context, true),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMovieList(BuildContext context, bool favoritesOnly) {
    return BlocBuilder<MovieCubit, MovieState>(
      builder: (context, state) {
        if (state is MovieLoading) {
          return const Center(
              child: CircularProgressIndicator(color: Colors.deepPurple));
        } else if (state is MovieError) {
          return Center(
              child: Text(state.message,
                  style: TextStyle(color: Colors.red.shade800)));
        } else if (state is MovieLoaded) {
          final movies = favoritesOnly
              ? state.movies.where((movie) => movie.isFavorite).toList()
              : state.movies;
          return ListView.builder(
            itemCount: movies.length,
            itemBuilder: (context, index) {
              final movie = movies[index];
              return _buildMovieCard(context, movie);
            },
          );
        }
        return const Center(
            child: Text('No movies available',
                style: TextStyle(color: Colors.deepPurple)));
      },
    );
  }

  Widget _buildMovieCard(BuildContext context, Movie movie) {
    return Card(
      elevation: 8,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.white, Colors.deepPurple.shade50],
          ),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.all(12),
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              ApiService.imagePath + movie.posterPath,
              width: 60,
              height: 90,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.error, color: Colors.red);
              },
            ),
          ),
          title: Text(
            movie.title,
            style: const TextStyle(
                fontWeight: FontWeight.bold, color: Colors.deepPurple),
          ),
          subtitle: Text(
            movie.overview,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: Colors.grey.shade700),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(
                  movie.isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: movie.isFavorite ? Colors.red : Colors.grey,
                ),
                onPressed: () =>
                    context.read<MovieCubit>().toggleFavorite(movie),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.amberAccent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  movie.voteAverage.toStringAsFixed(1),
                  style: const TextStyle(
                    color: Colors.deepPurple,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
