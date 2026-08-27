import 'package:flutter/material.dart';

/// A productivity tip shown on the tips screen.
class ProductivityTip {
  const ProductivityTip({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  /// The statically defined tips shown in the app.
  static const List<ProductivityTip> all = [
    ProductivityTip(
      icon: Icons.wb_sunny_outlined,
      title: 'Start bright',
      body: 'Begin with your hardest task before checking messages.',
    ),
    ProductivityTip(
      icon: Icons.timer_outlined,
      title: 'Time-box your work',
      body: 'Set focused 25-minute sprints, then take a 5-minute break.',
    ),
    ProductivityTip(
      icon: Icons.notifications_off_outlined,
      title: 'Silence noise',
      body: 'Put your phone away and close unrelated tabs.',
    ),
    ProductivityTip(
      icon: Icons.water_drop_outlined,
      title: 'Stay hydrated',
      body: 'Drink water and stretch between focus sessions.',
    ),
    ProductivityTip(
      icon: Icons.nights_stay_outlined,
      title: 'Rest and grow',
      body: 'Recovery fuels productivity. Sleep well and recharge.',
    ),
  ];
}
