# 🎨 Flow Diagram & Visualisasi

## 1️⃣ FLOW LOGIN LENGKAP

```
┌─────────────────────────────────────────────────────────────────┐
│                    FLOW LOGIN APLIKASI                          │
└─────────────────────────────────────────────────────────────────┘

1. USER INPUT STAGE
   ┌──────────────────┐
   │  LoginScreen UI  │ ← User input email & password
   └────────┬─────────┘
            │ User click "Login"
            ▼
   
2. VALIDATION STAGE
   ┌──────────────────┐
   │ Validasi input   │ ← Check email & password tidak kosong
   │ tidak kosong?    │
   └────────┬─────────┘
            │ ✓ Valid
            ▼
   
3. API CALL STAGE
   ┌──────────────────────────────────────┐
   │  _authService.login(email, password) │
   │                                      │
   │  AuthService → ApiService.post()     │
   │                                      │
   │  Kirim: POST /login                  │
   │  Data: { email, password }           │
   │  To: http://192.168.51.250:18118/api/│
   └────────┬─────────────────────────────┘
            │
            ▼
   
4. BACKEND RESPONSE STAGE
   ┌─────────────────────────────┐
   │   Laravel API Response      │
   │                             │
   │ Status 200: OK              │
   │ {                           │
   │   "data": {                 │
   │     "access_token": "xxxx", │
   │     "user": {...}           │
   │   }                         │
   │ }                           │
   └────────┬────────────────────┘
            │
            ▼
   
5. TOKEN SAVE STAGE
   ┌──────────────────────────────┐
   │ Extract token dari response  │
   │ token = payload.access_token │
   │                              │
   │ Simpan ke SharedPreferences: │
   │ SharedPreferences            │
   │   .setString('auth_token',   │
   │      token)                  │
   └────────┬─────────────────────┘
            │
            ▼
   
6. DIO HEADER STAGE
   ┌────────────────────────────────────┐
   │ Set Authorization header di Dio    │
   │                                    │
   │ _dio.options.headers[              │
   │   'Authorization'                  │
   │ ] = 'Bearer $token'                │
   │                                    │
   │ (Semua request berikutnya pakai    │
   │  header ini otomatis)              │
   └────────┬───────────────────────────┘
            │
            ▼
   
7. NAVIGATION STAGE
   ┌──────────────────────────────┐
   │ Navigator.pushReplacement()  │
   │ → MainScreen                 │
   │                              │
   │ (LoginScreen dihapus dari    │
   │  stack, tidak bisa back)     │
   └────────┬─────────────────────┘
            │
            ▼
   
8. SUCCESS
   ┌──────────────────┐
   │  MainScreen      │ ← User bisa lihat dashboard & posts
   └──────────────────┘


ERROR FLOW:
   
   Jika email/password salah:
   API return Status 401
   ↓
   AuthService return { success: false, message: "..." }
   ↓
   LoginScreen tampilkan error message
   ↓
   User tetap di LoginScreen bisa retry
```

---

## 2️⃣ FLOW FETCH POSTS/BERITA

```
┌──────────────────────────────────────────────────────┐
│        FLOW FETCH & DISPLAY POSTS                    │
└──────────────────────────────────────────────────────┘

1. PAGE OPEN
   ┌─────────────────┐
   │ PostsBody page  │
   │ di-open/di-tap  │
   └────────┬────────┘
            │
            ▼
   
2. INITSTATE
   ┌──────────────────────┐
   │ @override            │
   │ void initState() {   │
   │   _fetchNewsFromApi()│ ← Call fetch function
   │ }                    │
   └────────┬─────────────┘
            │
            ▼
   
3. SET LOADING STATE
   ┌──────────────────┐
   │ setState(() {    │
   │   _isLoading =   │
   │     true         │
   │ });              │
   └────────┬─────────┘
            │ (UI show CircularProgressIndicator)
            ▼
   
4. API REQUEST
   ┌──────────────────────────────────────┐
   │ ApiService.get('/posts')             │
   │                                      │
   │ Request: GET /posts                  │
   │ Header: Authorization: Bearer $token │
   │ (Token dari SharedPreferences)       │
   └────────┬─────────────────────────────┘
            │
            ▼
   
5. BACKEND RESPONSE
   ┌─────────────────────────────────────────┐
   │ Laravel API return posts data           │
   │                                         │
   │ Format 1 (Array):                       │
   │ [                                       │
   │   {                                     │
   │     "id": 1,                            │
   │     "title": "Berita 1",                │
   │     "content": "...",                   │
   │     "image": "posts/img1.jpg"           │
   │   }, ...                                │
   │ ]                                       │
   │                                         │
   │ atau Format 2 (Wrapped):                │
   │ {                                       │
   │   "data": [...]                         │
   │ }                                       │
   └────────┬────────────────────────────────┘
            │
            ▼
   
6. PARSE RESPONSE
   ┌──────────────────────────────────────┐
   │ Check response.statusCode == 200?    │
   │                                      │
   │ if data is List:                     │
   │   Map langsung                       │
   │ else if data['data'] exists:         │
   │   Map dari data['data']              │
   │                                      │
   │ newsList = response.data.map((item)  │
   │   => NewsModel.fromJson(item)        │
   │ ).toList()                           │
   └────────┬─────────────────────────────┘
            │
            ▼
   
7. CONVERT JSON TO MODEL
   ┌───────────────────────────────────────┐
   │ NewsModel.fromJson(Map<String, ...>)  │
   │                                       │
   │ id: json['id'].toString()             │
   │ title: json['title'] ?? ''            │
   │ content: json['content'] ?? ''        │
   │ image: buildImageUrl(json['image'])   │
   │   ↓                                   │
   │   Jika relative path:                 │
   │   Gabung dengan ApiConstants.baseUrl  │
   │   http://ip:port/api/ + posts/img.jpg │
   │                                       │
   │ newsModel = NewsModel(...)            │
   └────────┬────────────────────────────────┘
            │
            ▼
   
8. UPDATE UI STATE
   ┌──────────────────────────────────────┐
   │ setState(() {                        │
   │   _newsItems = newsList              │
   │   _isLoading = false                 │
   │   _errorMessage = null               │
   │ });                                  │
   └────────┬─────────────────────────────┘
            │ Trigger rebuild widget
            ▼
   
9. BUILD LISTVIEW
   ┌──────────────────────────────────────┐
   │ Widget build() {                     │
   │   if (_isLoading)                    │
   │     return CircularProgressIndicator │
   │                                      │
   │   if (_errorMessage != null)         │
   │     return ErrorWidget()              │
   │                                      │
   │   return ListView.builder(           │
   │     itemCount: _newsItems.length,    │
   │     itemBuilder: (ctx, idx) =>       │
   │       PostCard(_newsItems[idx])      │
   │   );                                 │
   │ }                                    │
   └────────┬─────────────────────────────┘
            │
            ▼
   
10. DISPLAY
    ┌──────────────────────────────────┐
    │ ┌─ Post 1 ─────────────────────┐ │
    │ │ [Image] Berita 1             │ │
    │ │ Category: Pengumuman          │ │
    │ │ Author: Admin                 │ │
    │ │ Date: 2024-05-17              │ │
    │ └──────────────────────────────┘ │
    │ ┌─ Post 2 ─────────────────────┐ │
    │ │ [Image] Berita 2             │ │
    │ │ Category: Kegiatan            │ │
    │ │ Author: Admin                 │ │
    │ │ Date: 2024-05-16              │ │
    │ └──────────────────────────────┘ │
    │ ┌─ Post 3 ─────────────────────┐ │
    │ │ [Image] Berita 3             │ │
    │ │ Category: Update              │ │
    │ │ Author: Admin                 │ │
    │ │ Date: 2024-05-15              │ │
    │ └──────────────────────────────┘ │
    └──────────────────────────────────┘


ERROR FLOW:

   API Error:
   Status != 200
   ↓
   setState({ _errorMessage = "Gagal memuat data" })
   ↓
   UI show error message
   ↓
   User bisa refresh/retry
   
   Network Error:
   Exception thrown
   ↓
   catch (e)
   ↓
   setState({ _errorMessage = 'Error: $e' })
   ↓
   UI show error
```

---

## 3️⃣ CLASS DIAGRAM

```
┌────────────────────────────────────────────────────────┐
│                    ARCHITECTURE                        │
└────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────┐
│              UI LAYER                   │
│  ┌──────────────────────────────────┐  │
│  │  LoginScreen                     │  │
│  │  - email input                   │  │
│  │  - password input                │  │
│  │  - _handleLogin()                │  │
│  └──────────┬───────────────────────┘  │
│             │ calls                     │
│             ▼                           │
│  ┌──────────────────────────────────┐  │
│  │  PostsBody / MaterialsBody       │  │
│  │  - _fetchNewsFromApi()           │  │
│  │  - _filtered getter              │  │
│  │  - _categories getter            │  │
│  └──────────┬───────────────────────┘  │
│             │ uses                      │
└─────────────┼──────────────────────────┘
              │
              ▼
┌─────────────────────────────────────────┐
│           SERVICE LAYER                 │
│  ┌──────────────────────────────────┐  │
│  │  AuthService (Singleton)         │  │
│  │  - login(email, password)        │  │
│  │  - logout()                      │  │
│  │  - isLoggedIn()                  │  │
│  │  - getToken()                    │  │
│  │  - _saveToken()                  │  │
│  │  - _getToken()                   │  │
│  └──────────┬───────────────────────┘  │
│             │ uses                      │
│             ▼                           │
│  ┌──────────────────────────────────┐  │
│  │  ApiService (Singleton)          │  │
│  │  - post(endpoint, data)          │  │
│  │  - get(endpoint)                 │  │
│  │  - setToken(token)               │  │
│  │  - removeToken()                 │  │
│  │  - _dio (Dio instance)           │  │
│  └──────────┬───────────────────────┘  │
│             │ uses                      │
└─────────────┼──────────────────────────┘
              │
              ▼
┌─────────────────────────────────────────┐
│         HTTP CLIENT LAYER               │
│  ┌──────────────────────────────────┐  │
│  │  Dio HTTP Client                 │  │
│  │  - baseUrl                       │  │
│  │  - headers (+ Authorization)     │  │
│  │  - timeout config                │  │
│  │  - interceptors (logger)         │  │
│  └──────────┬───────────────────────┘  │
│             │ sends request             │
└─────────────┼──────────────────────────┘
              │
              ▼
┌─────────────────────────────────────────┐
│         STORAGE LAYER                   │
│  ┌──────────────────────────────────┐  │
│  │  SharedPreferences               │  │
│  │  - 'auth_token' → JWT token      │  │
│  │  - 'isLoggedIn' → bool           │  │
│  │  - 'study_club_id' → int         │  │
│  └──────────────────────────────────┘  │
└─────────────────────────────────────────┘
              │
              ▼ (during startup)
        main() function
        └─ Check isLoggedIn
           ├─ true  → MainScreen
           └─ false → LoginScreen


┌─────────────────────────────────────────┐
│         REMOTE LAYER                    │
│  ┌──────────────────────────────────┐  │
│  │  Laravel Backend API             │  │
│  │  - POST /login                   │  │
│  │  - POST /logout                  │  │
│  │  - GET /user                     │  │
│  │  - GET /posts                    │  │
│  │                                  │  │
│  │  IP: 192.168.51.250:18118/api/  │  │
│  └──────────────────────────────────┘  │
└─────────────────────────────────────────┘
```

---

## 4️⃣ DATA FLOW: LOGIN REQUEST

```
┌────────────────────────────────────────────────────┐
│   DETAILED LOGIN DATA FLOW                         │
└────────────────────────────────────────────────────┘

INPUT:
  email: "admin@example.com"
  password: "password123"
         │
         ▼
    ┌────────────────────────────┐
    │ AuthService.login()        │
    │ Receive:                   │
    │ - email                    │
    │ - password                 │
    └────────────┬───────────────┘
                 │
                 ▼ (Format request)
    ┌────────────────────────────┐
    │ Create RequestBody         │
    │ {                          │
    │   "email": "admin@...com", │
    │   "password": "pass123"    │
    │ }                          │
    └────────────┬───────────────┘
                 │
                 ▼ (Call ApiService)
    ┌────────────────────────────────────────────┐
    │ ApiService.post('/login', requestBody)     │
    │                                            │
    │ Dio Configuration:                         │
    │ - baseUrl: http://192.168.51.250:18118/api/│
    │ - endpoint: /login                         │
    │ - Full URL: http://...../api/login         │
    │                                            │
    │ Headers:                                   │
    │ - Content-Type: application/json           │
    │ - Accept: application/json                 │
    │                                            │
    │ Body: { email, password }                  │
    └────────────┬─────────────────────────────────┘
                 │
                 ▼ (HTTP POST)
    
    ════════════════════════════════════════════
         OVER THE NETWORK
    ════════════════════════════════════════════
    
                 │
                 ▼ (Laravel Backend)
    ┌────────────────────────────────────────────┐
    │ Route::post('/login', LoginController@)    │
    │                                            │
    │ 1. Validate email & password               │
    │ 2. Find user di database                   │
    │ 3. Verify password (hash)                  │
    │ 4. Create JWT token                        │
    │ 5. Return token + user data                │
    └────────────┬─────────────────────────────────┘
                 │
                 ▼ (Response)
    ┌────────────────────────────────────────────┐
    │ HTTP 200 OK                                │
    │ {                                          │
    │   "data": {                                │
    │     "access_token": "eyJhbGciOiJIUzI1NiIs │
    │                     ...(long token)...     │
    │     ",                                     │
    │     "token_type": "Bearer",                │
    │     "user": {                              │
    │       "id": 1,                             │
    │       "email": "admin@example.com",        │
    │       "name": "Admin User",                │
    │       "study_club_id": 1                   │
    │     }                                      │
    │   }                                        │
    │ }                                          │
    └────────────┬─────────────────────────────────┘
                 │
                 ▼ (Response received by Dio)
    ┌────────────────────────────────────────────┐
    │ Response object:                           │
    │ - statusCode: 200                          │
    │ - data: {...} (parsed JSON)                │
    │ - headers: {...}                           │
    └────────────┬─────────────────────────────────┘
                 │
                 ▼ (Parse in AuthService)
    ┌────────────────────────────────────────────┐
    │ Extract token:                             │
    │ token = response.data['data']['access...'] │
    │                                            │
    │ Extract user:                              │
    │ user = response.data['data']['user']       │
    │                                            │
    │ Validate:                                  │
    │ if (token == null || token.isEmpty)       │
    │   return error                             │
    └────────────┬─────────────────────────────────┘
                 │
                 ▼ (Save token)
    ┌────────────────────────────────────────────┐
    │ SharedPreferences.setString(                │
    │   'auth_token',                            │
    │   'eyJhbGc...'  (the token)                │
    │ )                                          │
    │                                            │
    │ Save ke device local storage ✓             │
    └────────────┬─────────────────────────────────┘
                 │
                 ▼ (Set Dio header)
    ┌────────────────────────────────────────────┐
    │ _dio.options.headers['Authorization']      │
    │   = 'Bearer eyJhbGc...'                    │
    │                                            │
    │ ✓ Semua request ke API sekarang akan       │
    │   include Authorization header             │
    └────────────┬─────────────────────────────────┘
                 │
                 ▼ (Return success)
    ┌────────────────────────────────────────────┐
    │ return {                                   │
    │   'success': true,                         │
    │   'user': {id, email, name, ...}           │
    │ }                                          │
    └────────────┬─────────────────────────────────┘
                 │
                 ▼ (Handle in LoginScreen)
    ┌────────────────────────────────────────────┐
    │ if (result['success']) {                   │
    │   Navigator.pushReplacement(               │
    │     context,                               │
    │     MaterialPageRoute(                      │
    │       builder: (_) => MainScreen()          │
    │     )                                       │
    │   );                                       │
    │ }                                          │
    └────────────┬─────────────────────────────────┘
                 │
                 ▼
    ┌────────────────────────────────────────────┐
    │ ✓ LOGGED IN SUCCESSFULLY                   │
    │ ✓ Token saved & ready to use               │
    │ ✓ User at MainScreen                       │
    └────────────────────────────────────────────┘
```

---

## 5️⃣ DATA FLOW: FETCH POSTS REQUEST

```
┌────────────────────────────────────────────────────┐
│   DETAILED FETCH POSTS DATA FLOW                   │
└────────────────────────────────────────────────────┘

START:
  PostsBody widget opened
         │
         ▼
    ┌────────────────────────┐
    │ initState() called      │
    │ _fetchNewsFromApi()     │
    └────────────┬────────────┘
                 │
                 ▼ (Set loading)
    ┌────────────────────────────────────┐
    │ setState(() {                      │
    │   _isLoading = true                │
    │ });                                │
    │                                    │
    │ ✓ UI shows loading spinner         │
    └────────────┬──────────────────────────┘
                 │
                 ▼ (Call API)
    ┌────────────────────────────────────────────────┐
    │ ApiService().get(ApiConstants.post)            │
    │                                                │
    │ ApiConstants.post = 'posts'                    │
    │ Full endpoint: /posts                          │
    │                                                │
    │ GET Request:                                   │
    │ URL: http://192.168.51.250:18118/api/posts    │
    │                                                │
    │ Headers:                                       │
    │ - Accept: application/json                     │
    │ - Content-Type: application/json               │
    │ - Authorization: Bearer eyJhbGc... (token)     │
    │   ↑ (dari Dio config setelah login)            │
    └────────────┬─────────────────────────────────────┘
                 │
                 ▼ (Send request)
    
    ════════════════════════════════════════════
         OVER THE NETWORK (GET /posts)
    ════════════════════════════════════════════
    
                 │
                 ▼ (Laravel Backend)
    ┌────────────────────────────────────────────┐
    │ Route::get('/posts', PostController@index) │
    │                                            │
    │ 1. Verify token is valid                   │
    │ 2. Get posts from database                 │
    │ 3. Format response                         │
    │ 4. Return posts                            │
    └────────────┬─────────────────────────────────┘
                 │
                 ▼ (Response)
    ┌────────────────────────────────────────────┐
    │ HTTP 200 OK                                │
    │ [                                          │
    │   {                                        │
    │     "id": 1,                               │
    │     "title": "Pengumuman OSIS 2024",       │
    │     "content": "<p>Berita penting...</p>",│
    │     "category": "Pengumuman",              │
    │     "author": "Admin",                     │
    │     "date": "2024-05-17T10:30:00",         │
    │     "image": "posts/news1.jpg"             │
    │   },                                       │
    │   {                                        │
    │     "id": 2,                               │
    │     "title": "Event Tahunan",              │
    │     "content": "<p>Event akan diadakan...", │
    │     "category": "Event",                   │
    │     "author": "Admin",                     │
    │     "date": "2024-05-16T09:15:00",         │
    │     "image": "posts/event1.jpg"            │
    │   },                                       │
    │   ...                                      │
    │ ]                                          │
    └────────────┬─────────────────────────────────┘
                 │
                 ▼ (Parse in _fetchNewsFromApi)
    ┌────────────────────────────────────────────┐
    │ response.statusCode == 200? ✓              │
    │                                            │
    │ var data = response.data                   │
    │                                            │
    │ // Cek format response                     │
    │ if (data is List) {                        │
    │   // Format: [...]                         │
    │   newsList = data.map(...)                 │
    │ } else if (data is Map &&                  │
    │            data['data'] != null) {         │
    │   // Format: { "data": [...] }             │
    │   newsList = data['data'].map(...)         │
    │ }                                          │
    └────────────┬─────────────────────────────────┘
                 │
                 ▼ (Convert to NewsModel)
    ┌────────────────────────────────────────────┐
    │ newsList = data.map((item) {               │
    │   return NewsModel.fromJson(item);         │
    │ }).toList();                               │
    │                                            │
    │ For each item:                             │
    │ NewsModel(                                 │
    │   id: '1',                                 │
    │   title: 'Pengumuman OSIS 2024',           │
    │   content: '<p>Berita penting...</p>',     │
    │   category: 'Pengumuman',                  │
    │   author: 'Admin',                         │
    │   date: '2024-05-17T10:30:00',             │
    │   imageUrl: buildImageUrl('posts/news..') │
    │            ↓                               │
    │     = 'http://192...api/posts/news1.jpg'  │
    │ )                                          │
    └────────────┬─────────────────────────────────┘
                 │
                 ▼ (Handle content HTML)
    ┌────────────────────────────────────────────┐
    │ stripHtmlTags() applied when:              │
    │                                            │
    │ Original: '<p>Berita penting...</p>'       │
    │                                            │
    │ Stripped: 'Berita penting...'              │
    │           (untuk search & display)         │
    └────────────┬─────────────────────────────────┘
                 │
                 ▼ (Update state)
    ┌────────────────────────────────────────────┐
    │ setState(() {                              │
    │   _newsItems = newsList;                   │
    │   _isLoading = false;                      │
    │   _errorMessage = null;                    │
    │ });                                        │
    │                                            │
    │ ✓ _newsItems now have all posts            │
    │ ✓ Loading state = false                    │
    │ ✓ Error cleared                            │
    └────────────┬─────────────────────────────────┘
                 │
                 ▼ (Trigger rebuild)
    ┌────────────────────────────────────────────┐
    │ Widget build() re-run                      │
    │                                            │
    │ if (_isLoading) → show spinner             │
    │ else → show ListView                       │
    └────────────┬─────────────────────────────────┘
                 │
                 ▼ (Filter & display)
    ┌────────────────────────────────────────────┐
    │ List<NewsModel> get _filtered {            │
    │   return _newsItems.where((n) {            │
    │     final matchCat =                       │
    │       _selectedCategory == 'All' ||        │
    │       n.category == _selectedCategory;     │
    │                                            │
    │     final matchSearch =                    │
    │       n.title.toLowerCase()                │
    │         .contains(_searchQuery) ||         │
    │       stripHtmlTags(n.content)             │
    │         .contains(_searchQuery);           │
    │                                            │
    │     return matchCat && matchSearch;        │
    │   }).toList();                             │
    │ }                                          │
    │                                            │
    │ Display _filtered dalam ListView           │
    └────────────┬─────────────────────────────────┘
                 │
                 ▼
    ┌────────────────────────────────────────────┐
    │ ✓ POSTS DISPLAYED SUCCESSFULLY             │
    │                                            │
    │ ┌─ Post Card 1 ──────────────────────────┐│
    │ │ [Image] Pengumuman OSIS 2024             ││
    │ │ Category: Pengumuman | Date: 05-17      ││
    │ │ Author: Admin | Content preview...      ││
    │ └──────────────────────────────────────────┘│
    │ ┌─ Post Card 2 ──────────────────────────┐│
    │ │ [Image] Event Tahunan                    ││
    │ │ Category: Event | Date: 05-16           ││
    │ │ Author: Admin | Content preview...      ││
    │ └──────────────────────────────────────────┘│
    └────────────────────────────────────────────┘
```

---

## 6️⃣ ERROR HANDLING FLOW

```
┌────────────────────────────────────────────────────┐
│   ERROR SCENARIOS & HANDLING                       │
└────────────────────────────────────────────────────┘

ERROR 1: INVALID CREDENTIALS (Login)
┌──────────────────────────────────────┐
│ User input email/password salah      │
└──────────────┬───────────────────────┘
               │
               ▼
┌──────────────────────────────────────┐
│ API return HTTP 401 Unauthorized     │
│ {                                    │
│   "message": "Invalid credentials"   │
│ }                                    │
└──────────────┬───────────────────────┘
               │
               ▼
┌──────────────────────────────────────┐
│ response.statusCode == 200? ✗         │
│                                      │
│ Extract error message dari response  │
│ return {                             │
│   'success': false,                  │
│   'message': 'Invalid credentials'   │
│ }                                    │
└──────────────┬───────────────────────┘
               │
               ▼
┌──────────────────────────────────────┐
│ LoginScreen check:                   │
│ if (result['success']) = false       │
│                                      │
│ setState({                           │
│   _errorMessage = result['message']  │
│ });                                  │
└──────────────┬───────────────────────┘
               │
               ▼
┌──────────────────────────────────────┐
│ UI show error message:               │
│ "Invalid credentials"                │
│                                      │
│ User tetap di LoginScreen            │
│ Bisa coba lagi dengan data yang benar│
└──────────────────────────────────────┘


ERROR 2: NO INTERNET / NETWORK ERROR
┌──────────────────────────────────────┐
│ User offline atau server tidak       │
│ bisa diakses                         │
└──────────────┬───────────────────────┘
               │
               ▼
┌──────────────────────────────────────┐
│ Dio throw SocketException /          │
│ TimeoutException                     │
└──────────────┬───────────────────────┘
               │
               ▼
┌──────────────────────────────────────┐
│ try-catch block catch exception:     │
│                                      │
│ catch (e) {                          │
│   return {                           │
│     'success': false,                │
│     'message': e.toString()          │
│   };                                 │
│ }                                    │
└──────────────┬───────────────────────┘
               │
               ▼
┌──────────────────────────────────────┐
│ UI show error:                       │
│ "SocketException: Unable to connect" │
│ atau "TimeoutException"              │
│                                      │
│ User bisa retry setelah connect      │
└──────────────────────────────────────┘


ERROR 3: TOKEN EXPIRED (Fetch Posts)
┌──────────────────────────────────────┐
│ User login tapi token sudah expired  │
│ saat fetch posts                     │
└──────────────┬───────────────────────┘
               │
               ▼
┌──────────────────────────────────────┐
│ API return HTTP 401 Unauthorized     │
│ "Token expired"                      │
└──────────────┬───────────────────────┘
               │
               ▼
┌──────────────────────────────────────┐
│ ApiService.get() receive 401         │
│                                      │
│ response.statusCode == 200? ✗        │
└──────────────┬───────────────────────┘
               │
               ▼
┌──────────────────────────────────────┐
│ setState({ _errorMessage = "..." })  │
└──────────────┬───────────────────────┘
               │
               ▼
┌──────────────────────────────────────┐
│ UI show error message               │
│ User perlu logout & login ulang      │
│                                      │
│ (Di production bisa auto-logout)     │
└──────────────────────────────────────┘


ERROR 4: SERVER ERROR (500)
┌──────────────────────────────────────┐
│ Laravel backend error                │
└──────────────┬───────────────────────┘
               │
               ▼
┌──────────────────────────────────────┐
│ API return HTTP 500 Internal Error   │
└──────────────┬───────────────────────┘
               │
               ▼
┌──────────────────────────────────────┐
│ response.statusCode >= 500? ✓         │
│                                      │
│ setState({                           │
│   _errorMessage =                    │
│     'Gagal memuat data / server error'│
│ });                                  │
└──────────────┬───────────────────────┘
               │
               ▼
┌──────────────────────────────────────┐
│ UI show generic error message        │
│ User bisa retry nanti                │
└──────────────────────────────────────┘


GENERAL ERROR HANDLING PATTERN:

try {
  // API call
  final response = await apiService.method();
  
  if (response.statusCode == 200) {
    // SUCCESS - Process data
    setState({ ... });
  } else if (response.statusCode == 401) {
    // UNAUTHORIZED - Token invalid/expired
    // Action: logout, show error
  } else if (response.statusCode >= 500) {
    // SERVER ERROR
    // Action: show generic error
  } else {
    // OTHER ERRORS
    // Action: show error
  }
  
} catch (e) {
  // NETWORK/EXCEPTION ERROR
  // Contoh: TimeoutException, SocketException
  // Action: show error message
  setState({ _errorMessage = 'Error: $e' });
}
```

---

Good luck! 💪💪💪
