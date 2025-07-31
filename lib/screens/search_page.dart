import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../services/api_service.dart';
import 'detail_page.dart'; 

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _results = [];
  bool _isLoading = false;
  String _searchMessage = 'Cari destinasi wisata...';
  bool _isNavigating = false;

  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _results = [];
        _searchMessage = 'Cari destinasi wisata...';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _searchMessage = '';
    });

    try {
      final results = await ApiService.search(query);
      if (!mounted) return;
      setState(() {
        _results = results;
        if (_results.isEmpty) {
          _searchMessage = 'Tidak ada hasil untuk "$query"';
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _searchMessage = 'Gagal melakukan pencarian: ${e.toString()}';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _navigateToDetail(dynamic item) async {
    final String destinationId = item['id'].toString();
    if (destinationId.isEmpty) {
      Fluttertoast.showToast(msg: "ID Destinasi tidak valid.");
      return;
    }

    setState(() { _isNavigating = true; });

    try {
      final fullDestinationData = await ApiService.fetchDestinationById(destinationId);
      
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DetailPage(initialDestinationData: fullDestinationData),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      Fluttertoast.showToast(msg: "Gagal memuat detail: ${e.toString()}");
    } finally {
      if (mounted) {
        setState(() { _isNavigating = false; });
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black54),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Cari nama atau lokasi destinasi...',
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.grey),
          ),
          style: const TextStyle(color: Colors.black87, fontSize: 18),
          onSubmitted: (value) {
            _performSearch(value);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.clear, color: Colors.black54),
            onPressed: () {
              _searchController.clear();
              setState(() {
                _results = [];
                _searchMessage = 'Cari destinasi wisata...';
              });
            },
          )
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_results.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(_searchMessage, style: TextStyle(color: Colors.grey[600]), textAlign: TextAlign.center),
        ),
      );
    }

    return Stack(
      children: [
        ListView.builder(
          padding: const EdgeInsets.all(8.0),
          itemCount: _results.length,
          itemBuilder: (context, index) {
            final item = _results[index];
            final imageUrl = item['imageUrl'] as String?;
            
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 2,
              child: ListTile(
                contentPadding: const EdgeInsets.all(10),
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image.network(
                    imageUrl ?? 'https://via.placeholder.com/80x80?text=No+Image',
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    errorBuilder: (c,e,s) => Container(
                      width: 80, height: 80, color: Colors.grey[200],
                      child: const Icon(Icons.location_on, color: Colors.grey),
                    ),
                  ),
                ),
                title: Text(item['name'] ?? 'Tanpa Nama', style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(item['location'] ?? 'Tanpa Lokasi', maxLines: 2, overflow: TextOverflow.ellipsis),
                onTap: _isNavigating ? null : () => _navigateToDetail(item),
              ),
            );
          },
        ),
        if (_isNavigating)
          Container(
            color: Colors.black.withOpacity(0.3),
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
      ],
    );
  }
}