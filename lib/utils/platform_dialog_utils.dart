import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io';

enum DialogType {
  delete,
  error,
  warning,
  success,
  info,
}

class PlatformDialog {
  static Future<bool> showDeleteConfirmation({
    required BuildContext context,
    required String title,
    required String content,
  }) async {
    return await _showConfirmationDialog(
      context: context,
      type: DialogType.delete,
      title: title,
      content: content,
    );
  }

  static Future<void> showError({
    required BuildContext context,
    required String title,
    required String content,
  }) async {
    await _showAlertDialog(
      context: context,
      type: DialogType.error,
      title: title,
      content: content,
    );
  }

  static Future<bool> _showConfirmationDialog({
    required BuildContext context,
    required DialogType type,
    required String title,
    required String content,
  }) async {
    if (Platform.isIOS || Platform.isMacOS) {
      return await _showCupertinoDialog(
        context: context,
        type: type,
        title: title,
        content: content,
      );
    } else {
      return await _showMaterialDialog(
        context: context,
        type: type,
        title: title,
        content: content,
      );
    }
  }

  static Future<void> _showAlertDialog({
    required BuildContext context,
    required DialogType type,
    required String title,
    required String content,
  }) async {
    if (Platform.isIOS || Platform.isMacOS) {
      await showCupertinoDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => CupertinoAlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            CupertinoDialogAction(
              child: const Text('OK'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );
    } else {
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );
    }
  }

  static Future<bool> _showCupertinoDialog({
    required BuildContext context,
    required DialogType type,
    required String title,
    required String content,
  }) async {
    final result = await showCupertinoDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => CupertinoAlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          CupertinoDialogAction(
            isDestructiveAction: type == DialogType.delete,
            onPressed: () => Navigator.pop(context, true),
            child: _getActionText(type, true),
          ),
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context, false),
            child: _getActionText(type, false),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  static Future<bool> _showMaterialDialog({
    required BuildContext context,
    required DialogType type,
    required String title,
    required String content,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: _getActionText(type, false),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: type == DialogType.delete ? Colors.red : null,
            ),
            child: _getActionText(type, true),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  static Text _getActionText(DialogType type, bool isConfirm) {
    switch (type) {
      case DialogType.delete:
        return Text(isConfirm ? 'Delete' : 'Cancel');
      case DialogType.warning:
        return Text(isConfirm ? 'Proceed' : 'Cancel');
      default:
        return Text(isConfirm ? 'OK' : 'Cancel');
    }
  }
}