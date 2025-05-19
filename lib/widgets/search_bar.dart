import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class RecipeSearch extends StatefulWidget {
  final TextEditingController controller;
  final Function(String) onSearchChanged;

  const RecipeSearch({
    super.key,
    required this.controller,
    required this.onSearchChanged,
  });

  @override
  State<RecipeSearch> createState() => _RecipeSearchState();
}

class _RecipeSearchState extends State<RecipeSearch> {
  late stt.SpeechToText speech;
  bool isListening = false;

  @override
  void initState() {
    super.initState();
    speech = stt.SpeechToText();
  }

  void onListen() async {
    if (!isListening) {
      bool available = await speech.initialize(
        onStatus: (val) => print('onStatus: $val'),
        onError: (val) => print('onError: $val'),
      );
      if (available) {
        setState(() {
          isListening = true;
        });
        speech.listen(
          onResult: (val) {
            final query = val.recognizedWords;
            widget.controller.text = query;
            widget.controller.selection = TextSelection.fromPosition(
              TextPosition(offset: widget.controller.text.length),
            );
            widget.onSearchChanged(query.toLowerCase());
          },
        );
      }
    } else {
      setState(() {
        isListening = false;
      });
      speech.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      onChanged: (value) => widget.onSearchChanged(value.toLowerCase()),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        prefixIcon: const Icon(Icons.search),
        hintText: 'Ví dụ: Burger rau củ',
        suffixIcon: IconButton(
          icon: Icon(Icons.mic, color: isListening ? Colors.green : Colors.black),
          onPressed: onListen,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}
