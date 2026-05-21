# ⚡ QUICK REFERENCE CHEAT SHEET

## 🎯 10 POIN KUNCI

### 1. APP ENTRY POINT
```dart
void main() {
  // Cek apakah user sudah login dari sebelumnya
  final isLoggedIn = SharedPreferences.getBool('isLoggedIn') ?? false;
  
  // Jika sudah login → MainScreen, jika belum → LoginScreen
  runApp(StudyClubApp(isLoggedIn: isLoggedIn));
}
```
**Ingat**: Shared Preferences disimpan secara persistant di device

---

### 2. LOGIN FLOW (3 LANGKAH UTAMA)
1. **User Submit** → `_handleLogin()` di LoginScreen
2. **Service Process** → `AuthService.login()` kirim ke API
3. **Save & Navigate** → Token disimpan, header diupdate, navigasi ke MainScreen

```
Email/Password → AuthService → ApiService → Laravel → Token → Simpan → Navigate
```

---

### 3. TOKEN MANAGEMENT
| Operasi | Kode |
|---------|------|
| **Simpan** | `SharedPreferences.setString('auth_token', token)` |
| **Ambil** | `SharedPreferences.getString('auth_token')` |
| **Set di Dio** | `_dio.options.headers['Authorization'] = 'Bearer $token'` |
| **Hapus** | `SharedPreferences.remove('auth_token')` |

**Token Format**: `Bearer eyJhbGciOiJIUzI1NiIs...` (JWT format)

---

### 4. FETCH POSTS PATTERN
```dart
@override
void initState() {
  _fetchNewsFromApi(); // ← Fetch saat page dibuka
}

Future<void> _fetchNewsFromApi() {
  // GET /posts dengan Authorization header
  // Parse response ke List<NewsModel>
  // setState() untuk update UI
}
```

**Endpoint**: `/posts` → Requires Authorization token

---

### 5. RESPONSE PARSING (2 FORMAT)
```dart
// Format 1: List langsung
if (response.data is List) {
  newsList = response.data.map(...).toList();
}

// Format 2: Wrapped dalam "data"
else if (response.data['data'] is List) {
  newsList = response.data['data'].map(...).toList();
}
```

**Flexible parsing** untuk handle berbagai response format dari backend

---

### 6. MODEL CONVERSION
```dart
// JSON dari API:
{ "id": 1, "title": "...", "content": "...", "image": "posts/img.jpg" }

// Convert ke NewsModel:
NewsModel.fromJson(jsonMap) → 
  - Extract fields
  - Build full image URL: baseUrl + image path
  - Return NewsModel object
```

**Penting**: `buildImageUrl()` mengubah relative path menjadi full URL

---

### 7. ERROR HANDLING PATTERN
```dart
try {
  // API call
} on SocketException catch (e) {
  // Network error
} on TimeoutException catch (e) {
  // Timeout error
} catch (e) {
  // Other errors
  setState({ _errorMessage = e.toString() });
}
```

**Status Codes**:
- 200 = Sukses
- 401 = Unauthorized (login ulang)
- 500 = Server error

---

### 8. SINGLETON PATTERN
```dart
class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();
  
  // Cuma ada 1 instance di seluruh app
}
```

**Benefit**: Data shared, efficient, consistent

---

### 9. IMPORTANT LIBRARIES
| Library | Fungsi |
|---------|--------|
| **Dio** | HTTP client dengan interceptor & config |
| **SharedPreferences** | Local storage untuk token |
| **cached_network_image** | Image loading dari URL |
| **image_picker** | Select image dari device |
| **pretty_dio_logger** | Log API requests/responses |

---

### 10. API CONFIG
```dart
// Base URL
baseUrl = 'http://192.168.51.250:18118/api/'

// Endpoints
- /login (POST)
- /logout (POST)
- /user (GET)
- /posts (GET)

// Headers
- Content-Type: application/json
- Accept: application/json
- Authorization: Bearer {token} (setelah login)
```

---

## 📋 JAWABAN CEPAT (5 DETIK)

### Q: "Gimana cara login bekerja?"
**A**: User input email & password → AuthService kirim ke API → API return token → Token disimpan di SharedPreferences → Diset di Dio header → Navigate ke MainScreen

### Q: "Bagaimana aplikasi tahu user sudah login?"
**A**: Saat startup, cek apakah ada token di SharedPreferences. Ada = sudah login, langsung ke MainScreen. Tidak ada = belum login, ke LoginScreen.

### Q: "Gimana posts bisa ditampilkan?"
**A**: Saat PostsBody dibuka, initState() memanggil _fetchNewsFromApi() → GET request ke /posts dengan token → Parse response ke NewsModel list → setState() trigger rebuild → ListView tampilkan posts

### Q: "Apa itu Authorization header?"
**A**: Header HTTP yang isinya token JWT. Format: `Authorization: Bearer {token}`. Digunakan untuk autentikasi setiap request ke API.

### Q: "Kenapa pakai token?"
**A**: Token adalah bukti bahwa user sudah login. Setiap request ke endpoint yang protected harus kirim token. API verify token sebelum return data.

### Q: "Gimana handle error?"
**A**: try-catch block. Check response statusCode (200 = ok, 401 = unauthorized, 500 = server error). If error → setState dengan error message → UI tampilkan ke user.

### Q: "Apa itu SharedPreferences?"
**A**: Local storage di device. Menyimpan data key-value sederhana. Digunakan untuk simpan token sehingga user tidak perlu login lagi setelah app ditutup.

### Q: "Apa itu Singleton?"
**A**: Design pattern yang ensure hanya ada 1 instance class di seluruh aplikasi. Di AuthService & ApiService, ini berguna agar data/config shared di semua tempat.

### Q: "Kenapa pakai Dio instead of http?"
**A**: Dio lebih powerful. Support interceptor (untuk logging), custom headers, base URL, timeout config, dan error handling yang lebih baik.

### Q: "Gimana handle response format berbeda dari API?"
**A**: Cek apakah response adalah List atau Map. Jika List langsung → map. Jika Map → extract dari response['data']. Flexible parsing untuk compatibility.

---

## 🔍 DEBUGGING TIPS

### Masalah: Login gagal
- ✓ Check credential benar?
- ✓ Laravel backend running?
- ✓ Network bisa reach API URL?
- ✓ Check error message dari API

### Masalah: Posts tidak muncul
- ✓ Sudah login? (ada token?)
- ✓ Token masih valid?
- ✓ API endpoint `/posts` ada?
- ✓ Response format correct?
- ✓ Check error message di try-catch

### Masalah: Image tidak muncul
- ✓ Image URL built correctly?
- ✓ Cek di logs: URL lengkap berapa?
- ✓ Image file ada di server?
- ✓ CachedNetworkImage perlu internet permission

### Debugging Tools
```dart
// Log request/response (sudah set up di ApiService)
PrettyDioLogger(
  requestBody: true,
  responseBody: true,
  error: true,
);

// Check token di SharedPreferences
final token = await SharedPreferences.getInstance()
  .getString('auth_token');
print('Token: $token');

// Check response di Dio call
print('Status: ${response.statusCode}');
print('Data: ${response.data}');
```

---

## 🎓 PRESENTASI STRUCTURE

### Opening (1 menit)
- "Ini Admin Dashboard untuk Study Club"
- "Ada 2 fitur main: Login dari API & View Posts"
- "Pakai Flutter + Laravel"

### Technical Explanation (5 menit)
1. **Architecture** (3 layers: UI, Service, API)
2. **Login Flow** (draw atau explain)
3. **Posts Fetching** (draw atau explain)
4. **Token Management** (why & how)

### Demo (3 menit)
- Login dengan credential
- Show posts page
- Show filtering & searching

### Q&A (prepared)
- 17 pertanyaan di PANDUAN_UJI_KOMPETENSI.md
- 10 quick answer di file ini

---

## 📝 FILE STRUCTURE REMINDER

```
lib/
├── main.dart (Entry point, startup logic)
├── services/
│   ├── auth_service.dart (Login, logout, token)
│   └── api_service.dart (Dio config, HTTP methods)
├── screens/
│   ├── login_screen.dart (Login UI)
│   └── posts_body.dart (Posts display)
├── models/
│   └── app_models.dart (Data models)
└── constants/
    └── api_constants.dart (API URLs, endpoints)
```

---

## 💪 CONFIDENCE BOOSTERS

**Remember**:
- ✅ Kamu paham flow dari awal hingga akhir
- ✅ Kamu tahu alasan kenapa setiap library dipilih
- ✅ Kamu siap jawab tech questions
- ✅ Kamu bisa demo aplikasi
- ✅ Kamu punya comprehensive guide di file PANDUAN_UJI_KOMPETENSI.md

**Saat nervous**:
- Ambil napas dalam 3x
- Visualisasikan flow di kepala
- Jelaskan dengan calm & methodical
- Jangan takut bilang "Baik pertanyaan bagus, let me think..."
- Boleh referensi kode di laptop jika perlu

---

**Kamu pasti bisa! Good luck bro! 🚀🔥**
