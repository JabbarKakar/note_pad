import 'package:flutter/material.dart';

class PageThumbnail extends StatelessWidget {
  final VoidCallback onTap;
  final int index;
  final int currentPageIndex;

  const PageThumbnail({
    super.key,
    required this.onTap,
    required this.index,
    required this.currentPageIndex,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = currentPageIndex == index;
    final color = isSelected ? Theme.of(context).primaryColor : Colors.grey;

    return InkWell(
      onTap: onTap,
      child: Container(
        width: 35,
        height: 50,
        margin: const EdgeInsets.symmetric(horizontal: 3),
        decoration: BoxDecoration(
          border: Border.all(
            color: color,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        alignment: Alignment.center,
        child: Text(
          '${index + 1}',
          style: TextStyle(color: color),
        ),
      ),
    );
  }
}
