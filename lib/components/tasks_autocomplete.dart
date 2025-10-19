import 'package:flutter/material.dart';
import 'package:pomoslice/data/task_manager.dart';

class TasksAutocomplete extends StatelessWidget {
  const TasksAutocomplete({
    super.key,
    required this.tasksList,
    required this.taskManager,
    required this.controller,
  });

  final List<String> tasksList;
  final TaskManager taskManager;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Autocomplete<String>(
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text == '') {
          return const Iterable<String>.empty();
        }
        return tasksList.where((String option) {
          return option.toLowerCase().contains(
            textEditingValue.text.toLowerCase(),
          );
        });
      },
      onSelected: (String selection) {
        taskManager.setCurrentSelecedTask(selection);
        controller.text = selection;
        FocusScope.of(context).unfocus();
      },
      fieldViewBuilder:
          (context, textEditingController, focusNode, onFieldSubmitted) {
            if (controller.text.isNotEmpty &&
                textEditingController.text.isEmpty) {
              textEditingController.text = controller.text;
            }

            return TextField(
              controller: textEditingController,
              focusNode: focusNode,
              onChanged: (value) {
                taskManager.setCurrentSelecedTask(value);
                controller.text = value; // DODAJ TĘ LINIĘ
              },
              onSubmitted: (value) {
                taskManager.setCurrentSelecedTask(value);
                controller.text = value; // DODAJ TĘ LINIĘ
                onFieldSubmitted();
              },
            );
          },
    );
  }
}
