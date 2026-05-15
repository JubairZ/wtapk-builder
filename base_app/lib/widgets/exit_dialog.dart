import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../config/app_config.dart';
import '../themes/app_theme.dart';

class ExitDialog extends StatelessWidget {
  const ExitDialog({super.key});

  Color get _primary => AppConfig.useCustomColors
      ? AppConfig.customPrimaryColor
      : AppTheme.getPalette(AppConfig.themeTemplate).primary;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      title: Text(AppConfig.exitDialogTitle,
          style: const TextStyle(fontWeight: FontWeight.bold)),
      content: Text(AppConfig.exitDialogMessage),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(AppConfig.exitNoLabel,
              style: TextStyle(color: Colors.grey.shade600)),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context, true);
            SystemNavigator.pop();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: _primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
          ),
          child: Text(AppConfig.exitYesLabel),
        ),
      ],
    );
  }
}
