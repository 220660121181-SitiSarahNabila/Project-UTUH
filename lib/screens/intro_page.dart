import 'package:flutter/material.dart';
import 'login_page.dart'; 

void main() {
  runApp(const MaterialApp(
    home: IntroPage(),
    debugShowCheckedModeBanner: false,
  ));
}

class IntroPage extends StatelessWidget {
  const IntroPage({Key? key}) : super(key: key);

  static const Color blueColor = Color(0xFF3B9AC4);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Blue area with curved bottom
          ClipPath(
            clipper: BottomCurveClipper(),
            child: Container(
              color: const Color(0xFF3B9AC4),
              height: MediaQuery.of(context).size.height * 0.5,
              alignment: Alignment.center,
              child: SizedBox(
                width: 150,
                height: 150,
                child: Image.asset(
                  'assets/images/logo.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
          const SizedBox(height: 30),
          Text(
            'Hello!',
            style: TextStyle(
              color: blueColor,
              fontFamily: "Poppins",
              fontWeight: FontWeight.w800, // ExtraBold
              fontSize: 24,
            ),
          ),
          const SizedBox(height: 2),
          const Text(
            'Welcome to Ulin Atuh App',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 16,
               fontFamily: "Poppins",
               fontWeight: FontWeight.w600, // SemiBold
            ),
          ),
          const SizedBox(height: 60),
          ElevatedButton(
            onPressed: () {
               Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => const LoginPage()),
  );
},
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3B9AC4),
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 6,
              shadowColor: const Color.fromARGB(255, 255, 255, 255),
            ),
            child: const Text('GET STARTED',
            style: TextStyle(
              color: Color.fromARGB(255, 255, 255, 255),
              fontSize: 16,
              fontFamily: "Poppins",
               fontWeight: FontWeight.w400, // MediumBold
            ),
            ),
            
          ),
          const Spacer(),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}

// Pindahkan kelas ini ke luar IntroPage
class BottomCurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 50);
    path.quadraticBezierTo(
      size.width / 2,
      size.height,
      size.width,
      size.height - 50,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
