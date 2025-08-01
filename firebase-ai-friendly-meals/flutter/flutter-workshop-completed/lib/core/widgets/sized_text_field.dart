import 'package:flutter/material.dart';

class SizedTextField extends StatelessWidget {
  const SizedTextField({
    required this.controller,
    required this.onChanged,
    this.hintText,
    this.enabled,
    this.height = 128,
    super.key,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final String? hintText;
  final bool? enabled;
  final double height;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      enabled: enabled,
      maxLines: null,
      expands: true,
      textAlignVertical: TextAlignVertical.top,
      decoration: InputDecoration(
        constraints: BoxConstraints(
          maxHeight: height,
          minHeight: height,
        ),
        hintText: hintText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surface,
        contentPadding: const EdgeInsets.all(16),
      ),
    );
  }
}
