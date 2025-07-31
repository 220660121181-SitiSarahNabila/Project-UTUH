import 'package:flutter/material.dart';
import '../models/destination_model.dart'; // Pastikan path ini benar

class DestinationCard extends StatelessWidget {
  final DestinationModel destination;
  final VoidCallback onTap; // Callback untuk aksi tap tetap ada

  const DestinationCard({
    super.key, 
    required this.destination,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap, // Gunakan callback onTap yang diberikan
        child: Row(
          children: [
            // Gambar dengan Hero untuk animasi transisi
            Hero(
              tag: 'destinationImage-${destination.id}',
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
                child: Image.network(
                  destination.primaryImageUrl, // Gunakan gambar utama dari model
                  width: 110,
                  height: 110,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 110,
                      height: 110,
                      color: Colors.grey[200],
                      child: Icon(Icons.image_not_supported, color: Colors.grey[400]),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(width: 10),

            // Informasi destinasi
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      destination.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      destination.location,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    
                  ],
                ),
              ),
            ),
            // Tombol hapus dan bagian trailing sudah sepenuhnya dihilangkan
          ],
        ),
      ),
    );
  }
}