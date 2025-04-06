import 'package:flutter/material.dart';

class ControlButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final bool isPrimary;
  final bool isActive;

  const ControlButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.isPrimary = false,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        gradient: isPrimary && isActive
            ? const LinearGradient(
                colors: [Color(0xFFE8550C), Color(0xFFF47333)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : const LinearGradient(
                colors: [Color(0xFF47494B), Color(0xFF18191D)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        borderRadius: BorderRadius.circular(40),
        border: Border.all(
          color: isPrimary && isActive
              ? const Color(0xFFE8550C)
              : const Color(0xFF2F3139),
          width: 3,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF5B5B5B),
            blurRadius: 3,
            offset: const Offset(-3, -3),
            spreadRadius: isPrimary && isActive ? 1 : 0,
          ),
          BoxShadow(
            color: const Color(0xFF050606),
            blurRadius: 3,
            offset: const Offset(3, 3),
            spreadRadius: isPrimary && isActive ? 1 : 0,
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, size: 30),
        color: isPrimary && isActive ? Colors.white : const Color(0xFF84878A),
        onPressed: onPressed,
      ),
    );
  }
}
