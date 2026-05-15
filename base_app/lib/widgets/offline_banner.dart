import 'package:flutter/material.dart';

  /// Animated banner shown at the top when internet is lost.
  class OfflineBanner extends StatelessWidget {
    final bool isOffline;
    const OfflineBanner({super.key, required this.isOffline});

    @override
    Widget build(BuildContext context) {
      return AnimatedSlide(
        offset: isOffline ? Offset.zero : const Offset(0, -1),
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
        child: AnimatedOpacity(
          opacity: isOffline ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 300),
          child: Material(
            elevation: 4,
            child: Container(
              width: double.infinity,
              color: const Color(0xFFB71C1C),
              padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.wifi_off_rounded, color: Colors.white, size: 16),
                  SizedBox(width: 8),
                  Text(
                    'No internet connection',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }
  }
  