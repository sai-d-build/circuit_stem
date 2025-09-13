import 'dart:math';
import 'package:flutter/material.dart';
import 'package:sparkcircuit/presentation/theme/app_theme.dart';

class ParticleEffect extends StatefulWidget {
  final int numberOfParticles;
  final Color particleColor;
  final double particleSize;
  final Duration animationDuration;
  final bool enablePhysics;
  final double gravity;
  final Offset? spawnPosition;

  const ParticleEffect({
    super.key,
    this.numberOfParticles = 50,
    required this.particleColor,
    this.particleSize = 3.0,
    this.animationDuration = const Duration(seconds: 5),
    this.enablePhysics = true,
    this.gravity = 0.1,
    this.spawnPosition,
  });

  @override
  State<ParticleEffect> createState() => _ParticleEffectState();
}

class _ParticleEffectState extends State<ParticleEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<_Particle> _particles = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    )..repeat();

    _controller.addListener(() {
      setState(_updateParticles);
    });

    _initParticles();
  }

  void _initParticles() {
    final centerX = widget.spawnPosition?.dx ?? 0.5;
    final centerY = widget.spawnPosition?.dy ?? 0.5;

    for (var i = 0; i < widget.numberOfParticles; i++) {
      final angle = _random.nextDouble() * 2 * pi;
      final speed = _random.nextDouble() * 0.01 + 0.005;

      _particles.add(_Particle(
        position: Offset(centerX, centerY),
        velocity: Offset(
          cos(angle) * speed,
          sin(angle) * speed,
        ),
        life: _random.nextDouble() * 0.8 + 0.2, // 0.2 to 1.0
        size: _random.nextDouble() * widget.particleSize +
            widget.particleSize * 0.5,
      ));
    }
  }

  void _updateParticles() {
    for (var i = 0; i < widget.numberOfParticles; i++) {
      final particle = _particles[i];

      // Update position
      particle.position = particle.position + particle.velocity;

      // Apply gravity if enabled
      if (widget.enablePhysics) {
        particle.velocity =
            particle.velocity + Offset(0, widget.gravity * 0.001);
      }

      // Update life
      particle.life -= 0.02;

      // Reset particle if dead or out of bounds
      if (particle.life <= 0 ||
          particle.position.dx < -0.2 ||
          particle.position.dx > 1.2 ||
          particle.position.dy < -0.2 ||
          particle.position.dy > 1.2) {
        _resetParticle(particle);
      }
    }
  }

  void _resetParticle(_Particle particle) {
    final centerX = widget.spawnPosition?.dx ?? 0.5;
    final centerY = widget.spawnPosition?.dy ?? 0.5;

    final angle = _random.nextDouble() * 2 * pi;
    final speed = _random.nextDouble() * 0.01 + 0.005;

    particle.position = Offset(centerX, centerY);
    particle.velocity = Offset(
      cos(angle) * speed,
      sin(angle) * speed,
    );
    particle.life = _random.nextDouble() * 0.8 + 0.2;
    particle.size =
        _random.nextDouble() * widget.particleSize + widget.particleSize * 0.5;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _ParticlePainter(
        particles: _particles,
        particleColor: widget.particleColor,
      ),
      child: Container(),
    );
  }
}

class _Particle {
  Offset position;
  Offset velocity;
  double life;
  double size;

  _Particle({
    required this.position,
    required this.velocity,
    required this.life,
    required this.size,
  });
}

class _ParticlePainter extends CustomPainter {
  final List<_Particle> particles;
  final Color particleColor;

  _ParticlePainter({
    required this.particles,
    required this.particleColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      if (particle.life <= 0) continue;

      final paint = Paint()
        ..color = particleColor.withValues(alpha: particle.life)
        ..style = PaintingStyle.fill;

      // Add glow effect
      final glowPaint = Paint()
        ..color = particleColor.withValues(alpha: particle.life * 0.3)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, particle.size);

      final center = Offset(
        particle.position.dx * size.width,
        particle.position.dy * size.height,
      );

      // Draw glow
      canvas.drawCircle(center, particle.size * 2, glowPaint);

      // Draw particle
      canvas.drawCircle(center, particle.size * particle.life, paint);
    }
  }

  @override
  bool shouldRepaint(_ParticlePainter oldDelegate) => true;
}

// Pre-configured effects
class SparkEffect extends StatelessWidget {
  final Offset? position;

  const SparkEffect({super.key, this.position});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<CircuitColorScheme>()!;
    return ParticleEffect(
      numberOfParticles: 20,
      particleColor: colors.energyPulse,
      particleSize: 2,
      animationDuration: const Duration(milliseconds: 800),
      enablePhysics: false,
      spawnPosition: position,
    );
  }
}

class FireworkEffect extends StatelessWidget {
  final Offset? position;

  const FireworkEffect({super.key, this.position});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<CircuitColorScheme>()!;
    return ParticleEffect(
      numberOfParticles: 100,
      particleColor: colors.neonAccent,
      particleSize: 4,
      animationDuration: const Duration(seconds: 2),
      enablePhysics: true,
      gravity: 0.05,
      spawnPosition: position,
    );
  }
}
