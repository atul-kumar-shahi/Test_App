import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final bool? isObscuredText;
  final String? obscuredCharacter;
  final String hintText;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final bool readOnly;
  final Function(String)? onChanged; // Add onChanged property

  const CustomTextField({
    super.key,
    required this.controller,
    this.keyboardType = TextInputType.text,
    this.isObscuredText = false,
    this.obscuredCharacter = '*',
    required this.hintText,
    this.suffixIcon,
    this.prefixIcon,
    this.readOnly = false, // Initialize readOnly property
    this.onChanged, // Initialize onChanged property
  });

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: isObscuredText!,
        obscuringCharacter: obscuredCharacter!,
        readOnly: readOnly, // Use readOnly property
        onChanged: onChanged, // Use onChanged property
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.only(top: 20, left: 15, bottom: 12),
          constraints: BoxConstraints(
            maxHeight: height * 0.095,
            maxWidth: width,
          ),
          filled: true,
          fillColor: Colors.white,
          hintText: hintText,
          hintStyle: TextStyle(
            color: Colors.grey.shade500,
          ),
          prefixIcon: prefixIcon,
          suffixIcon: suffixIcon,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30.0),
            borderSide: const BorderSide(
              color: Colors.red,
              width: 1,
            ),
          ),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.blue,
              width: 1,
            ),
          ),
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.black,
              width: 1,
            ),
          ),
        ),
      ),
    );
  }
}
