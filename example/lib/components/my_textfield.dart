import 'package:flutter/material.dart';

class MyTextfield extends StatelessWidget {
  final String hintText;
  final TextEditingController controller;
  final FocusNode? focusNode;
  final IconData? prefixIcon;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final int? maxLines;
  final Color? textColor;
  final Color? backgroundColor;
  final Color? hintTextColor;
  final Color? errorColor;
  final Color? errorBorderColor;
  final double? errorFontSize;
  final EdgeInsetsGeometry? padding;

  const MyTextfield({
    super.key,
    required this.hintText,
    required this.controller,
    this.focusNode,
    this.prefixIcon,
    this.validator,
    this.keyboardType,
    this.maxLines,
    this.textColor,
    this.backgroundColor,
    this.hintTextColor,
    this.errorColor,
    this.errorBorderColor,
    this.errorFontSize,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 0.0),
      child: TextFormField(
        controller: controller,
        focusNode: focusNode,
        validator: validator,
        keyboardType: keyboardType,
        maxLines: maxLines,
        style: TextStyle(
            color: textColor ?? Colors.black,
            fontFamily: 'Arial',
            fontSize: 14),
        decoration: InputDecoration(
          // Error Text Style
          errorStyle: TextStyle(
            color: errorColor ?? Colors.red,
            fontSize: errorFontSize ?? 12,
            fontWeight: FontWeight.w500,
          ),
          // Focused
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(
              color: Color(0xFF1E3A8A),
            ),
            borderRadius: BorderRadius.circular(12),
          ),

          // Enabled Border
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(
              color: Color(0xFF1E3A8A),
            ),
            borderRadius: BorderRadius.circular(12),
          ),

          // Normal Border
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),

          // Error Border
          errorBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: errorBorderColor ?? Colors.red,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(12),
          ),

          // Focused Error Border
          focusedErrorBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: errorBorderColor ?? Colors.red,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(12),
          ),

          // Content Padding (Adjust Textfield Padding)
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),

          // Fill Color
          fillColor:
              backgroundColor ?? const Color(0xFF1E3A8A).withValues(alpha: 0.2),
          filled: true,

          // Hint Text
          hintText: hintText,
          hintStyle: TextStyle(
            color: hintTextColor ?? const Color(0xFF1E3A8A),
          ),

          prefixIcon: prefixIcon != null
              ? Icon(
                  prefixIcon,
                  color: const Color(0xFF1E3A8A),
                )
              : null,
        ),
      ),
    );
  }
}
