import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';

import '../providers/user_provider.dart';
import '../services/api_service.dart';

const Color kBlueBrand = Color(0xFF3B9AC4);

class DetailPage extends StatefulWidget {
  final Map<String, dynamic> initialDestinationData;

  const DetailPage({Key? key, required this.initialDestinationData}) : super(key: key);

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  late Map<String, dynamic> _currentDestinationData;
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _timer;

  bool _isBookmarked = false;
  bool _isLoadingBookmark = true;

  @override
  void initState() {
    super.initState();
    _currentDestinationData = Map<String, dynamic>.from(widget.initialDestinationData);
    _initializePage();
  }

  void _initializePage() {
    final List<String> imageUrls = (_currentDestinationData['imageUrls'] as List<dynamic>?)
        ?.map((e) => e.toString())
        .toList() ?? [];
    if (imageUrls.length > 1) {
      _startTimer(imageUrls.length);
    }
    _pageController.addListener(() {
      if (!mounted) return;
      final newPage = _pageController.page?.round();
      if (newPage != null && newPage != _currentPage) {
        setState(() {
          _currentPage = newPage;
        });
      }
    });
    _checkBookmarkStatus();
  }

  Future<void> _checkBookmarkStatus() async {
    final user = Provider.of<UserProvider>(context, listen: false).user;
    if (user == null) {
      setState(() => _isLoadingBookmark = false);
      return;
    }
    try {
      final status = await ApiService.checkBookmarkStatus(
        destinationId: _currentDestinationData['id'].toString(),
        userId: user.id.toString(),
      );
      if (mounted) {
        setState(() {
          _isBookmarked = status;
          _isLoadingBookmark = false;
        });
      }
    } catch (e) {
      print("Gagal memeriksa status bookmark: $e");
      if (mounted) setState(() => _isLoadingBookmark = false);
    }
  }

  Future<void> _toggleBookmark() async {
    final user = Provider.of<UserProvider>(context, listen: false).user;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Anda harus login untuk bookmark.")));
      return;
    }

    setState(() {
      _isBookmarked = !_isBookmarked;
    });

    try {
      await ApiService.toggleBookmark(
        destinationId: _currentDestinationData['id'].toString(),
        userId: user.id.toString(),
      );
    } catch (e) {
      setState(() {
        _isBookmarked = !_isBookmarked;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Gagal mengubah bookmark: $e")));
    }
  }

  void _startTimer(int numPages) {
    _timer = Timer.periodic(const Duration(seconds: 5), (Timer timer) {
      if (!mounted) return;
      int nextPage = _currentPage + 1;
      if (nextPage >= numPages) {
        nextPage = 0;
      }
      if (_pageController.hasClients) {
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  String _formatPrice(dynamic price) {
    if (price == null) return 'Harga tidak tersedia';
    final numberFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    if (price is String) {
      final parsedPrice = int.tryParse(price);
      return parsedPrice != null ? numberFormat.format(parsedPrice) : 'Harga tidak valid';
    } else if (price is num) {
      return numberFormat.format(price);
    }
    return 'Format harga tidak dikenal';
  }

  Future<void> _launchMapsUrl(String address) async {
    final String query = Uri.encodeComponent(address);
    final Uri googleMapsUrl = Uri.parse('https://www.google.com/maps/search/?api=1&query=$query');
    try {
      if (await canLaunchUrl(googleMapsUrl)) {
        await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication);
      } else {
        throw 'Tidak dapat membuka aplikasi peta.';
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Tidak dapat membuka peta: $e')),
        );
      }
    }
  }

  Widget _buildPageIndicator(int numPages) {
    List<Widget> list = [];
    for (int i = 0; i < numPages; i++) {
      list.add(i == _currentPage ? _indicator(true) : _indicator(false));
    }
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: list);
  }

  Widget _indicator(bool isActive) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      margin: const EdgeInsets.symmetric(horizontal: 4.0),
      height: 8.0,
      width: isActive ? 24.0 : 8.0,
      decoration: BoxDecoration(
        color: isActive ? kBlueBrand : Colors.grey[400],
        borderRadius: const BorderRadius.all(Radius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String name = _currentDestinationData['name'] as String? ?? 'Nama Tidak Tersedia';
    String location = _currentDestinationData['location'] as String? ?? 'Lokasi Tidak Tersedia';
    String description = _currentDestinationData['description'] as String? ?? 'Deskripsi Tidak Tersedia';
    String time = _currentDestinationData['Time'] as String? ?? 'Waktu Tidak Tersedia';
    dynamic price = _currentDestinationData['price'];

    final List<String> imageUrls = (_currentDestinationData['imageUrls'] as List<dynamic>?)
        ?.map((e) => e.toString())
        .toList() ?? [];

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FA),
      appBar: AppBar(
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: kBlueBrand,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.of(context).pop(),
          color: kBlueBrand,
        ),
        actions: [
          _isLoadingBookmark
              ? const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: kBlueBrand)),
                )
              : IconButton(
                  icon: Icon(
                    _isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_outline_rounded,
                    color: _isBookmarked ? kBlueBrand : Colors.grey[700],
                  ),
                  tooltip: 'Bookmark',
                  onPressed: _toggleBookmark,
                ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Gambar Destinasi
            ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
              child: imageUrls.isNotEmpty
                  ? Stack(
                      alignment: Alignment.bottomCenter,
                      children: [
                        SizedBox(
                          height: 260,
                          child: PageView.builder(
                            controller: _pageController,
                            itemCount: imageUrls.length,
                            itemBuilder: (context, index) {
                              return Image.network(
                                imageUrls[index],
                                width: double.infinity,
                                height: 260,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => Container(
                                  color: Colors.grey[200],
                                  child: const Icon(Icons.broken_image, color: kBlueBrand, size: 60),
                                ),
                                loadingBuilder: (context, child, loading) =>
                                    loading == null
                                        ? child
                                        : SizedBox(
                                            width: double.infinity,
                                            height: 260,
                                            child: Center(
                                              child: CircularProgressIndicator(color: kBlueBrand),
                                            ),
                                          ),
                              );
                            },
                          ),
                        ),
                        if (imageUrls.length > 1)
                          Positioned(
                            bottom: 14.0,
                            child: _buildPageIndicator(imageUrls.length),
                          ),
                      ],
                    )
                  : Container(
                      width: double.infinity,
                      height: 260,
                      color: Colors.grey[200],
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.image_not_supported_outlined, color: kBlueBrand, size: 60),
                          const SizedBox(height: 8),
                          Text("Tidak ada gambar tersedia", style: TextStyle(color: kBlueBrand)),
                        ],
                      ),
                    ),
            ),

            // Card Konten Detail
            Card(
              margin: const EdgeInsets.fromLTRB(14, 18, 14, 16),
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 22, 20, 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: kBlueBrand,
                          ),
                    ),
                    const SizedBox(height: 12),
                    _buildDetailRow(context, Icons.location_on_rounded, "Lokasi", location),
                    _buildDetailRow(context, Icons.access_time, "Waktu Buka", time),
                    _buildDetailRow(context, Icons.payments_outlined, "Harga Tiket", _formatPrice(price)),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.map_outlined),
                        label: const Text('Lihat di Peta'),
                        onPressed: () => _launchMapsUrl(location),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kBlueBrand,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text("Deskripsi",
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700, color: Colors.grey[900])),
                    const SizedBox(height: 6),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.grey[700], height: 1.5),
                      textAlign: TextAlign.justify,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              color: kBlueBrand.withOpacity(0.09),
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.all(7),
            child: Icon(icon, color: kBlueBrand, size: 21),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[600])),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w500,
                        height: 1.45,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
