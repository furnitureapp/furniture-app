import 'package:flutter/material.dart';
import 'package:furniture_ecom_app/my_ecom/my_constants/colors.dart';

class PaginationWidget extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final VoidCallback? onPrev;
  final VoidCallback? onNext;

  const PaginationWidget({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.onPrev,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12.0, bottom: 25.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GradientButtons(
            text: "PREV",
            onPressed: currentPage > 1 ? onPrev : null,
          ),
          const SizedBox(width: 20),
          Text(
            "Page $currentPage of $totalPages",
            style: const TextStyle(color: mythemecolor),
          ),
          const SizedBox(width: 20),
          GradientButtons(
            text: "NEXT",
            onPressed: currentPage < totalPages ? onNext : null,
          ),
        ],
      ),
    );
  }
}



class GradientButtons extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;

  const GradientButtons({super.key, required this.text, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: onPressed == null ? 0.4 : 1.0,
      child: Container(
        width: 80,
        height: 40,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [mythemecolor, mythemecolor1],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: onPressed,
          child: Text(
            text,
            style: const TextStyle(fontSize: 12, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
