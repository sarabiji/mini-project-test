import 'package:flutter/material.dart';
import 'package:snap_chef_5/constants/image_path.dart';
import 'package:snap_chef_5/screens/home.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;

    return Scaffold(
      body: SizedBox(
        width: w,
        height: h,
        child: Stack(
          children: [
            /// Background
            Positioned.fill(child: Container(color: Colors.white)),

            /// Centered Title Image
            Center(
              child: Image.asset(
                ImagesPath.onboardingTitle,
                width: w * 0.8, // Scales responsively
                fit: BoxFit.contain,
              ),
            ),

            /// Bottom Container
            Positioned(
              bottom: 0,
              child: Container(
                height: h * 0.25, // Adjusted for better proportion
                width: w,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(40),
                    topLeft: Radius.circular(40),
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: h * 0.03),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        /// Title
                        Text(
                          'Let\'s cook good food',
                          style: TextStyle(
                            fontSize: w * 0.06,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),

                        SizedBox(height: h * 0.01),

                        /// Subtitle
                        Text(
                          'Check out the app and start cooking delicious meals!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: w * 0.04,
                            fontWeight: FontWeight.w400,
                            color: Colors.black54,
                          ),
                        ),

                        SizedBox(height: h * 0.03),

                        /// Get Started Button
                        SizedBox(
                          width: w * 0.8,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(
                                0xFF637FE7,
                              ), // Match theme
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              padding: EdgeInsets.symmetric(vertical: h * 0.015),
                            ),
                            onPressed: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const Home(),
                                ),
                              );
                            },
                            child: Text(
                              'Get Started',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: w * 0.045,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
