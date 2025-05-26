import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

class ToastService {
  /// Mostra un toast di successo
  static void showSuccess(BuildContext context, String message) {
    _showToast(context, message, true);
  }

  /// Mostra un toast di errore
  static void showError(BuildContext context, String message) {
    _showToast(context, message, false);
  }

  /// Mostra un toast informativo
  static void showInfo(BuildContext context, String message) {
    _showCustomToast(
      context,
      message,
      'Informazione',
      ToastificationType.info,
      Colors.blue,
      Colors.blue.shade600,
      const Icon(Icons.info_outline, color: Colors.blue),
    );
  }

  /// Mostra un toast di avvertimento
  static void showWarning(BuildContext context, String message) {
    _showCustomToast(
      context,
      message,
      'Attenzione',
      ToastificationType.warning,
      Colors.orange,
      Colors.orange.shade600,
      const Icon(
        Icons.warning_amber_outlined,
        color: Colors.orange,
      ),
    );
  }

  /// Metodo base per mostrare un toast di successo o errore
  static void _showToast(BuildContext context, String message, bool isSuccess) {
    _showCustomToast(
      context,
      message,
      isSuccess ? 'Successo' : 'Attenzione',
      isSuccess ? ToastificationType.success : ToastificationType.error,
      isSuccess ? Colors.green : Colors.red,
      isSuccess ? Colors.green.shade600 : Colors.red.shade600,
      isSuccess
          ? const Icon(Icons.check_circle_outline, color: Colors.green)
          : const Icon(Icons.error_outline, color: Colors.red),
    );
  }

  /// Metodo principale che mostra un toast completamente personalizzabile
  static void _showCustomToast(
    BuildContext context,
    String message,
    String title,
    ToastificationType type,
    Color textColor,
    Color backgroundColor,
    Icon icon,
  ) {
    toastification.show(
      context: context,
      type: type,
      style: ToastificationStyle.flatColored,
      autoCloseDuration: const Duration(seconds: 3),
      title: Text(
        title,
        style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
      ),
      description: Text(
        message,
        style: TextStyle(color: textColor),
      ),
      alignment: Alignment.bottomCenter,
      animationDuration: const Duration(milliseconds: 300),
      // Utilizziamo un'animazione predefinita più semplice
      // invece di una funzione di animazione personalizzata
      closeOnClick: true,

      icon: icon,
      primaryColor: backgroundColor,
      backgroundColor: backgroundColor,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      margin: const EdgeInsets.all(8),
      borderRadius: BorderRadius.circular(8),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.2),
          blurRadius: 8,
          offset: const Offset(0, 4),
        )
      ],
    );
  }
}
