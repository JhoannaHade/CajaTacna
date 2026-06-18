class LoginRequest {
  final String email;
  final String password;

  LoginRequest({required this.email, required this.password});

  Map<String, dynamic> toJson() => {
    'email': email,
    'password': password,
  };
}

class AuthResponse {
  final String accessToken;
  final String? refreshToken;
  final int expiresIn;
  final String tokenType;
  final UserData? user;
  final String? error;
  final String? errorDescription;

  AuthResponse({
    required this.accessToken,
    this.refreshToken,
    required this.expiresIn,
    required this.tokenType,
    this.user,
    this.error,
    this.errorDescription,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) => AuthResponse(
    accessToken: json['access_token'] ?? '',
    refreshToken: json['refresh_token'],
    expiresIn: json['expires_in'] ?? 0,
    tokenType: json['token_type'] ?? '',
    user: json['user'] != null ? UserData.fromJson(json['user']) : null,
    error: json['error'],
    errorDescription: json['error_description'],
  );
}

class UserData {
  final String id;
  final String email;

  UserData({required this.id, required this.email});

  factory UserData.fromJson(Map<String, dynamic> json) => UserData(
    id: json['id'] ?? '',
    email: json['email'] ?? '',
  );
}
