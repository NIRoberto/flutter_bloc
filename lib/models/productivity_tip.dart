import 'package:flutter/material.dart';

class ProductivityTip {
  const ProductivityTip({
    required this.icon,
    required this.title,
    required this.body,
    required this.category,
    required this.color,
  });

  final IconData icon;
  final String title;
  final String body;
  final String category;
  final Color color;

  static const List<ProductivityTip> all = [
    ProductivityTip(
      icon: Icons.wb_sunny_rounded,
      title: 'Start with the hardest task',
      body: 'Tackle your most important work before checking messages. Your willpower is highest in the morning.',
      category: 'Morning',
      color: Color(0xFFE65100),
    ),
    ProductivityTip(
      icon: Icons.timer_rounded,
      title: 'Time-box your work',
      body: 'Set focused sprints with a timer. Constraints create urgency and prevent perfectionism.',
      category: 'Focus',
      color: Color(0xFF2E7D32),
    ),
    ProductivityTip(
      icon: Icons.do_not_disturb_on_rounded,
      title: 'Silence all notifications',
      body: 'Every interruption costs 23 minutes of recovery time. Protect your deep work blocks fiercely.',
      category: 'Focus',
      color: Color(0xFF6A1B9A),
    ),
    ProductivityTip(
      icon: Icons.water_drop_rounded,
      title: 'Stay hydrated',
      body: 'Even mild dehydration reduces cognitive performance by up to 20%. Keep water at your desk.',
      category: 'Energy',
      color: Color(0xFF0277BD),
    ),
    ProductivityTip(
      icon: Icons.bedtime_rounded,
      title: 'Protect your sleep',
      body: 'Sleep is when your brain consolidates learning. 7–9 hours is non-negotiable for peak performance.',
      category: 'Recovery',
      color: Color(0xFF283593),
    ),
    ProductivityTip(
      icon: Icons.directions_walk_rounded,
      title: 'Move between sessions',
      body: 'A 5-minute walk between focus blocks boosts creativity and resets your attention span.',
      category: 'Energy',
      color: Color(0xFF00695C),
    ),
    ProductivityTip(
      icon: Icons.checklist_rounded,
      title: 'Plan tomorrow tonight',
      body: 'Write your top 3 priorities the night before. You\'ll start the day with clarity instead of chaos.',
      category: 'Planning',
      color: Color(0xFFC62828),
    ),
    ProductivityTip(
      icon: Icons.self_improvement_rounded,
      title: 'Single-tasking wins',
      body: 'Multitasking reduces productivity by 40%. Do one thing at a time and do it fully.',
      category: 'Focus',
      color: Color(0xFF558B2F),
    ),
  ];
}
