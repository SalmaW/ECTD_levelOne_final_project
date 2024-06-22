import 'package:flutter/material.dart';

class GridViewItem extends StatelessWidget {
  final Color? color;
  final String label;
  final IconData iconData;
  final VoidCallback onTap;
  const GridViewItem(
      {required this.label,
      required this.color,
      required this.iconData,
      required this.onTap,
      super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: Colors.white,
        surfaceTintColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: color?.withOpacity(.2),
              child: Icon(
                iconData,
                color: color,
                size: 40,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            )
          ],
        ),
      ),
    );
  }
}
