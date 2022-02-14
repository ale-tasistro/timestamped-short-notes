// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'note.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Note _$NoteFromJson(Map<String, dynamic> json) => Note(
      json['desc'] as String,
    )..timestamp = DateTime.parse(json['timestamp'] as String);

Map<String, dynamic> _$NoteToJson(Note instance) => <String, dynamic>{
      'desc': instance.desc,
      'timestamp': instance.timestamp.toIso8601String(),
    };
