import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class AvatarUtils {
  // Genera avatar por defecto programáticamente
  static Future<ui.Image> generateDefaultAvatar({
    String initials = 'LR',
    double size = 200.0,
    List<Color> gradientColors = const [
      Color(0xFF6A11CB),
      Color(0xFF2575FC),
    ],
    Color textColor = Colors.white,
  }) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    // Fondo gradiente
    final paint = Paint()
      ..shader = ui.Gradient.linear(
        const Offset(0, 0),
        Offset(size, size),
        gradientColors,
      );

    canvas.drawCircle(Offset(size / 2, size / 2), size / 2, paint);

    // Texto con iniciales
    final paragraphBuilder = ui.ParagraphBuilder(
      ui.ParagraphStyle(
        textAlign: TextAlign.center,
      ),
    )
      ..pushStyle(ui.TextStyle(
        color: textColor,
        fontSize: size * 0.3,
        fontWeight: FontWeight.bold,
      ))
      ..addText(_getInitials(initials));

    final paragraph = paragraphBuilder.build()
      ..layout(ui.ParagraphConstraints(width: size));

    // Centrar texto
    final textWidth = paragraph.width;
    final textHeight = paragraph.height;
    final x = (size - textWidth) / 2;
    final y = (size - textHeight) / 2;

    canvas.drawParagraph(paragraph, Offset(x, y));

    final picture = recorder.endRecording();
    return await picture.toImage(size.toInt(), size.toInt());
  }

  // Obtiene iniciales del nombre
  static String _getInitials(String name) {
    if (name.isEmpty) return 'LR';

    final parts = name.trim().split(' ');
    if (parts.length == 1) {
      return parts[0].length >= 2
          ? parts[0].substring(0, 2).toUpperCase()
          : parts[0].toUpperCase();
    }

    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  // Convierte ui.Image a ImageProvider
  static Future<ImageProvider> generateAvatarProvider({
    String? name,
    double size = 200.0,
  }) async {
    try {
      final image = await generateDefaultAvatar(
        initials: name ?? 'LR',
        size: size,
      );
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final bytes = byteData!.buffer.asUint8List();
      return MemoryImage(bytes);
    } catch (e) {
      // Fallback a AssetImage
      return getDefaultAvatarProvider();
    }
  }

  // ImageProvider desde assets (FALLBACK: Generado dinámicamente si no hay asset)
  static ImageProvider getDefaultAvatarProvider() {
    // En lugar de asset, retornamos un placeholder seguro temporalmente o
    // idealmente deberíamos hacer esto asíncrono, pero ImageProvider puede ser síncrono.
    // Para simplificar y evitar problemas de assets faltantes:
    return const AssetImage('assets/images/default_avatar.png');
    // NOTA: Si el asset falla, Flutter lanzará error en consola.
    // Mejor opción: Reemplazar el uso directo de este método por generateAvatarProvider.
  }

  // Widget completo de avatar con todos los casos
  static Widget buildAvatar({
    String? imageUrl,
    String? name,
    double radius = 40.0,
    bool isPaid = false,
    double revelationLevel = 1.0, // 0.0 a 1.0
    bool showRevealButton = false,
    VoidCallback? onRevealPressed,
    int availableTokens = 0,
  }) {
    return _AvatarWidget(
      imageUrl: imageUrl,
      name: name,
      radius: radius,
      isPaid: isPaid,
      revelationLevel: revelationLevel,
      showRevealButton: showRevealButton,
      onRevealPressed: onRevealPressed,
      availableTokens: availableTokens,
    );
  }
}

// Widget privado con toda la lógica
class _AvatarWidget extends StatelessWidget {
  final String? imageUrl;
  final String? name;
  final double radius;
  final bool isPaid;
  final double revelationLevel;
  final bool showRevealButton;
  final VoidCallback? onRevealPressed;
  final int availableTokens;

  const _AvatarWidget({
    required this.imageUrl,
    required this.name,
    required this.radius,
    required this.isPaid,
    required this.revelationLevel,
    required this.showRevealButton,
    this.onRevealPressed,
    this.availableTokens = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Avatar principal
        Container(
          width: radius * 2,
          height: radius * 2,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: isPaid ? Colors.yellow : Colors.grey,
              width: isPaid ? 2.0 : 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 8,
                spreadRadius: 2,
              ),
            ],
          ),
          child: ClipOval(
            child: _buildAvatarContent(),
          ),
        ),

        // Efecto de pixelación para free users
        if (!isPaid && revelationLevel < 1.0) _buildPixelationOverlay(),

        // Botón de revelar
        if (showRevealButton && !isPaid && revelationLevel < 1.0)
          _buildRevealButton(),

        // Badge premium
        if (isPaid)
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.yellow,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: Icon(
                Icons.workspace_premium,
                size: radius * 0.3,
                color: Colors.black,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildAvatarContent() {
    // Si es usuario PAID o está 100% revelado, mostrar imagen normal
    if (isPaid || revelationLevel >= 1.0) {
      return _buildFullAvatar();
    }

    // Para free users con revelación parcial
    return Stack(
      children: [
        // Imagen base (pixelada/oscura)
        ColorFiltered(
          colorFilter: ColorFilter.mode(
            Colors.black.withValues(alpha: 0.7),
            BlendMode.darken,
          ),
          child: _buildFullAvatar(),
        ),

        // Porcentaje revelado
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Colors.black.withValues(alpha: 1 - revelationLevel),
              ],
            ),
          ),
        ),

        // Indicador de porcentaje
        Center(
          child: Text(
            '${(revelationLevel * 100).toInt()}%',
            style: TextStyle(
              color: Colors.white,
              fontSize: radius * 0.25,
              fontWeight: FontWeight.bold,
              shadows: const [
                Shadow(
                  color: Colors.black,
                  blurRadius: 4,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFullAvatar() {
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: imageUrl!,
        fit: BoxFit.cover,
        placeholder: (context, url) => _buildPlaceholder(),
        errorWidget: (context, url, error) => _buildPlaceholder(),
      );
    }

    return FutureBuilder<ImageProvider>(
      future: AvatarUtils.generateAvatarProvider(
        name: name,
        size: radius * 2,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.hasData) {
          return Image(
            image: snapshot.data!,
            fit: BoxFit.cover,
          );
        }
        return _buildPlaceholder();
      },
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Text(
          AvatarUtils._getInitials(name ?? 'LR'),
          style: TextStyle(
            color: Colors.white,
            fontSize: radius * 0.6,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildPixelationOverlay() {
    return IgnorePointer(
      child: Container(
        width: radius * 2,
        height: radius * 2,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.black.withValues(alpha: 0.3),
        ),
        child: CustomPaint(
          painter: _PixelationPainter(
            pixelSize: 8.0,
            opacity: 1.0 - revelationLevel,
          ),
        ),
      ),
    );
  }

  Widget _buildRevealButton() {
    return Positioned.fill(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onRevealPressed,
          borderRadius: BorderRadius.circular(radius),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black.withValues(alpha: 0.5),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.visibility,
                    color: Colors.yellow,
                    size: radius * 0.5,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'REVELAR\n($availableTokens token${availableTokens != 1 ? 's' : ''})',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.yellow,
                      fontSize: radius * 0.15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Painter para efecto de pixelación
class _PixelationPainter extends CustomPainter {
  final double pixelSize;
  final double opacity;

  _PixelationPainter({
    required this.pixelSize,
    required this.opacity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withValues(alpha: opacity * 0.3);

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Dibujar cuadrícula de pixelación
    for (double x = 0; x < size.width; x += pixelSize) {
      for (double y = 0; y < size.height; y += pixelSize) {
        final point = Offset(x, y);
        final distance = (point - center).distance;

        if (distance <= radius) {
          // Aleatorizar opacidad para efecto pixelado
          final randomOpacity = opacity * (0.5 + (x * y % 100) / 200);
          paint.color = Colors.black.withValues(alpha: randomOpacity);

          canvas.drawRect(
            Rect.fromLTWH(x, y, pixelSize, pixelSize),
            paint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant _PixelationPainter oldDelegate) {
    return oldDelegate.pixelSize != pixelSize || oldDelegate.opacity != opacity;
  }
}

// Widget para lista de avatares
class AvatarGrid extends StatelessWidget {
  final List<Map<String, dynamic>> users;
  final bool isPaidUser;
  final Function(int) onUserTap;
  final Function(int)? onRevealTap;

  const AvatarGrid({
    super.key,
    required this.users,
    required this.isPaidUser,
    required this.onUserTap,
    this.onRevealTap,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.8,
      ),
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];
        return GestureDetector(
          onTap: () => onUserTap(index),
          child: Column(
            children: [
              // Avatar
              AvatarUtils.buildAvatar(
                imageUrl: user['photoUrl'],
                name: user['name'],
                radius: 50,
                isPaid: isPaidUser,
                revelationLevel: user['revelationLevel'] ?? 1.0,
                showRevealButton:
                    !isPaidUser && (user['revelationLevel'] ?? 1.0) < 1.0,
                onRevealPressed:
                    onRevealTap != null ? () => onRevealTap!(index) : null,
                availableTokens: user['availableTokens'] ?? 0,
              ),

              const SizedBox(height: 8),

              // Nombre
              Text(
                user['name'] ?? 'Usuario',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),

              // Distancia
              if (user['distance'] != null)
                Text(
                  '${user['distance'].toStringAsFixed(1)} km',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),

              // Compatibilidad
              if (user['compatibility'] != null)
                Chip(
                  label: Text('${user['compatibility']}%'),
                  backgroundColor:
                      _getCompatibilityColor(user['compatibility']),
                  labelStyle: const TextStyle(
                    fontSize: 10,
                    color: Colors.white,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Color _getCompatibilityColor(int compatibility) {
    if (compatibility >= 80) return Colors.green;
    if (compatibility >= 60) return Colors.yellow;
    return Colors.orange;
  }
}
