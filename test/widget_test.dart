import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ulin_atuhfront/main.dart';

void main() {
  testWidgets('HomeScreen loads with search bar and posts', (WidgetTester tester) async {
    // Jalankan aplikasi
    await tester.pumpWidget(MyApp());

    // Periksa apakah field pencarian tampil
    expect(find.byType(TextField), findsOneWidget);

    // Periksa apakah ada teks "Hallo, Carmen" di AppBar
    expect(find.text('Hallo, Carmen'), findsOneWidget);

    // Periksa apakah ada postingan dari 'Cameron Williamson'
    expect(find.text('Cameron Williamson'), findsOneWidget);

    // Periksa apakah ada komentar dari Jennie
    expect(find.text('Amazing view from this skywalk!'), findsOneWidget);

    // Periksa apakah ikon tambah tampil (FAB)
    expect(find.byIcon(Icons.add), findsOneWidget);
  });
}
