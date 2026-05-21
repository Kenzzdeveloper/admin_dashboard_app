import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:io';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../constants/api_constants.dart';

// Helper function untuk menghapus HTML tags
String stripHtmlTags(String html) {
  final RegExp exp = RegExp(r"<[^>]*>", multiLine: true, caseSensitive: false);
  String text = html.replaceAll(exp, '');
  // Decode HTML entities
  text = text.replaceAll('&nbsp;', ' ');
  text = text.replaceAll('&amp;', '&');
  text = text.replaceAll('&lt;', '<');
  text = text.replaceAll('&gt;', '>');
  text = text.replaceAll('&quot;', '"');
  text = text.replaceAll('&#039;', "'");
  return text.trim();
}

// Helper function untuk membangun full image URL dari API
String buildImageUrl(String? imagePath) {
  if (imagePath == null || imagePath.isEmpty) {
    return '';
  }

  final trimmed = imagePath.trim();
  if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
    return trimmed;
  }

  String cleanPath = trimmed.replaceFirst(RegExp(r'^/+'), '');
  cleanPath = cleanPath.replaceFirst(RegExp(r'^api/'), '');

  if (cleanPath.startsWith('storage/app/public/')) {
    cleanPath = cleanPath.replaceFirst('storage/app/public/', 'storage/');
  }

  if (cleanPath.startsWith('public/')) {
    cleanPath = cleanPath.replaceFirst('public/', '');
  }

  if (cleanPath.startsWith('posts/')) {
    return _joinUrl(ApiConstants.imageBaseUrl, 'storage/$cleanPath');
  }

  if (cleanPath.startsWith('storage/')) {
    return _joinUrl(ApiConstants.imageBaseUrl, cleanPath);
  }

  return _joinUrl(ApiConstants.imageBaseUrl, cleanPath);
}

String _joinUrl(String base, String path) {
  var cleanedBase = base;
  while (cleanedBase.endsWith('/')) {
    cleanedBase = cleanedBase.substring(0, cleanedBase.length - 1);
  }

  var cleanedPath = path;
  while (cleanedPath.startsWith('/')) {
    cleanedPath = cleanedPath.substring(1);
  }

  return '$cleanedBase/$cleanedPath';
}

class NewsModel {
  final String id;
  final String title;
  final String content;
  final String category;
  final String author;
  final String date;
  final String imageUrl;

  const NewsModel({
    required this.id,
    required this.title,
    required this.content,
    required this.category,
    required this.author,
    required this.date,
    required this.imageUrl,
  });

  factory NewsModel.fromJson(Map<String, dynamic> json) {
    return NewsModel(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      category: json['category'] ?? 'Update',
      author: json['author'] ?? 'Admin',
      date: json['date'] ?? '',
      imageUrl: buildImageUrl(json['image_url']),
    );
  }
}

class MaterialsBody extends StatefulWidget {
  const MaterialsBody({super.key});

  @override
  State<MaterialsBody> createState() => _MaterialsBodyState();
}

class _MaterialsBodyState extends State<MaterialsBody> {
  String _selectedCategory = 'All';
  final _searchController = TextEditingController();
  String _searchQuery = '';
  late List<NewsModel> _newsItems;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _newsItems = [];
    _fetchNewsFromApi();
  }

  Future<void> _fetchNewsFromApi() async {
    try {
      setState(() => _isLoading = true);
      final response = await ApiService().get(ApiConstants.post);

      if (response.statusCode == 200) {
        final data = response.data;
        List<NewsModel> newsList = [];

        if (data is List) {
          newsList = data
              .map((item) => NewsModel.fromJson(item as Map<String, dynamic>))
              .toList();
        } else if (data is Map && data.containsKey('data')) {
          newsList = (data['data'] as List)
              .map((item) => NewsModel.fromJson(item as Map<String, dynamic>))
              .toList();
        }

        setState(() {
          _newsItems = newsList;
          _errorMessage = null;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Gagal memuat data';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<String> get _categories {
    final cats = _newsItems.map((n) => n.category).toSet().toList()..sort();
    return ['All', ...cats];
  }

  List<NewsModel> get _filtered {
    return _newsItems.where((n) {
      final matchCat =
          _selectedCategory == 'All' || n.category == _selectedCategory;
      final matchSearch =
          n.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              stripHtmlTags(n.content)
                  .toLowerCase()
                  .contains(_searchQuery.toLowerCase());
      return matchCat && matchSearch;
    }).toList();
  }

  void _showPostDialog() {
    final titleCtrl = TextEditingController();
    final contentCtrl = TextEditingController();
    String selectedCat = 'Pengumuman';
    File? selectedImageFile;
    String imageLabel = 'Pilih gambar (opsional)';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDState) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Buat Berita',
              style: TextStyle(fontWeight: FontWeight.w700)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _dialogField(titleCtrl, 'Judul Berita', Icons.title_outlined),
                const SizedBox(height: 12),
                _dialogField(contentCtrl, 'Isi Berita', Icons.article_outlined,
                    maxLines: 4),
                const SizedBox(height: 12),
                const Text('Kategori',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF374151))),
                const SizedBox(height: 6),
                _dropdownField(
                  value: selectedCat,
                  items: ['Pengumuman', 'Kegiatan', 'Update', 'Event'],
                  onChanged: (v) => setDState(() => selectedCat = v!),
                ),
                const SizedBox(height: 12),
                // Image preview or picker
                GestureDetector(
                  onTap: () async {
                    final ImagePicker picker = ImagePicker();
                    final XFile? image = await picker.pickImage(
                      source: ImageSource.gallery,
                      maxWidth: 1920,
                      maxHeight: 1080,
                      imageQuality: 80,
                    );

                    if (image != null) {
                      setDState(() {
                        selectedImageFile = File(image.path);
                        imageLabel = image.name;
                      });
                    }
                  },
                  child: selectedImageFile == null
                      ? Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF9FAFB),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color: const Color(0xFFE5E7EB),
                                style: BorderStyle.solid),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.image_outlined,
                                  size: 28, color: Color(0xFF9CA3AF)),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  imageLabel,
                                  style: const TextStyle(
                                      fontSize: 13, color: Color(0xFF6B7280)),
                                ),
                              ),
                            ],
                          ),
                        )
                      : Container(
                          width: double.infinity,
                          height: 150,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color: const Color(0xFF2563EB), width: 2),
                          ),
                          child: Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(selectedImageFile!,
                                    width: double.infinity,
                                    height: 150,
                                    fit: BoxFit.cover),
                              ),
                              Positioned(
                                top: 8,
                                right: 8,
                                child: GestureDetector(
                                  onTap: () =>
                                      setDState(() => selectedImageFile = null),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      borderRadius: BorderRadius.circular(50),
                                    ),
                                    padding: const EdgeInsets.all(4),
                                    child: const Icon(Icons.close,
                                        color: Colors.white, size: 16),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Batal')),
            ElevatedButton(
              onPressed: () async {
                final title = titleCtrl.text.trim();
                final content = contentCtrl.text.trim();
                if (title.isEmpty || content.isEmpty) {
                  return;
                }

                try {
                  // Get study_club_id from AuthService
                  final studyClubId = await AuthService().getStudyClubId();

                  if (studyClubId == null) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content:
                                Text('Error: Study club ID tidak ditemukan')),
                      );
                    }
                    return;
                  }

                  // Use FormData for multipart upload
                  final formData = FormData();
                  formData.fields.add(MapEntry('title', title));
                  formData.fields.add(MapEntry('content', content));
                  formData.fields.add(MapEntry('category', selectedCat));
                  formData.fields
                      .add(MapEntry('study_club_id', studyClubId.toString()));

                  if (selectedImageFile != null) {
                    formData.files.add(
                      MapEntry(
                        'image',
                        MultipartFile.fromFileSync(
                          selectedImageFile!.path,
                          filename: selectedImageFile!.path.split('/').last,
                        ),
                      ),
                    );
                  }

                  await ApiService().post(ApiConstants.post, formData);

                  // Refresh the list setelah berhasil
                  await _fetchNewsFromApi();

                  if (context.mounted) {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Berita berhasil dibuat!')),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Gagal membuat berita: $e')),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Posting'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dialogField(TextEditingController ctrl, String label, IconData icon,
      {int maxLines = 1}) {
    return TextField(
      controller: ctrl,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 18, color: const Color(0xFF9CA3AF)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
    );
  }

  Widget _dropdownField({
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFD1D5DB)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          items: items
              .map((i) => DropdownMenuItem(value: i, child: Text(i)))
              .toList(),
          onChanged: onChanged,
          style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF374151),
              fontWeight: FontWeight.w500),
        ),
      ),
    );
  }

  void _deleteNews(String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Hapus Berita'),
        content: const Text('Yakin ingin menghapus berita ini?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          TextButton(
            onPressed: () async {
              try {
                await ApiService().delete('${ApiConstants.post}/$id');
                // Refresh the list setelah berhasil
                await _fetchNewsFromApi();
                if (context.mounted) {
                  Navigator.pop(ctx);
                }
              } catch (e) {
                if (context.mounted) {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Gagal menghapus berita: $e')),
                  );
                }
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          const Text('Berita',
              style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF111827))),
          const SizedBox(height: 4),
          const Text('Kelola posting berita dan gambar untuk admin.',
              style: TextStyle(fontSize: 14, color: Color(0xFF6B7280))),
          const SizedBox(height: 16),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _showPostDialog,
              icon: const Icon(Icons.post_add_outlined, size: 20),
              label: const Text('Buat Berita',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Error message
          if (_errorMessage != null)
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFFEE2E2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFFECACA)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline,
                      color: Color(0xFFDC2626), size: 18),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(
                        color: Color(0xFFDC2626),
                        fontSize: 13,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: _fetchNewsFromApi,
                    child: const Icon(Icons.refresh,
                        color: Color(0xFFDC2626), size: 18),
                  ),
                ],
              ),
            ),

          // Loading state
          if (_isLoading)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: const CircularProgressIndicator(
                  color: Color(0xFF2563EB),
                ),
              ),
            )
          else ...[
            TextField(
              controller: _searchController,
              onChanged: (v) => setState(() => _searchQuery = v),
              decoration: InputDecoration(
                hintText: 'Cari berita...',
                hintStyle: const TextStyle(color: Color(0xFFD1D5DB)),
                prefixIcon: const Icon(Icons.search,
                    color: Color(0xFF9CA3AF), size: 20),
                suffixIcon: _searchQuery.isNotEmpty
                    ? GestureDetector(
                        onTap: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                        child: const Icon(Icons.close,
                            color: Color(0xFF9CA3AF), size: 18),
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: Color(0xFF2563EB), width: 1.5),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _categories.map((cat) {
                  final isSel = _selectedCategory == cat;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedCategory = cat),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 7),
                        decoration: BoxDecoration(
                          color: isSel ? const Color(0xFF2563EB) : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSel
                                ? const Color(0xFF2563EB)
                                : const Color(0xFFE5E7EB),
                          ),
                        ),
                        child: Text(
                          cat,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color:
                                isSel ? Colors.white : const Color(0xFF6B7280),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 14),
            Text('${_filtered.length} berita ditemukan',
                style: const TextStyle(fontSize: 13, color: Color(0xFF9CA3AF))),
            const SizedBox(height: 10),
            if (_filtered.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: Column(
                    children: [
                      Icon(Icons.article_outlined,
                          size: 56, color: Colors.grey.shade300),
                      const SizedBox(height: 12),
                      Text('Tidak ada berita',
                          style: TextStyle(
                              color: Colors.grey.shade400, fontSize: 15)),
                    ],
                  ),
                ),
              )
            else
              ..._filtered.map((n) => _NewsCard(
                    news: n,
                    onDelete: () => _deleteNews(n.id),
                  )),
          ],
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _NewsCard extends StatefulWidget {
  final NewsModel news;
  final VoidCallback onDelete;

  const _NewsCard({
    required this.news,
    required this.onDelete,
  });

  @override
  State<_NewsCard> createState() => _NewsCardState();
}

class _NewsCardState extends State<_NewsCard> {
  String? _authToken;

  @override
  void initState() {
    super.initState();
    _loadAuthToken();
  }

  Future<void> _loadAuthToken() async {
    final token = await AuthService().getToken();
    if (mounted) {
      setState(() {
        _authToken = token;
      });
    }
  }

  Color _categoryColor(String category) {
    switch (category) {
      case 'Kegiatan':
        return const Color(0xFF2563EB);
      case 'Pengumuman':
        return const Color(0xFF10B981);
      case 'Update':
        return const Color(0xFFF59E0B);
      case 'Event':
        return const Color(0xFF7C3AED);
      default:
        return const Color(0xFF6B7280);
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _categoryColor(widget.news.category);
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => NewsDetailPage(news: widget.news),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.news.imageUrl.isEmpty)
              Container(
                width: double.infinity,
                height: 150,
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: const Icon(Icons.image_outlined,
                    size: 40, color: Color(0xFF9CA3AF)),
              )
            else
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                child: CachedNetworkImage(
                  imageUrl: widget.news.imageUrl,
                  httpHeaders: _authToken != null
                      ? {'Authorization': 'Bearer $_authToken'}
                      : {},
                  width: double.infinity,
                  height: 150,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    width: double.infinity,
                    height: 150,
                    color: Colors.grey.shade200,
                    child: const Center(
                      child: SizedBox(
                        width: 30,
                        height: 30,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    width: double.infinity,
                    height: 150,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F6),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.image_not_supported_outlined,
                            size: 40, color: Color(0xFF9CA3AF)),
                        const SizedBox(height: 8),
                        Text(
                          'Gambar gagal dimuat',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(widget.news.category,
                            style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: color)),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: widget.onDelete,
                        child: const Icon(Icons.delete_outline,
                            color: Color(0xFFEF4444), size: 20),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(widget.news.title,
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF111827))),
                  const SizedBox(height: 8),
                  Text(stripHtmlTags(widget.news.content),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 13, color: Color(0xFF6B7280))),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Text(widget.news.author,
                          style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF374151))),
                      const SizedBox(width: 12),
                      Text(widget.news.date,
                          style: const TextStyle(
                              fontSize: 12, color: Color(0xFF9CA3AF))),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Halaman Detail Berita
class NewsDetailPage extends StatefulWidget {
  final NewsModel news;

  const NewsDetailPage({super.key, required this.news});

  @override
  State<NewsDetailPage> createState() => _NewsDetailPageState();
}

class _NewsDetailPageState extends State<NewsDetailPage> {
  String? _authToken;

  @override
  void initState() {
    super.initState();
    _loadAuthToken();
  }

  Future<void> _loadAuthToken() async {
    final token = await AuthService().getToken();
    if (mounted) {
      setState(() {
        _authToken = token;
      });
    }
  }

  Color _categoryColor(String category) {
    switch (category) {
      case 'Kegiatan':
        return const Color(0xFF2563EB);
      case 'Pengumuman':
        return const Color(0xFF10B981);
      case 'Update':
        return const Color(0xFFF59E0B);
      case 'Event':
        return const Color(0xFF7C3AED);
      default:
        return const Color(0xFF6B7280);
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _categoryColor(widget.news.category);

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: CustomScrollView(
        slivers: [
          // App Bar dengan gambar header
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            backgroundColor: const Color(0xFF2563EB),
            leading: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Color(0xFF111827)),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: widget.news.imageUrl.isEmpty
                  ? Container(
                      color: const Color(0xFF2563EB),
                      child: const Center(
                        child: Icon(Icons.article_outlined,
                            size: 80, color: Colors.white70),
                      ),
                    )
                  : Stack(
                      fit: StackFit.expand,
                      children: [
                        CachedNetworkImage(
                          imageUrl: widget.news.imageUrl,
                          httpHeaders: _authToken != null
                              ? {'Authorization': 'Bearer $_authToken'}
                              : {},
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: Colors.grey.shade300,
                            child: const Center(
                              child: SizedBox(
                                width: 40,
                                height: 40,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: const Color(0xFF2563EB),
                            child: const Center(
                              child: Icon(Icons.article_outlined,
                                  size: 80, color: Colors.white70),
                            ),
                          ),
                        ),
                        // Gradient overlay untuk readability
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withOpacity(0.4),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
          ),
          // Content
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _getCategoryIcon(widget.news.category),
                            size: 16,
                            color: color,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            widget.news.category,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: color,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Title
                    Text(
                      widget.news.title,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF111827),
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Metadata
                    Row(
                      children: [
                        const CircleAvatar(
                          radius: 16,
                          backgroundColor: Color(0xFF2563EB),
                          child:
                              Icon(Icons.person, size: 18, color: Colors.white),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.news.author,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF374151),
                              ),
                            ),
                            Text(
                              widget.news.date,
                              style: const TextStyle(
                                fontSize: 11,
                                color: Color(0xFF9CA3AF),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Divider(color: Color(0xFFE5E7EB)),
                    const SizedBox(height: 24),
                    // Content
                    Text(
                      'Isi Berita',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      stripHtmlTags(widget.news.content),
                      style: const TextStyle(
                        fontSize: 15,
                        color: Color(0xFF374151),
                        height: 1.7,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 40),
                    // Info card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline,
                              color: Color(0xFF6B7280), size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Berita ini dipublikasikan pada ${widget.news.date}',
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF6B7280),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Kegiatan':
        return Icons.event;
      case 'Pengumuman':
        return Icons.campaign;
      case 'Update':
        return Icons.update;
      case 'Event':
        return Icons.celebration;
      default:
        return Icons.article;
    }
  }
}
