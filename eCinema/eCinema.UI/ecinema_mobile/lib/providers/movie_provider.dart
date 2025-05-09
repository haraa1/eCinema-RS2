import 'package:ecinema_mobile/models/movie.dart';
import 'package:ecinema_mobile/providers/base_provider.dart';

class MovieProvider extends BaseProvider<Movie> {
  MovieProvider() : super("Movie");

  List<Movie> _movies = [];
  List<Movie> get movies => _movies;

  @override
  Movie fromJson(data) => Movie.fromJson(data);

  @override
  Future<List<Movie>> get([dynamic search]) async {
    _movies = await super.get(search);
    notifyListeners();
    return _movies;
  }
}
