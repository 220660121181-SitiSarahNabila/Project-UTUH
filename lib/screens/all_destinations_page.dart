import 'package:flutter/material.dart';
import '../models/destination_model.dart';
import '../services/api_service.dart';
import 'detail_page.dart';
import '../widgets/destination_card.dart'; // Import widget kartu Anda yang sudah diperbarui

class AllDestinationsPage extends StatefulWidget {
  const AllDestinationsPage({super.key});

  @override
  State<AllDestinationsPage> createState() => _AllDestinationsPageState();
}

class _AllDestinationsPageState extends State<AllDestinationsPage> {
  List<DestinationModel> _allDestinations = [];
  List<DestinationModel> _filteredDestinations = [];
  bool _isLoading = true;
  String _errorMessage = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchData();
    _searchController.addListener(_filterData);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterData);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    try {
      final List<dynamic> responseData = await ApiService.fetchDestinations();
      if (!mounted) return;
      setState(() {
        _allDestinations = responseData.map((data) => DestinationModel.fromJson(data as Map<String, dynamic>)).toList();
        _filteredDestinations = List.from(_allDestinations);
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Gagal memuat data: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  void _filterData() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredDestinations = _allDestinations.where((destination) {
        final name = destination.name.toLowerCase();
        final location = destination.location.toLowerCase();
        return name.contains(query) || location.contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Semua Destinasi'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Cari destinasi...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),
          // Konten Utama (Loading, Error, atau Daftar)
          Expanded(
            child: _buildContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(_errorMessage, textAlign: TextAlign.center),
        ),
      );
    }

    if (_filteredDestinations.isEmpty) {
      return const Center(
        child: Text('Tidak ada destinasi yang ditemukan.'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 16),
      itemCount: _filteredDestinations.length,
      itemBuilder: (context, index) {
        final destination = _filteredDestinations[index];
        // Menggunakan DestinationCard yang sudah ada dari folder widgets
        return DestinationCard(
          destination: destination,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DetailPage(
                  // --- PERBAIKAN DI SINI ---
                  // Mengirim data destinasi menggunakan parameter 'initialDestinationData'
                  // dan mengubah objek Model menjadi Map menggunakan .toJson()
                  initialDestinationData: destination.toJson(),
                ),
              ),
            );
          },
        );
      },
    );
  }
}