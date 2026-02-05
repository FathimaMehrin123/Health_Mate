import 'package:flutter/material.dart';

class CustomDropdown extends StatelessWidget {
  // final String label;
  final String selectedValue;
  final List<DropdownItems<String>> items;
  final void Function(String?)? onChanged;
  final String? Function(String?)? validator;

  const CustomDropdown({
    super.key,
    //  required this.label,
    required this.selectedValue,
    required this.items,
    this.onChanged,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      isExpanded: true,

      // initialValue: selectedValue,
      initialValue: selectedValue,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Color(0xFF6B73FF), width: 2),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      items: items.map((item) {
        return DropdownMenuItem<String>(
          value: item.label,
          child: Column(
            //  mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(item.label),
              //   if (item.subtitle != null)
              //    Text(item.subtitle!, style: TextStyle(fontSize: 11)),
            ],
          ),
        );
      }).toList(),

      onChanged: onChanged,
      validator: validator,
      icon: Icon(Icons.keyboard_arrow_down, color: Color(0xFF6B73FF)),
    );
  }
}

class DropdownItems<String> {
  // final String value;
  final String label;
  final String? subtitle;

  DropdownItems({required this.label, this.subtitle});
}
