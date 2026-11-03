import 'package:flutter/material.dart';
import 'package:flutter_app/data/constants.dart';
import 'package:flutter_app/views/pages/login_page.dart';
import 'package:flutter_app/views/pages/role_selection_page.dart';
import 'package:flutter_app/views/widgets/app_widgets.dart';
import 'package:lottie/lottie.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Arch-shaped soft-mint backdrop behind the hero animation,
                  // echoing the rounded-arch photo frames from the reference.
                  ClipPath(
                    clipper: _ArchClipper(),
                    child: Container(
                      height: 230,
                      width: double.infinity,
                      color: AppColors.tealStart.withOpacity(0.10),
                      alignment: Alignment.center,
                      // The source animation draws its house within a mostly
                      // empty 800x800 canvas — zoom in so it reads as a hero
                      // illustration instead of a small icon lost in the arch.
                      child: Transform.scale(
                        scale: 2.6,
                        child: Lottie.asset(
                          'assets/lotties/welcome.json',
                          height: 260.0,
                          width: double.infinity,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28.0),
                  Text(
                    "Senior App",
                    textAlign: TextAlign.center,
                    style: AppTextStyles.heading1.copyWith(fontSize: 34.0, letterSpacing: 0.5),
                  ),
                  const SizedBox(height: 10.0),
                  const Text(
                    "Let's spread cheer & show that\nwe care for our elderly.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16.0,
                      color: AppColors.textGrey,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 36.0),

                  GradientPillButton(
                    label: "Get started",
                    radius: AppRadius.pill,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RoleSelectionPage(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 14.0),

                  OutlinedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginPage(title: "Login"),
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.pill)),
                    ),
                    child: const Text("Login"),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Rounded-arch silhouette (flat sides, semicircular top) used behind the
/// welcome hero animation.
class _ArchClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final radius = size.width / 2;
    final straightHeight = size.height - radius;
    return Path()
      ..moveTo(0, size.height)
      ..lineTo(0, straightHeight)
      ..arcToPoint(Offset(size.width, straightHeight), radius: Radius.circular(radius))
      ..lineTo(size.width, size.height)
      ..close();
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
