import 'package:flutter/material.dart';

class BubbleTextEditingController extends TextEditingController {
  BubbleTextEditingController({super.text});

  TextSpan Function(String text)? styledSpanBuilder;

  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    final builder = styledSpanBuilder;
    if (builder != null) {
      return builder(text);
    }
    return super.buildTextSpan(
      context: context,
      style: style,
      withComposing: withComposing,
    );
  }
}
