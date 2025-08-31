import 'package:flutter/material.dart';

class TasksAutocomplete extends StatelessWidget {
  const TasksAutocomplete({super.key});

  //TODO: replace that with List created of user tasks in local storage
  static const List<String> _kOptions = <String>['reading', 'programming', 'cleaning', 'running'];

  @override
  Widget build(BuildContext context) {
    return Autocomplete<String>(
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text == '') {
          return const Iterable<String>.empty();
        }
        return _kOptions.where((String option) {
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