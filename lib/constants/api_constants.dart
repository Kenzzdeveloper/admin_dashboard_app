class ApiConstants {
  // Ganti dengan URL Laravel kamu (untuk Docker: http://localhost:8000/api/)
  static const String baseUrl = 'http://192.168.51.250:18118/api/';
  static const String imageBaseUrl = 'http://192.168.51.250:18118/';

  // Endpoints
  static const String login = 'login';
  static const String register = 'register';
  static const String logout = 'logout';
  static const String user = 'user';
  static const String post = 'posts';

  // Kalau butuh full URL
  static String getFullUrl(String endpoint) => '$baseUrl$endpoint';
}
