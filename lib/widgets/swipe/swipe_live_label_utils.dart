import 'package:flutter/material.dart';

String? getLiveLabel(Offset offset, bool isDragging) {
  if (!isDragging) return null;
  if (offset.dx > 20 && offset.dx.abs() > offset.dy.abs()) return 'Keep';
  if (offset.dx < -20 && offset.dx.abs() > offset.dy.abs()) return 'Delete';
  if (offset.dy < -20 && offset.dy.abs() > offset.dx.abs()) {
    return 'Sort later';
  }
  return null;
}

Color? getLiveLabelColor(Offset offset, bool isDragging) {
  if (!isDragging) return null;
  if (offset.dx > 20 && offset.dx.abs() > offset.dy.abs()) {
    return Colors.green;
  }
  if (offset.dx < -20 && offset.dx.abs() > offset.dy.abs()) return Colors.red;
  if (offset.dy < -20 && offset.dy.abs() > offset.dx.abs()) {
    return Colors.purple;
  }
  return null;
}

bool shouldShowLiveLabel(Offset offset, bool isDragging) {
  if (!isDragging) return false;
  if (offset.dx.abs() > 20 && offset.dx.abs() > offset.dy.abs()) return true;
  if (offset.dy < -20 && offset.dy.abs() > offset.dx.abs()) return true;
  return false;
}
