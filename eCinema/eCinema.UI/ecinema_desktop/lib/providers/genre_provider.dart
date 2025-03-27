import 'package:ecinema_desktop/models/genre.dart';
import 'package:ecinema_desktop/providers/base_provider.dart';

class GenreProvider extends BaseProvider<Genre> {
  GenreProvider() : super("Genre");

  @override
  Genre fromJson(data) => Genre.fromJson(data);
}
