import 'package:flutter/material.dart';
import '../../core/theme.dart';

class SkeletonSplashScreen extends StatefulWidget {
  const SkeletonSplashScreen({super.key});

  @override
  State<SkeletonSplashScreen> createState() => _SkeletonSplashScreenState();
}

class _SkeletonSplashScreenState extends State<SkeletonSplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildAppIcon(context),
            SizedBox(height: AppSpacing.xl),
            _buildLoadingSpinner(context),
            SizedBox(height: AppSpacing.lg),
            _buildLoadingText(context),
          ],
        ),
      ),
    );
  }

  Widget _buildAppIcon(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: Scale.of(context, 72),
          height: Scale.of(context, 72),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(Scale.of(context, 36)),
            color: Color.lerp(
              AppColors.primary,
              AppColors.primary.withValues(alpha: 0.7),
              _animation.value,
            ),
          ),
          child: Icon(
            Icons.photo_library_outlined,
            color: Colors.white,
            size: Scale.of(context, 36),
          ),
        );
      },
    );
  }

  Widget _buildLoadingSpinner(BuildContext context) {
    return SizedBox(
      width: Scale.of(context, 24),
      height: Scale.of(context, 24),
      child: CircularProgressIndicator(
        strokeWidth: 2,
        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
      ),
    );
  }

  Widget _buildLoadingText(BuildContext context) {
    return Text(
      'Loading your gallery...',
      style: AppTextStyles.title(context).copyWith(color: AppColors.primary),
    );
  }
}
