import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../core/constants.dart';

class FlipCardWidget extends StatefulWidget {
  final String front;
  final String back;
  final VoidCallback? onFlip;

  const FlipCardWidget({
    super.key,
    required this.front,
    required this.back,
    this.onFlip,
  });

  @override
  State<FlipCardWidget> createState() => _FlipCardWidgetState();
}

class _FlipCardWidgetState extends State<FlipCardWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isFront = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(_controller);
  }

  @override
  void didUpdateWidget(FlipCardWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reset về mặt trước khi card content thay đổi
    if (oldWidget.front != widget.front || oldWidget.back != widget.back) {
      if (!_isFront) {
        _controller.reverse();
        setState(() => _isFront = true);
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _flip() {
    if (_isFront) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
    setState(() => _isFront = !_isFront);
    widget.onFlip?.call();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _flip,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          final angle = _animation.value * math.pi;
          final transform = Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateY(angle);

          return Transform(
            transform: transform,
            alignment: Alignment.center,
            child: angle <= math.pi / 2
                ? _buildFront()
                : Transform(
                    transform: Matrix4.identity()..rotateY(math.pi),
                    alignment: Alignment.center,
                    child: _buildBack(),
                  ),
          );
        },
      ),
    );
  }

  Widget _buildFront() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.paddingLarge),
      decoration: BoxDecoration(
        color: AppColors.matchaLight,
        borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            widget.front,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.pandaBlack,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSizes.paddingLarge),
          const Text(
            'Nhấn để lật',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white70,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBack() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.paddingLarge),
      decoration: BoxDecoration(
        color: AppColors.pandaWhite,
        borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            widget.back,
            style: const TextStyle(
              fontSize: 18,
              color: AppColors.pandaBlack,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
