import 'package:flutter/material.dart';
import 'package:pomoslice/data/task_manager.dart';

class TasksAutocomplete extends StatelessWidget {
  const TasksAutocomplete({
    super.key,
    required this.tasksList,
    required this.taskManager,
  });

  final List<String> tasksList;
  final TaskManager taskManager;

  @override
  Widget build(BuildContext context) {
    return Autocomplete<String>(
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text == '') {
          return const Iterable<String>.empty();
        }
        return tasksList.where((String option) {
          return option.contains(textEditingValue.text.toLowerCase());
        });
      },
      onSelected: (String selection) {
        taskManager.getCurrentSelecedTask(selection);
      },
      fieldViewBuilder:
          (context, textEditingController, focusNode, onFieldSubmitted) {
            return TextField(
              controller: textEditingController,
              focusNode: focusNode,
              onChanged: (value) => taskManager.getCurrentSelecedTask(value),
              onSubmitted: (value) {
                taskManager.getCurrentSelecedTask(value);
                onFieldSubmitted();
              },
            );
          },
    );
  }
}
