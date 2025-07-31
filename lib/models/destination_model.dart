class DestinationModel {
  final int id;
  final String name;
  final String location;
  final String description;
  final List<String> imageUrls; // <-- PERUBAHAN: dari String ke List<String>
  final String time;
  final int price;
  final double rating;

  DestinationModel({
    required this.id,
    required this.name,
    required this.location,
    required this.description,
    required this.imageUrls, // <-- Diperbarui
    required this.time,
    required this.price,
    required this.rating,
  });

  // Helper getter untuk mendapatkan gambar utama/pertama dengan aman
  String get primaryImageUrl {
    if (imageUrls.isNotEmpty) {
      return imageUrls[0]; // Ambil gambar pertama dari list
    }
    // Sediakan URL placeholder jika tidak ada gambar sama sekali
    return 'https://via.placeholder.com/200x150?text=No+Image';
  }

  factory DestinationModel.fromJson(Map<String, dynamic> json) {
    final List<String> images = (json['imageUrls'] as List<dynamic>?)
        ?.map((e) => e.toString())
        .toList() ?? [];

    if (images.isEmpty && json['imageUrl'] != null) {
      images.add(json['imageUrl'] as String);
    }
    
    int parsedPrice;
    if (json['price'] is int) {
      parsedPrice = json['price'];
    } else {
      parsedPrice = int.tryParse(json['price'].toString()) ?? 0;
    }
    
    return DestinationModel(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      location: json['location'] as String? ?? '',
      description: json['description'] as String? ?? '',
      imageUrls: images,
      // --- PERBAIKAN DI SINI: GUNAKAN KEY 'Time' ---
      time: json['Time'] as String? ?? '', // <-- Menggunakan 'T' besar
      // ------------------------------------------
      price: parsedPrice,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'location': location,
      'description': description,
      'imageUrls': imageUrls, // <-- Diperbarui
      'Time': time,
      'price': price,
      'rating': rating,
    };
  }
}