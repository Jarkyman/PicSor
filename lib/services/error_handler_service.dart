import 'package:flutter/material.dart';
import '../core/theme.dart';

enum ErrorType { network, permission, storage, gallery, swipe, unknown }

class AppError {
  final String message;
  final ErrorType type;
  final Exception? originalException;
  final String? userFriendlyMessage;

  AppError({
    required this.message,
    required this.type,
    this.originalException,
    this.userFriendlyMessage,
  });

  String get displayMessage => userFriendlyMessage ?? message;

  @override
  String toString() {
    if (originalException != null) {
      return 'AppError: $message (Type: $type, Original: $originalException)';
    }
    return 'AppError: $message (Type: $type)';
  }
}

class ErrorHandlerService {
  static final ErrorHandlerService _instance = ErrorHandlerService._internal();
  factory ErrorHandlerService() => _instance;
  ErrorHandlerService._internal();

  void handleError(
    BuildContext context,
    dynamic error, {
    ErrorType type = ErrorType.unknown,
    String? userFriendlyMessage,
    VoidCallback? onRetry,
  }) {
    final appError = _createAppError(error, type, userFriendlyMessage);

    debugPrint('ErrorHandlerService: ${appError.toString()}');

    _showErrorDialog(context, appError, onRetry);
  }

  void handleSilentError(dynamic error, {ErrorType type = ErrorType.unknown}) {
    final appError = _createAppError(error, type);
    debugPrint('ErrorHandlerService (Silent): ${appError.toString()}');
  }

  AppError _createAppError(
    dynamic error,
    ErrorType type, [
    String? userFriendlyMessage,
  ]) {
    if (error is AppError) {
      return error;
    }

    String message = error.toString();
    Exception? originalException;

    if (error is Exception) {
      originalException = error;
    }

    // Provide user-friendly messages for common errors
    userFriendlyMessage ??= _getUserFriendlyMessage(type, message);

    return AppError(
      message: message,
      type: type,
      originalException: originalException,
      userFriendlyMessage: userFriendlyMessage,
    );
  }

  String _getUserFriendlyMessage(ErrorType type, String originalMessage) {
    switch (type) {
      case ErrorType.network:
        return 'Network connection issue. Please check your internet connection and try again.';
      case ErrorType.permission:
        return 'Permission denied. Please grant the required permissions in your device settings.';
      case ErrorType.storage:
        return 'Storage access issue. Please check your device storage and try again.';
      case ErrorType.gallery:
        return 'Unable to access your photo gallery. Please check permissions and try again.';
      case ErrorType.swipe:
        return 'Unable to process swipe action. Please try again.';
      case ErrorType.unknown:
        return 'Something went wrong. Please try again.';
    }
  }

  void _showErrorDialog(
    BuildContext context,
    AppError error,
    VoidCallback? onRetry,
  ) {
    if (!context.mounted) return;

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Row(
              children: [
                Icon(
                  _getErrorIcon(error.type),
                  color: AppColors.error,
                  size: Scale.of(context, 24),
                ),
                SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    _getErrorTitle(error.type),
                    style: AppTextStyles.title(context),
                  ),
                ),
              ],
            ),
            content: Text(
              error.displayMessage,
              style: AppTextStyles.body(context),
            ),
            actions: [
              if (onRetry != null)
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    onRetry();
                  },
                  child: Text('Retry', style: AppTextStyles.button(context)),
                ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('OK', style: AppTextStyles.button(context)),
              ),
            ],
          ),
    );
  }

  IconData _getErrorIcon(ErrorType type) {
    switch (type) {
      case ErrorType.network:
        return Icons.wifi_off;
      case ErrorType.permission:
        return Icons.block;
      case ErrorType.storage:
        return Icons.storage;
      case ErrorType.gallery:
        return Icons.photo_library;
      case ErrorType.swipe:
        return Icons.swipe;
      case ErrorType.unknown:
        return Icons.error;
    }
  }

  String _getErrorTitle(ErrorType type) {
    switch (type) {
      case ErrorType.network:
        return 'Connection Error';
      case ErrorType.permission:
        return 'Permission Required';
      case ErrorType.storage:
        return 'Storage Error';
      case ErrorType.gallery:
        return 'Gallery Error';
      case ErrorType.swipe:
        return 'Swipe Error';
      case ErrorType.unknown:
        return 'Error';
    }
  }

  // Convenience methods for common error types
  void handleNetworkError(
    BuildContext context,
    dynamic error, {
    VoidCallback? onRetry,
  }) {
    handleError(context, error, type: ErrorType.network, onRetry: onRetry);
  }

  void handlePermissionError(
    BuildContext context,
    dynamic error, {
    VoidCallback? onRetry,
  }) {
    handleError(context, error, type: ErrorType.permission, onRetry: onRetry);
  }

  void handleGalleryError(
    BuildContext context,
    dynamic error, {
    VoidCallback? onRetry,
  }) {
    handleError(context, error, type: ErrorType.gallery, onRetry: onRetry);
  }

  void handleSwipeError(
    BuildContext context,
    dynamic error, {
    VoidCallback? onRetry,
  }) {
    handleError(context, error, type: ErrorType.swipe, onRetry: onRetry);
  }
}
