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
        taskManager.setCurrentSelectedTask(selection);
        controller.text = selection;
        FocusScope.of(context).unfocus();
      },
      fieldViewBuilder:
          (context, textEditingController, focusNode, onFieldSubmitted) {
            // Autocomplete owns an internal controller. The external controller
            // only keeps the text alive when this widget is recreated after a
            // tab switch.
            if (controller.text.isNotEmpty &&
                textEditingController.text.isEmpty) {
              textEditingController.text = controller.text;
            }

            return TextField(
              controller: textEditingController,
              focusNode: focusNode,
              onChanged: (value) {
                taskManager.setCurrentSelectedTask(value);
                controller.text = value;
              },
              onSubmitted: (value) {
                taskManager.setCurrentSelectedTask(value);
                controller.text = value;
                onFieldSubmitted();
              },
            );
          },
    );
  }
}
