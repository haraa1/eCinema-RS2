import 'package:json_annotation/json_annotation.dart';

part 'movie.g.dart';

@JsonSerializable()
class Movie {
  int? id;
  String? title;
  String? description;
  int? durationMinutes;
  String? language;
  DateTime? releaseDate;
  int? status;
  int? pgRating;
  List<int>? genreIds;
  List<int>? actorIds;
  final String? posterUrl;

  Movie({
    this.id,
    this.title,
    this.description,
    this.durationMinutes,
    this.language,
    this.releaseDate,
    this.status,
    this.pgRating,
    this.genreIds,
    this.actorIds,
    this.posterUrl,
  });

  factory Movie.fromJson(Map<String, dynamic> json) => _$MovieFromJson(json);
  Map<String, dynamic> toJson() => _$MovieToJson(this);
}
