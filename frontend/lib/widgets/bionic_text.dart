import 'package:flutter/material.dart';

class BionicText extends StatelessWidget {
  final String text;
  final TextStyle? style;

  const BionicText(this.text, {super.key, this.style});

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: _buildTextSpan(context, text, style: style),
    );
  }

  TextSpan _buildTextSpan(BuildContext context, String text, {TextStyle? style}) {
    final defaultStyle = style ?? DefaultTextStyle.of(context).style;
    final boldStyle = defaultStyle.copyWith(fontWeight: FontWeight.bold);
    final spans = <TextSpan>[];
    final words = text.split(' ');

    for (final word in words) {
      if (word.isEmpty) continue;
      final boldLength = (word.length / 2).ceil();
      final boldPart = word.substring(0, boldLength);
      final regularPart = word.substring(boldLength);
      spans.add(TextSpan(text: boldPart, style: boldStyle));
      spans.add(TextSpan(text: regularPart, style: defaultStyle));
      spans.add(const TextSpan(text: ' '));
    }
    return TextSpan(children: spans, style: defaultStyle);
  }
}
