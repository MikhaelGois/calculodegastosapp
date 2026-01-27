import 'package:flutter/material.dart';
import '../services/watermark_service.dart';

/// Widget que exibe a marca d'água em tempo real
class WatermarkOverlay extends StatelessWidget {
  final WatermarkData watermarkData;
  final Alignment alignment;
  final double fontSize;
  final Color textColor;
  final double opacity;

  const WatermarkOverlay({
    Key? key,
    required this.watermarkData,
    this.alignment = Alignment.bottomLeft,
    this.fontSize = 12,
    this.textColor = Colors.white,
    this.opacity = 0.9,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final lines = WatermarkService.formatWatermarkLines(watermarkData);

    return Positioned.fill(
      child: Align(
        alignment: alignment,
        child: Container(
          padding: const EdgeInsets.all(8),
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
            borderRadius: BorderRadius.circular(4),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment:
                  alignment == Alignment.bottomLeft ||
                      alignment == Alignment.topLeft
                  ? CrossAxisAlignment.start
                  : CrossAxisAlignment.end,
              children: [
                for (var i = 0; i < lines.length; i++)
                  Text(
                    lines[i],
                    style: TextStyle(
                      color: textColor.withOpacity(opacity),
                      fontSize: fontSize,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'monospace',
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Widget exibido durante a gravação mostrando marca d'água em tempo real
class RecordingWatermarkWidget extends StatefulWidget {
  final WatermarkData watermarkData;
  final Alignment alignment;
  final bool isRecording;

  const RecordingWatermarkWidget({
    Key? key,
    required this.watermarkData,
    this.alignment = Alignment.bottomLeft,
    this.isRecording = true,
  }) : super(key: key);

  @override
  State<RecordingWatermarkWidget> createState() =>
      _RecordingWatermarkWidgetState();
}

class _RecordingWatermarkWidgetState extends State<RecordingWatermarkWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Opacity(
          opacity: 0.7 + (_pulseController.value * 0.3),
          child: WatermarkOverlay(
            watermarkData: widget.watermarkData,
            alignment: widget.alignment,
            fontSize: 13,
            opacity: 1.0,
          ),
        );
      },
    );
  }
}

/// Exibir marca d'água em um card para visualização
class WatermarkPreviewCard extends StatelessWidget {
  final WatermarkData watermarkData;
  final bool showCamera;

  const WatermarkPreviewCard({
    Key? key,
    required this.watermarkData,
    this.showCamera = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final lines = WatermarkService.formatWatermarkLines(watermarkData);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.amber, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.watermark, color: Colors.amber, size: 18),
                const SizedBox(width: 8),
                const Text(
                  'Marca d\'água',
                  style: TextStyle(
                    color: Colors.amber,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...lines.map(
              (line) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Text(
                  line,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget para copiar dados de marca d'água
class CopyWatermarkButton extends StatefulWidget {
  final WatermarkData watermarkData;

  const CopyWatermarkButton({Key? key, required this.watermarkData})
    : super(key: key);

  @override
  State<CopyWatermarkButton> createState() => _CopyWatermarkButtonState();
}

class _CopyWatermarkButtonState extends State<CopyWatermarkButton> {
  bool _copied = false;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: _copied
          ? null
          : () async {
              // Copiar para clipboard (implementar conforme necessário)
              setState(() => _copied = true);
              await Future.delayed(const Duration(seconds: 2));
              if (mounted) {
                setState(() => _copied = false);
              }
            },
      icon: Icon(_copied ? Icons.check : Icons.copy),
      label: Text(_copied ? 'Copiado!' : 'Copiar'),
    );
  }
}
