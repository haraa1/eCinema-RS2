import 'package:ecinema_mobile/models/movie.dart';
import 'package:ecinema_mobile/providers/base_provider.dart';

class MovieProvider extends BaseProvider<Movie> {
  MovieProvider() : super("Movie");

  @override
  Movie fromJson(data) => Movie.fromJson(data);
}
