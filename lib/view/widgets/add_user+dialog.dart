import 'package:flutter/material.dart';
import 'package:shadow_chat/view/widgets/custom_text_field.dart';

class AddUserDialog extends StatelessWidget {
  const AddUserDialog({super.key,});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      title: Text('Add User'),
      content: CustomTextField(
        labelText: 'Email',
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            // Add user logic here
            Navigator.of(context).pop();
          },
          child: Text('Add'),
        ),
      ],

    );
  }
}
