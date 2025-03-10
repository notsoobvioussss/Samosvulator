import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

@JsonSerializable()
class UserModel {
  final int id;
  final String username;
  final String password; // Добавь это поле
  final String name;
  final String surname;
  final String company;
  final String section;
  final String jobTitle;
  final String token;

  UserModel({
    required this.id,
    required this.username,
    required this.password, // Добавь сюда
    required this.name,
    required this.surname,
    required this.company,
    required this.section,
    required this.jobTitle,
    required this.token,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserModelToJson(this);
}