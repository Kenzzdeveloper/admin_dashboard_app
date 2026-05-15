import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';
import '../constants/api_constants.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final ApiService _apiService = ApiService();

  // Initialize logger
  void init() {
    _apiService.initLogger();
  }

  // Login method
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _apiService.post(ApiConstants.login, {
        'email': email,
        'password': password,
      });

      if (response.statusCode == 200) {
        final rawData = response.data;
        final responseData = rawData is Map
            ? Map<String, dynamic>.from(rawData)
            : <String, dynamic>{};
        final dataRaw = responseData['data'];
        final payload =
            dataRaw is Map ? Map<String, dynamic>.from(dataRaw) : responseData;
        final token = payload['access_token']?.toString().isNotEmpty == true
            ? payload['access_token'].toString()
            : payload['token']?.toString();
        final user = payload['user'] is Map
            ? Map<String, dynamic>.from(payload['user'] as Map)
            : <String, dynamic>{};

        if (token == null || token.isEmpty) {
          return {
            'success': false,
            'message':
                responseData['message']?.toString() ?? 'Token tidak ditemukan',
          };
        }

        await _saveToken(token);
        await _saveUserData(payload);
        _apiService.setToken(token);

        return {'success': true, 'user': user};
      } else {
        final rawData = response.data;
        final responseData = rawData is Map
            ? Map<String, dynamic>.from(rawData)
            : <String, dynamic>{};
        return {
          'success': false,
          'message': responseData['message']?.toString() ?? 'Login failed',
        };
      }
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // Logout method
  Future<bool> logout() async {
    try {
      final response = await _apiService.post(ApiConstants.logout, {});

      // Clear token regardless of response
      await _clearToken();
      _apiService.removeToken();

      return response.statusCode == 200;
    } catch (e) {
      // Clear token even if API call fails
      await _clearToken();
      _apiService.removeToken();
      return true;
    }
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final token = await _getToken();
    return token != null && token.isNotEmpty;
  }

  // Get current user
  Future<Map<String, dynamic>?> getCurrentUser() async {
    try {
      final response = await _apiService.get(ApiConstants.user);
      if (response.statusCode == 200) {
        return response.data;
      }
    } catch (e) {
      // Token might be expired
      await logout();
    }
    return null;
  }

  // Private methods for token management
  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  Future<void> _saveUserData(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();

    // Try to get study_club_id from various possible locations in the response
    int? studyClubId;

    // Try direct field
    if (userData.containsKey('study_club_id')) {
      studyClubId = userData['study_club_id'] as int?;
    }

    // Try inside user object
    if (studyClubId == null &&
        userData.containsKey('user') &&
        userData['user'] is Map) {
      final user = userData['user'] as Map;
      if (user.containsKey('study_club_id')) {
        studyClubId = user['study_club_id'] as int?;
      }
    }

    // Default to 1 if not found (assuming first study club)
    studyClubId ??= 1;

    await prefs.setInt('study_club_id', studyClubId);
  }

  Future<int?> getStudyClubId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('study_club_id');
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<void> _clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  // Initialize token on app start
  Future<void> initializeToken() async {
    final token = await _getToken();
    if (token != null) {
      _apiService.setToken(token);
    }
  }
}
