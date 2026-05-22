import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/utils/group_share_codec.dart';

/// Full-screen camera viewport that scans group QR codes.
/// Returns the decoded [GroupPayload] via Navigator.pop when a valid one is read.
class GroupQrScannerScreen extends StatefulWidget {
  const GroupQrScannerScreen({super.key});

  @override
  State<GroupQrScannerScreen> createState() => _GroupQrScannerScreenState();
}

class _GroupQrScannerScreenState extends State<GroupQrScannerScreen> {
  final MobileScannerController _controller = MobileScannerController(
    formats: const [BarcodeFormat.qrCode],
    detectionSpeed: DetectionSpeed.normal,
  );

  bool _handled = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_handled) return;
    final raw = capture.barcodes.firstOrNull?.rawValue;
    if (raw == null || raw.isEmpty) return;

    final result = decodeGroup(raw);
    if (!result.isSuccess) {
      _showError(result.error!);
      return;
    }

    _handled = true;
    _controller.stop();
    Navigator.pop(context, result.payload);
  }

  void _showError(GroupDecodeError error) {
    final l = AppLocalizations.of(context);
    final msg = switch (error) {
      GroupDecodeError.unsupportedVersion => l.updateSplitliToImport,
      GroupDecodeError.tooLarge => l.groupQrTooLarge,
      GroupDecodeError.malformed ||
      GroupDecodeError.empty =>
        l.groupQrMalformed,
      GroupDecodeError.notSplitliPayload => l.notASplitliQr,
    };
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(msg),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: _onDetect,
            errorBuilder: (_, _) => _PermissionFallback(l: l),
          ),
          // Dimmed overlay with a transparent square cutout for framing.
          IgnorePointer(
            child: CustomPaint(
              painter: _ScannerOverlayPainter(),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 4, 16, 0),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close_rounded,
                            color: Colors.white),
                      ),
                      Expanded(
                        child: Text(
                          l.scanGroupQr,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
                  child: Text(
                    l.scanWithSplitli,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PermissionFallback extends StatelessWidget {
  const _PermissionFallback({required this.l});
  final AppLocalizations l;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      alignment: Alignment.center,
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.no_photography_rounded,
              size: 48, color: Colors.white.withValues(alpha: 0.6)),
          const SizedBox(height: 12),
          Text(
            l.scanGroupQr,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _ScannerOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cutoutSide = size.shortestSide * 0.7;
    final center = Offset(size.width / 2, size.height / 2);
    final cutoutRect = Rect.fromCenter(
      center: center,
      width: cutoutSide,
      height: cutoutSide,
    );
    final cutoutRRect = RRect.fromRectAndRadius(
      cutoutRect,
      const Radius.circular(20),
    );

    final overlay = Path()..addRect(Offset.zero & size);
    final cutout = Path()..addRRect(cutoutRRect);
    final dimmed = Path.combine(PathOperation.difference, overlay, cutout);

    canvas.drawPath(
      dimmed,
      Paint()..color = Colors.black.withValues(alpha: 0.55),
    );

    // Bright border around the cutout.
    canvas.drawRRect(
      cutoutRRect,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  @override
  bool shouldRepaint(_ScannerOverlayPainter oldDelegate) => false;
}
