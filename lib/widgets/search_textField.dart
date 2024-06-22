import 'package:flutter/material.dart';

class SearchTextField extends StatelessWidget {
  final void Function(String)? rawQueryText;
  const SearchTextField({
    required this.rawQueryText,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      onTapOutside: (event) {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      onChanged: rawQueryText,
      decoration: const InputDecoration(
        prefixIcon: Icon(Icons.search),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(5)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(5)),
        ),
        labelText: "Search",
      ),
    );
  }
}
