# 📚 Panduan Uji Kompetensi - Admin Dashboard App

## Ringkasan Aplikasi
Aplikasi ini adalah **Admin Dashboard Flutter** yang terhubung dengan **Laravel Backend API**. Fitur utama yang baru diimplementasikan:
1. **Login dari API** - Autentikasi berbasis token JWT
2. **View Posts/Berita** - Menampilkan posts dari admin dashboard Laravel

---

## 🔐 FITUR 1: SISTEM LOGIN DARI API

### 1.1 Alur Login Lengkap

```
User Input (Email & Password)
          ↓
    LoginScreen
          ↓
   AuthService.login()
          ↓
   ApiService.post(endpoint: 'login')
          ↓
   Laravel API /api/login
          ↓
   Terima Token (JWT)
          ↓
   Simpan Token di SharedPreferences
          ↓
   Set Authorization Header di Dio
          ↓
   Navigate ke MainScreen
```

### 1.2 Komponen Penting

#### **A. LoginScreen** (`lib/screens/login_screen.dart`)
- **Fungsi**: UI untuk input email & password
- **Proses**:
  - Validasi input tidak kosong
  - Panggil `AuthService().login(email, password)`
  - Jika berhasil → navigasi ke MainScreen
  - Jika gagal → tampilkan error message

**Kode Alur**:
```dart
Future<void> _handleLogin() async {
  // 1. Validasi
  if (email.isEmpty || password.isEmpty) return;
  
  // 2. Panggil service
  final result = await _authService.login(email, password);
  
  // 3. Handle hasil
  if (result['success']) {
    // Navigasi ke dashboard
    Navigator.pushReplacement(context, ...);
  } else {
    // Tampilkan error
    setState(() => _errorMessage = result['message']);
  }
}
```

#### **B. AuthService** (`lib/services/auth_service.dart`)
- **Pola**: Singleton (hanya satu instance di seluruh aplikasi)
- **Fungsi Utama**:

| Fungsi | Deskripsi |
|--------|-----------|
| `login()` | Kirim email & password ke API, terima token |
| `logout()` | Hapus token & user data |
| `isLoggedIn()` | Cek apakah sudah login (ada token?) |
| `getToken()` | Ambil token dari storage |
| `getCurrentUser()` | Fetch data user dari API |

**Fokus Penting - Method `login()`**:
```dart
Future<Map<String, dynamic>> login(String email, String password) async {
  // 1. Kirim request POST ke API
  final response = await _apiService.post(ApiConstants.login, {
    'email': email,
    'password': password,
  });

  // 2. Jika sukses (status 200)
  if (response.statusCode == 200) {
    // 3. Extract token dari response
    final token = payload['access_token'] ?? payload['token'];
    
    // 4. Simpan token ke SharedPreferences
    await _saveToken(token);
    
    // 5. Set token di header Dio untuk request berikutnya
    _apiService.setToken(token);
    
    return {'success': true, 'user': user};
  }
  // ... jika gagal
}
```

#### **C. ApiService** (`lib/services/api_service.dart`)
- **Pola**: Singleton
- **Library**: Menggunakan **Dio** (HTTP client)
- **Fungsi**:
  - POST request untuk login
  - GET request untuk fetch posts
  - Management Authorization header

**Method Penting**:
```dart
// Simpan token di header untuk semua request berikutnya
void setToken(String token) {
  _dio.options.headers['Authorization'] = 'Bearer $token';
}

// HTTP Methods
Future<Response> post(String endpoint, dynamic data) => _dio.post(endpoint, data: data);
Future<Response> get(String endpoint) => _dio.get(endpoint);
```

### 1.3 Token Management
- **Storage**: SharedPreferences (key: `auth_token`)
- **Format**: Bearer token (JWT)
- **Header**: `Authorization: Bearer {token}`
- **Lifecycle**:
  - Disimpan setelah login sukses
  - Digunakan untuk setiap API request
  - Dihapus saat logout

### 1.4 Error Handling Login
**Kondisi yang bisa terjadi**:
1. **Empty input** → Tampilkan "Harap isi semua field"
2. **Email/password salah** → API return status 401
3. **Server error** → API return status 500
4. **Network error** → Timeout atau no internet

**Response Handling**:
```dart
if (response.statusCode == 200) {
  // Sukses
} else if (response.statusCode == 401) {
  // Unauthorized (email/password salah)
} else if (response.statusCode >= 500) {
  // Server error
}
```

---

## 📰 FITUR 2: VIEW POSTS/BERITA DARI API LARAVEL

### 2.1 Alur Fetch Posts

```
User Buka Posts Page
          ↓
   initState() → _fetchNewsFromApi()
          ↓
   ApiService.get(endpoint: 'posts')
          ↓
   Laravel API /api/posts
   (dengan Authorization header)
          ↓
   Parse JSON response
          ↓
   Convert ke NewsModel objects
          ↓
   Display di ListView
```

### 2.2 Komponen Penting

#### **A. PostsBody** (`lib/screens/posts_body.dart`)
- **Fungsi**: Menampilkan list posts/berita
- **Feature**:
  - Fetch posts dari API saat page load
  - Filter by category
  - Search by title/content
  - Display posts dengan image & content

**Kode Penting**:
```dart
@override
void initState() {
  super.initState();
  _fetchNewsFromApi(); // Fetch data saat page dibuka
}

Future<void> _fetchNewsFromApi() async {
  try {
    // 1. GET request ke /api/posts
    final response = await ApiService().get(ApiConstants.post);
    
    // 2. Parse response
    if (response.statusCode == 200) {
      // 3. Convert JSON ke NewsModel list
      List<NewsModel> newsList = [];
      if (response.data is List) {
        newsList = response.data.map((item) => NewsModel.fromJson(item)).toList();
      } else if (response.data is Map && response.data['data'] != null) {
        newsList = response.data['data'].map((item) => NewsModel.fromJson(item)).toList();
      }
      
      // 4. Update UI
      setState(() {
        _newsItems = newsList;
        _isLoading = false;
      });
    }
  } catch (e) {
    setState(() => _errorMessage = 'Error: $e');
  }
}
```

#### **B. NewsModel** (`lib/screens/posts_body.dart`)
- **Fungsi**: Model data untuk posts
- **Fields**:
  ```dart
  - id: ID unik post dari database
  - title: Judul berita
  - content: Isi berita (bisa HTML dari Laravel)
  - category: Kategori (Pengumuman, Kegiatan, Update, Event)
  - author: Nama author
  - date: Tanggal publish
  - imageUrl: URL gambar (di-build dari base URL API)
  ```

- **Method `fromJson`**:
  ```dart
  factory NewsModel.fromJson(Map<String, dynamic> json) {
    return NewsModel(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      category: json['category'] ?? 'Update',
      author: json['author'] ?? 'Admin',
      date: json['date'] ?? '',
      imageUrl: buildImageUrl(json['image']), // Build full URL
    );
  }
  ```

#### **C. Helper Functions**

**1. `buildImageUrl()`**
```dart
// Mengubah relative path menjadi full URL
String buildImageUrl(String? imagePath) {
  if (imagePath == null) return '';
  
  // Jika sudah full URL (http/https)
  if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
    return imagePath;
  }
  
  // Gabung dengan baseUrl API
  return '${ApiConstants.baseUrl}$imagePath';
}
```

**2. `stripHtmlTags()`**
```dart
// Menghapus HTML tags dari content Laravel
String stripHtmlTags(String html) {
  final RegExp exp = RegExp(r"<[^>]*>", multiLine: true, caseSensitive: false);
  return html.replaceAll(exp, '').trim();
}
```

### 2.3 Response API Format
**Kemungkinan format dari Laravel**:

**Format 1** (List langsung):
```json
[
  {
    "id": 1,
    "title": "Berita 1",
    "content": "...",
    "category": "Pengumuman",
    "author": "Admin",
    "date": "2024-05-17",
    "image": "posts/image1.jpg"
  }
]
```

**Format 2** (Wrapped dalam data):
```json
{
  "data": [
    {
      "id": 1,
      "title": "Berita 1",
      ...
    }
  ]
}
```

**Parsing di code**:
```dart
if (data is List) {
  // Format 1
  newsList = data.map((item) => NewsModel.fromJson(item)).toList();
} else if (data is Map && data.containsKey('data')) {
  // Format 2
  newsList = (data['data'] as List).map((item) => NewsModel.fromJson(item)).toList();
}
```

### 2.4 Error Handling Posts
- **Network Error** → Tampilkan error message
- **No Auth Token** → 401 Unauthorized (pengguna perlu login ulang)
- **Server Error** → 500 Internal Server Error
- **Empty Posts** → Tampilkan message "Tidak ada berita"

---

## 🔗 INTEGRASI API LENGKAP

### 3.1 API Endpoints
| Endpoint | Method | Deskripsi | Auth? |
|----------|--------|-----------|-------|
| `/login` | POST | Autentikasi user | ❌ |
| `/logout` | POST | Logout & clear token | ✅ |
| `/user` | GET | Fetch user profile | ✅ |
| `/posts` | GET | Fetch all posts | ✅ |

### 3.2 API Constants
```dart
class ApiConstants {
  static const String baseUrl = 'http://192.168.51.250:18118/api/';
  
  // Endpoints
  static const String login = 'login';
  static const String logout = 'logout';
  static const String user = 'user';
  static const String post = 'posts';
}
```

### 3.3 Dio Configuration
```dart
Dio _dio = Dio(BaseOptions(
  baseUrl: ApiConstants.baseUrl,
  connectTimeout: const Duration(seconds: 15),
  receiveTimeout: const Duration(seconds: 15),
  headers: {
    'Accept': 'application/json',
    'Content-Type': 'application/json',
  },
));
```

---

## 🛡️ KEAMANAN & BEST PRACTICES

### 4.1 Token Security
- ✅ Token disimpan di SharedPreferences (secure enough untuk local storage)
- ✅ Menggunakan Bearer token (JWT format)
- ✅ Token dihapus saat logout
- ⚠️ Token bisa expired → perlu handle di API response

### 4.2 Error Handling Best Practices
```dart
try {
  // API call
  final response = await _apiService.post(endpoint, data);
  
  if (response.statusCode == 200) {
    // Sukses
  } else {
    // Handle error status code
  }
} catch (e) {
  // Network error atau exception lainnya
}
```

### 4.3 Data Validation
- Validasi input sebelum kirim ke API
- Handle null/empty values
- Decode HTML entities dari Laravel

---

## 🎯 PERTANYAAN YANG MUNGKIN DITANYA PENGUJI

### Kategori 1: Alur Aplikasi
1. **"Jelaskan flow login dari awal sampai user bisa melihat dashboard?"**
   - ✓ User input email & password → LoginScreen
   - ✓ Panggil AuthService.login()
   - ✓ AuthService kirim POST request ke API
   - ✓ API return token
   - ✓ Token disimpan di SharedPreferences
   - ✓ Token diset di Dio header
   - ✓ Navigate ke MainScreen

2. **"Bagaimana cara aplikasi tahu user sudah login?"**
   - SharedPreferences menyimpan token (key: `auth_token`)
   - Saat app startup, cek apakah token ada
   - Jika ada → ke MainScreen, jika tidak → LoginScreen

3. **"Gimana posts bisa tampil di aplikasi?"**
   - Saat PostsBody dibuka, initState() → _fetchNewsFromApi()
   - Kirim GET request ke `/api/posts`
   - API return list posts
   - Parse JSON ke NewsModel objects
   - Display di ListView

### Kategori 2: Teknis - Token & Authorization
4. **"Apa itu Authorization header?"**
   - Header HTTP yang berisi token untuk autentikasi
   - Format: `Authorization: Bearer {token}`
   - Dikirim di setiap request ke endpoint yang memerlukan auth

5. **"Bagaimana token disimpan dan diakses?"**
   - Disimpan: `SharedPreferences.setString('auth_token', token)`
   - Diakses: `SharedPreferences.getString('auth_token')`
   - Digunakan: `_dio.options.headers['Authorization'] = 'Bearer $token'`

6. **"Apa yang terjadi jika token expired?"**
   - API return 401 Unauthorized
   - AuthService trigger logout
   - Token dihapus
   - User dikembalikan ke LoginScreen

### Kategori 3: Response Handling
7. **"Bagaimana cara handle response dari API?"**
   - Check statusCode (200 = sukses, 401 = unauthorized, 500 = server error)
   - Parse JSON data
   - Convert ke model objects (NewsModel, User, etc)
   - Update UI dengan setState()

8. **"Kenapa ada 2 format response di posts (List vs Map.data)?"**
   - Laravel bisa return format berbeda
   - Some APIs return `[...]` langsung
   - Some return `{ "data": [...] }`
   - Code handle kedua format untuk fleksibilitas

### Kategori 4: Error Handling
9. **"Bagaimana aplikasi handle error saat login gagal?"**
   - Catch exception di try-catch block
   - Check statusCode
   - Return map dengan `success: false` dan pesan error
   - UI tampilkan error message kepada user

10. **"Apa yang terjadi jika network error saat fetch posts?"**
    - Catch exception
    - Set errorMessage state
    - UI tampilkan error message
    - User bisa retry dengan pull-to-refresh

### Kategori 5: Library & Tools
11. **"Apa itu Dio? Kenapa pakai Dio bukannya http?"**
    - Dio = HTTP client dengan fitur lebih lengkap
    - Support interceptor (untuk logging, error handling)
    - Support timeout config
    - Support base URL & headers default
    - Lebih mudah untuk API complex

12. **"Apa itu SharedPreferences?"**
    - Local storage untuk menyimpan data sederhana
    - Key-value format
    - Data tersimpan di device (tidak di cloud)
    - Digunakan untuk: token, user ID, preferences

13. **"Apa itu Singleton pattern di AuthService & ApiService?"**
    - Design pattern untuk ensure hanya ada 1 instance
    - Kode: `static final _instance = Service._internal();`
    - Benefit: Data shared, efficient memory usage

### Kategori 6: Model & Data
14. **"Bagaimana NewsModel.fromJson() bekerja?"**
    - Factory constructor untuk convert JSON ke object
    - Extract fields dari Map JSON
    - Handle null values dengan default value
    - Build full image URL jika ada gambar

15. **"Kenapa perlu `stripHtmlTags()` function?"**
    - Laravel content bisa berisi HTML tags
    - Saat ditampilkan di Flutter, HTML tags tidak bagus
    - Fungsi hapus semua `<tag>` dan decode entities

### Kategori 7: UI Flow
16. **"Bagaimana user navigate setelah login sukses?"**
    - Navigator.pushReplacement() → MainScreen
    - pushReplacement() = remove LoginScreen dari stack
    - Jadi user tidak bisa back ke login screen

17. **"Bagaimana posts di-filter & di-search?"**
    - `_filtered` getter filter by category & search query
    - `_selectedCategory` untuk filter kategori
    - `_searchQuery` untuk search di title & content
    - ListView rebuild dengan filtered list

---

## 💡 TIPS PRESENTASI

### Saat Presentasi:
1. **Mulai dengan Overview**
   - "Ini adalah Admin Dashboard untuk Study Club"
   - "Ada 2 fitur utama: Login & View Posts"

2. **Demo Live (jika bisa)**
   - Login dengan credential dari backend
   - Navigate ke Posts page
   - Show posts loading & display

3. **Penjelasan Technical**
   - Draw flow diagram (login flow, posts flow)
   - Show code snippets penting
   - Jelaskan integration dengan Laravel API

4. **Siapkan Jawaban**
   - Pahami seluruh alur dari awal ke akhir
   - Tahu kenapa pakai Dio, SharedPreferences, dll
   - Siap jelaskan error handling & edge cases

### Pertanyaan Sulit - Jawaban Siap:
- **"Kenapa harus simpan token?"** → Agar setiap request autentikasi dengan API
- **"Bagaimana kalau token hilang?"** → User harus login ulang
- **"Bagaimana scalability?"** → Bisa extend dengan more endpoints, pagination, etc
- **"Bagaimana kalau posts banyak?"** → Bisa implement pagination di API

---

## 📝 CHECKLIST PERSIAPAN

- [ ] Pahami flow login dari awal sampai akhir
- [ ] Pahami struktur AuthService (singleton, methods)
- [ ] Pahami struktur ApiService (Dio config, setToken)
- [ ] Pahami NewsModel dan fromJson()
- [ ] Pahami token management (save, use, delete)
- [ ] Pahami error handling di setiap step
- [ ] Siap jelaskan kenapa pakai setiap library
- [ ] Practice demo aplikasi
- [ ] Siap jawab 17 pertanyaan di atas
- [ ] Draw flow diagram di kertas

---

## 🚀 CATATAN PENTING

**Ingat**:
- Aplikasi ini menggunakan **pattern-based architecture** (Service layer)
- **Dio** untuk HTTP requests dengan interceptor
- **SharedPreferences** untuk local storage token
- **Singleton pattern** untuk single instance services
- **try-catch** untuk error handling
- **setState** untuk update UI setelah async operation

**Jangan lupa**:
- Token adalah KEY untuk autentikasi
- Error handling harus comprehensive
- UI harus responsive & show loading state
- API response format harus di-handle dengan baik

---

Good luck untuk uji kompetensi! 💪
