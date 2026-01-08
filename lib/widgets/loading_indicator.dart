import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../core/theme/app_colors.dart';

/// Custom loading indicator
class LoadingIndicator extends StatelessWidget {
  final Color? color;
  final double size;

  const LoadingIndicator({
    super.key,
    this.color,
    this.size = 50,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SpinKitFadingCircle(
        color: color ?? AppColors.primary,
        size: size,
      ),
    );
  }
}
