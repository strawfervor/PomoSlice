import 'package:flutter/material.dart';

class TasksAutocomplete extends StatelessWidget {
  const TasksAutocomplete({super.key, required this.tasksList});

  final List<String> tasksList;

  @override
  Widget build(BuildContext context) {
    return Autocomplete<String>(
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text == '') {
          return const Iterable<String>.empty();
        }
        return tasksList.where((String option) {
          return option.contains(textEditingValue.text.toLowerCase());
        },
        );
      },
      onSelected: (String selection) {
        debugPrint('You just selected $selection');
      },
    );
  }
}