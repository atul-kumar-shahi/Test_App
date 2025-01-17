import 'package:flutter/material.dart';

class SquareTile extends StatelessWidget {
  const SquareTile({super.key,required this.imagePath,required this.onTap});

  final String imagePath;
  final void Function() onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        child: Image.asset(imagePath,height: 40,),
      ),
    );
  }
}