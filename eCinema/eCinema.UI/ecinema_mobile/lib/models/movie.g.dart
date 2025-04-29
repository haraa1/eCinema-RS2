// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'movie.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Movie _$MovieFromJson(Map<String, dynamic> json) => Movie(
  id: (json['id'] as num?)?.toInt(),
  title: json['title'] as String?,
  description: json['description'] as String?,
  durationMinutes: (json['durationMinutes'] as num?)?.toInt(),
  language: json['language'] as String?,
  releaseDate:
      json['releaseDate'] == null
          ? null
          : DateTime.parse(json['releaseDate'] as String),
  status: (json['status'] as num?)?.toInt(),
  pgRating: (json['pgRating'] as num?)?.toInt(),
  genreIds:
      (json['genreIds'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList(),
  actorIds:
      (json['actorIds'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList(),
  posterUrl: json['posterUrl'] as String?,
);

Map<String, dynamic> _$MovieToJson(Movie instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'description': instance.description,
  'durationMinutes': instance.durationMinutes,
  'language': instance.language,
  'releaseDate': instance.releaseDate?.toIso8601String(),
  'status': instance.status,
  'pgRating': instance.pgRating,
  'genreIds': instance.genreIds,
  'actorIds': instance.actorIds,
  'posterUrl': instance.posterUrl,
};
