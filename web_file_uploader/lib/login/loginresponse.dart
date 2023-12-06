class LoginDataResponse {
  final String accessToken;
  //final String id;
  final String employeename;
  final String email;
  final bool enabled;
  //final List<String> roles;

  const LoginDataResponse({
    required this.accessToken,
    //required this.id,
    required this.employeename,
    required this.email,
    required this.enabled,
    //required this.roles,
  });

  factory LoginDataResponse.fromJson(Map<String, dynamic> json) {
    return LoginDataResponse(
      accessToken: json['accessToken'] as String,
      //id: json['id'] as String,
      employeename: json['employeename'] as String,
      email: json['email'] as String,
      enabled: json['enabled'] as bool,
      //roles: json['roles'] as List<String>,
    );
  }
}