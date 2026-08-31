import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/auth/auth_bloc.dart';
import '../blocs/auth/auth_event.dart';
import '../blocs/auth/auth_state.dart';
import '../theme/app_theme.dart';
import 'login_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _nameController = TextEditingController();
  bool _editing = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _startEdit(Authenticated authState) {
    _nameController.text = authState.user.name;
    setState(() => _editing = true);
  }

  void _saveEdit() {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;
    context.read<AuthBloc>().add(UpdateProfile(name: name));
    setState(() => _editing = false);
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: () => Navigator.of(context).pop(),
              )
            : null,
      ),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is Authenticated) {
            final user = state.user;
            return ListView(
              padding: EdgeInsets.symmetric(horizontal: w * 0.06, vertical: w * 0.05),
              children: [
                // Avatar
                Center(
                  child: Container(
                    width: w * 0.22,
                    height: w * 0.22,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF66BB6A), Color(0xFF2E7D32)],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.seedColor.withValues(alpha: 0.3),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        user.firstName.substring(0, 1).toUpperCase(),
                        style: TextStyle(
                          fontSize: w * 0.09,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: w * 0.04),
                // Name field / display
                if (_editing)
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _nameController,
                          textCapitalization: TextCapitalization.words,
                          autofocus: true,
                          decoration: const InputDecoration(hintText: 'Your name'),
                          onSubmitted: (_) => _saveEdit(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton.filled(
                        onPressed: _saveEdit,
                        icon: const Icon(Icons.check_rounded, size: 20),
                      ),
                    ],
                  )
                else
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        user.name,
                        style: TextStyle(
                          fontSize: w * 0.05,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.ink,
                        ),
                      ),
                      const SizedBox(width: 6),
                      GestureDetector(
                        onTap: () => _startEdit(state),
                        child: Icon(Icons.edit_rounded, size: w * 0.04, color: AppTheme.muted),
                      ),
                    ],
                  ),
                SizedBox(height: w * 0.01),
                Center(
                  child: Text(
                    user.email,
                    style: TextStyle(fontSize: w * 0.035, color: AppTheme.muted),
                  ),
                ),
                if (user.createdAt != null) ...[
                  SizedBox(height: w * 0.01),
                  Center(
                    child: Text(
                      'Member since ${_formatDate(user.createdAt!)}',
                      style: TextStyle(fontSize: w * 0.03, color: AppTheme.muted.withValues(alpha: 0.7)),
                    ),
                  ),
                ],
                SizedBox(height: w * 0.06),
                // Account section
                _SectionHeader(title: 'Account', w: w),
                SizedBox(height: w * 0.03),
                _ProfileTile(
                  icon: Icons.logout_rounded,
                  label: 'Sign out',
                  color: Colors.red.shade400,
                  onTap: () => _showLogoutDialog(context),
                ),
              ],
            );
          }

          // Not logged in
          return Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: w * 0.08),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.person_outline_rounded, size: w * 0.18, color: AppTheme.muted.withValues(alpha: 0.3)),
                  SizedBox(height: w * 0.04),
                  Text(
                    'No account yet',
                    style: TextStyle(fontSize: w * 0.045, fontWeight: FontWeight.w700, color: AppTheme.ink),
                  ),
                  SizedBox(height: w * 0.015),
                  Text(
                    'Sign up to personalise your experience\nand keep your progress backed up.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: w * 0.035, color: AppTheme.muted, height: 1.5),
                  ),
                  SizedBox(height: w * 0.06),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: FilledButton(
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const LoginPage()),
                      ),
                      child: const Text('Sign in or create account'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sign out?'),
        content: const Text('You can sign in again at any time.'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              context.read<AuthBloc>().add(const LogOut());
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red.shade400),
            child: const Text('Sign out'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime d) {
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${months[d.month - 1]} ${d.day}, ${d.year}';
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.w});
  final String title;
  final double w;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontSize: w * 0.032,
        fontWeight: FontWeight.w600,
        color: AppTheme.muted,
        letterSpacing: 0.5,
      ),
    );
  }
}

class _ProfileTile extends StatelessWidget {
  const _ProfileTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final c = color ?? AppTheme.ink;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: w * 0.04, vertical: w * 0.035),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(w * 0.035),
          border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
        ),
        child: Row(
          children: [
            Icon(icon, size: w * 0.05, color: c),
            SizedBox(width: w * 0.03),
            Expanded(
              child: Text(label, style: TextStyle(fontSize: w * 0.038, color: c)),
            ),
            Icon(Icons.chevron_right_rounded, size: w * 0.045, color: Colors.black.withValues(alpha: 0.15)),
          ],
        ),
      ),
    );
  }
}