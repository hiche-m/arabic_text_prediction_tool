import 'package:flutter/material.dart';

class Headline extends StatefulWidget {
  final String headlineText;
  final double? fontSize;
  const Headline({required this.headlineText, this.fontSize, super.key});

  @override
  State<Headline> createState() => _HeadlineState();
}

class _HeadlineState extends State<Headline> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: FittedBox(
            fit: BoxFit.contain,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 0),
              child: Text(
                widget.headlineText,
                overflow: TextOverflow.fade,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                  fontSize: widget.fontSize ?? 25,
                ),
              ),
            ),
          ),
        ),
        Divider(thickness: 1.0),
      ],
    );
  }
}
