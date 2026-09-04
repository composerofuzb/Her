import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

class QrPairingDialog extends StatelessWidget {
  final String sisterName;
  final String sisterEmail;

  const QrPairingDialog({
    super.key,
    required this.sisterName,
    required this.sisterEmail,
  });

  static void show(BuildContext context, {required String sisterName, required String sisterEmail}) {
    showDialog(
      context: context,
      builder: (_) => QrPairingDialog(
        sisterName: sisterName,
        sisterEmail: sisterEmail,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.nebulaCard,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Pair Sister\'s Phone', style: AppTypography.titleLarge),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white38),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Simulated High-Contrast QR Code container
            Container(
              width: 180,
              height: 180,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.starGold, width: 2),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CustomPaint(
                    size: const Size(150, 150),
                    painter: _QrPatternPainter(),
                  ),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.cosmicPurple,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Text('⭐', style: TextStyle(fontSize: 16)),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
            Text(
              'Scan on $sisterName\'s Phone',
              style: AppTypography.titleMedium.copyWith(color: AppColors.starGold),
            ),
            const SizedBox(height: 6),
            Text(
              'Or sign in directly using her account:\n$sisterEmail',
              style: AppTypography.bodySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.cosmicPurple,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Done'),
            ),
          ],
        ),
      ),
    );
  }
}

class _QrPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black87
      ..style = PaintingStyle.fill;

    // Corner squares
    const squareSize = 35.0;
    canvas.drawRect(const Rect.fromLTWH(0, 0, squareSize, squareSize), paint);
    canvas.drawRect(Rect.fromLTWH(size.width - squareSize, 0, squareSize, squareSize), paint);
    canvas.drawRect(Rect.fromLTWH(0, size.height - squareSize, squareSize, squareSize), paint);

    // Grid dots simulation
    const step = 14.0;
    for (double x = 40; x < size.width - 40; x += step) {
      for (double y = 10; y < size.height - 10; y += step) {
        if ((x.toInt() + y.toInt()) % 3 == 0) {
          canvas.drawRect(Rect.fromLTWH(x, y, 7, 7), paint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(_QrPatternPainter old) => false;
}
