import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NumberInput extends StatefulWidget {
  final int initialValue;
  final int maxValue;
  final int minValue;
  final Function(int) onChanged;

  const NumberInput(
      {Key? key,
      required this.initialValue,
      required this.onChanged,
      this.maxValue = 100,
      this.minValue = 1})
      : super(key: key);

  @override
  NumberInputState createState() => NumberInputState();
}

class NumberInputState extends State<NumberInput> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue.toString());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _increment() {
    int currentValue = int.tryParse(_controller.text) ?? 1;
    if (currentValue < widget.maxValue) {
      setState(() {
        _controller.text = (currentValue + 1).toString();
      });
    }
    widget.onChanged(int.parse(_controller.text));
  }

  void _decrement() {
    int currentValue = int.tryParse(_controller.text) ?? 1;
    if (currentValue > widget.minValue) {
      setState(() {
        _controller.text = (currentValue - 1).toString();
      });
      widget.onChanged(int.parse(_controller.text));
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            onPressed: () => _increment(),
            icon: const Icon(Icons.arrow_drop_up),
          ),
          SizedBox(
            width: 50,
            child: TextField(
              controller: _controller,
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly,
              ],
            ),
          ),
          IconButton(
            onPressed: () => _decrement(),
            icon: Icon(Icons.arrow_drop_down),
          ),
        ],
      ),
    );
  }
}
