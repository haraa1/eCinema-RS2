import 'package:ecinema_mobile/models/genre.dart';
import 'package:ecinema_mobile/providers/base_provider.dart';

class GenreProvider extends BaseProvider<Genre> {
  GenreProvider() : super("Genre");

  @override
  Genre fromJson(data) => Genre.fromJson(data);
}
