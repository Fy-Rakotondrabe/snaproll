import 'dart:convert';
import 'package:flutter/services.dart';

class Lesson {
  const Lesson({
    required this.id,
    required this.name,
    required this.tag,
    required this.tagColor,
    required this.shortDescription,
    required this.fullDescription,
    required this.imagePath,
    required this.photoColor1,
    required this.photoColor2,
    required this.level,
    this.duration,
  });

  final String id;
  final String name;
  final String tag;
  final Color tagColor;
  final String shortDescription;
  final String fullDescription;
  final String imagePath;
  final Color photoColor1;
  final Color photoColor2;
  final String level;
  final String? duration;

  factory Lesson.fromJson(Map<String, dynamic> json) {
    return Lesson(
      id: json['id'] as String,
      name: json['name'] as String,
      tag: json['tag'] as String,
      tagColor: Color(int.parse(json['tagColor'] as String)),
      shortDescription: json['shortDescription'] as String,
      fullDescription: json['fullDescription'] as String,
      imagePath: json['imagePath'] as String,
      photoColor1: Color(int.parse(json['photoColor1'] as String)),
      photoColor2: Color(int.parse(json['photoColor2'] as String)),
      level: json['level'] as String,
      duration: json['duration'] as String?,
    );
  }

  static Future<List<Lesson>> loadAll(String languageCode) async {
    final path = 'assets/data/lessons-$languageCode.json';
    final raw = await rootBundle.loadString(path);
    final data = jsonDecode(raw) as Map<String, dynamic>;
    return (data['lessons'] as List)
        .map((e) => Lesson.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
