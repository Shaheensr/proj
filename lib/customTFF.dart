import 'package:flutter/material.dart';

class AuthTextField extends StatelessWidget {
  const AuthTextField(
      {Key? key,
      required this.controller,
      required this.label,
      required this.hint,
      required this.validate})
      : super(key: key);

  final TextEditingController controller;
  final Function validate;
  final String label;
  final String hint;
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      autocorrect: false,
      controller: controller,
      validator: (value) {
        validate(value);
      },
      decoration: const InputDecoration(
          labelText: "label",
          border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(10.0))),
          hintText: "hint"),
    );
  }
}