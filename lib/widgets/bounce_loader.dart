import 'package:flutter/material.dart';
import 'dart:math' as math;

class BounceLoader extends StatefulWidget {
  final double size;
  
  const BounceLoader({
    Key? key,
    this.size = 60,
  }) : super(key: key);

  @override
  State<BounceLoader> createState() => _BounceLoaderState();
}

class _BounceLoaderState extends State<BounceLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2100),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: widget.size,
          height: widget.size + 90, // Добавляем место для прыжка
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildBall(delay: 0.0, index: 0),
              _buildBall(delay: 0.3, index: 1),
              _buildBall(delay: 0.6, index: 2),
            ],
          ),
        ),
        const SizedBox(height: 30),
        Text(
          'Загрузка...',
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 16,
            fontWeight: FontWeight.w300,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }

  Widget _buildBall({required double delay, required int index}) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = (_controller.value + delay) % 1.0;
        
        // Плавная анимация с ease-in-out эффектом
        double normalizedT;
        if (t <= 0.5) {
          // Подъем: ease-out
          normalizedT = t / 0.5;
          normalizedT = (1 - math.pow(1 - normalizedT, 3)).toDouble(); // Cubic ease-out
        } else {
          // Падение: ease-in
          normalizedT = (t - 0.5) / 0.5;
          normalizedT = math.pow(normalizedT, 3).toDouble(); // Cubic ease-in
        }
        
        // Анимация: в 50% шарик подпрыгивает на -90px и уменьшается до 0.3
        double translateY = 0;
        double scale = 1.0;
        double opacity = 1.0;
        
        if (t <= 0.5) {
          // Подъем: от 0 до 50%
          translateY = -90 * normalizedT;
          scale = 1.0 - (1.0 - 0.3) * normalizedT;
          opacity = 0.6 + 0.4 * normalizedT; // Становится ярче при подъеме
        } else {
          // Падение: от 50% до 100%
          translateY = -90 + 90 * normalizedT;
          scale = 0.3 + (1.0 - 0.3) * normalizedT;
          opacity = 1.0 - 0.4 * normalizedT; // Становится темнее при падении
        }
        
        // Добавляем легкое горизонтальное движение для динамики
        final horizontalOffset = math.sin(t * math.pi * 2) * 2;
        
        return Transform.translate(
          offset: Offset(horizontalOffset, translateY),
          child: Transform.scale(
            scale: scale,
            child: Opacity(
              opacity: opacity,
              child: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withOpacity(0.5 * opacity),
                      blurRadius: 8 * scale,
                      spreadRadius: 2 * scale,
                    ),
                    BoxShadow(
                      color: Colors.white.withOpacity(0.3 * opacity),
                      blurRadius: 4 * scale,
                      spreadRadius: 1 * scale,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
