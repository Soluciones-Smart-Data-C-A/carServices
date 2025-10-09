import 'package:flutter/material.dart';

class SnackBarUtils {
  static void showSnackBar({
    required BuildContext context,
    required String message,
    bool isError = false,
    int durationSeconds = 3,
    SnackBarAction? action,
  }) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: Duration(seconds: durationSeconds),
        action: action,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  static void showSuccess({
    required BuildContext context,
    required String message,
    int durationSeconds = 3,
    SnackBarAction? action,
  }) {
    showSnackBar(
      context: context,
      message: message,
      isError: false,
      durationSeconds: durationSeconds,
      action: action,
    );
  }

  static void showError({
    required BuildContext context,
    required String message,
    int durationSeconds = 4,
    SnackBarAction? action,
  }) {
    showSnackBar(
      context: context,
      message: message,
      isError: true,
      durationSeconds: durationSeconds,
      action: action,
    );
  }

  static void showInfo({
    required BuildContext context,
    required String message,
    int durationSeconds = 3,
    SnackBarAction? action,
  }) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: Colors.blue,
        duration: Duration(seconds: durationSeconds),
        action: action,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  static void showWarning({
    required BuildContext context,
    required String message,
    int durationSeconds = 4,
    SnackBarAction? action,
  }) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: Colors.orange,
        duration: Duration(seconds: durationSeconds),
        action: action,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  static void hideCurrentSnackBar(BuildContext context) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
  }

  static void removeCurrentSnackBar(BuildContext context) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
  }
}
