import 'package:freezed_annotation/freezed_annotation.dart';

part 'orionoid_auth_response.freezed.dart';
part 'orionoid_auth_response.g.dart';

@freezed
class OrionoidAuthResponse with _$OrionoidAuthResponse {
  const factory OrionoidAuthResponse({
    required String name,
    required String version,
    required OrionoidAuthResult result,
    OrionoidAuthData? data,
    OrionoidAuthUserData? userData,
  }) = _OrionoidAuthResponse;

  factory OrionoidAuthResponse.fromJson(Map<String, dynamic> json) =>
      _$OrionoidAuthResponseFromJson(json);
}

@freezed
class OrionoidAuthResult with _$OrionoidAuthResult {
  const factory OrionoidAuthResult({
    required String status,
    required String type,
    required String description,
    required String message,
  }) = _OrionoidAuthResult;

  factory OrionoidAuthResult.fromJson(Map<String, dynamic> json) =>
      _$OrionoidAuthResultFromJson(json);
}

@freezed
class OrionoidAuthData with _$OrionoidAuthData {
  const factory OrionoidAuthData({
    String? code,
    @Default(5) int interval,
    int? expiration,
    String? link,
    String? direct,
    String? qr,
    OrionoidAuthUser? user,
    String? token,
  }) = _OrionoidAuthData;

  factory OrionoidAuthData.fromJson(Map<String, dynamic> json) =>
      _$OrionoidAuthDataFromJson(json);
}

@freezed
class OrionoidAuthUserData with _$OrionoidAuthUserData {
  const factory OrionoidAuthUserData({
    required OrionoidAuthUser user,
    required String token,
  }) = _OrionoidAuthUserData;

  factory OrionoidAuthUserData.fromJson(Map<String, dynamic> json) =>
      _$OrionoidAuthUserDataFromJson(json);
}

@freezed
class OrionoidAuthUser with _$OrionoidAuthUser {
  const factory OrionoidAuthUser({
    required String id,
    required String email,
    String? username,
  }) = _OrionoidAuthUser;

  factory OrionoidAuthUser.fromJson(Map<String, dynamic> json) =>
      _$OrionoidAuthUserFromJson(json);
} 