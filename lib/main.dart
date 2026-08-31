import 'dart:async';

import 'package:flutter/material.dart';

import 'app.dart';
import 'services/notification_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialise in the background so notification setup never blocks startup.
  unawaited(NotificationService.instance.init());
  runApp(const FocusLeafApp());
}
