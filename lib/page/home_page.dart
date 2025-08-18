import 'package:flutter/material.dart';
import 'package:projectconvert/page/res_page.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image (live flight/runway)
          Positioned.fill(
            child: Image.network(
              "https://cdn.pixabay.com/photo/2022/02/14/12/10/plane-7013022_1280.jpg", // example GIF of plane takeoff
              fit: BoxFit.cover,
            ),
          ),
          // Optional dark overlay for better button visibility
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.3)),
          ),
          // Continue button at bottom center
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(25.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 50,
                    vertical: 15,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => ResultsScreen()),
                  );
                },
                child: const Text(
                  "Continue",
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
