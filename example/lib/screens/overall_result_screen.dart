import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_unity_widget_example/firebase_service.dart';
import 'package:flutter_unity_widget_example/services/user_view_model.dart';
import 'package:flutter_unity_widget_example/widgets/app_drawer.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

class OverallResultScreen extends StatefulWidget {
  final bool allCourseDone;

  const OverallResultScreen({super.key, required this.allCourseDone});

  static const Color yellowish = Color(0xFFFFF59D);
  static const Color royalBlue = Color(0xFF1E3A8A);

  @override
  State<OverallResultScreen> createState() => _OverallResultScreenState();
}

class _OverallResultScreenState extends State<OverallResultScreen> {
  bool _isDownloading = false;
  final GlobalKey _certificateKey = GlobalKey();
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _currentUserId = FirebaseService.currentUsersId;
    if (_currentUserId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        context.read<UserViewModel>().listenToUser(_currentUserId!);
      });
    }
  }

  Future<void> _downloadCertificate(BuildContext context) async {
    if (kIsWeb) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Downloading is not supported on the web yet.'),
        ),
      );
      return;
    }

    final boundary = _certificateKey.currentContext?.findRenderObject()
        as RenderRepaintBoundary?;

    if (boundary == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to prepare certificate preview.'),
        ),
      );
      return;
    }

    setState(() => _isDownloading = true);

    try {
      final ui.Image image = await boundary.toImage(pixelRatio: 7);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

      if (byteData == null) {
        throw Exception('Failed to encode certificate image.');
      }

      final bytes = byteData.buffer
          .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes);
      final timestamp = DateTime.now().millisecondsSinceEpoch;

      if (Platform.isAndroid || Platform.isIOS) {
        final hasPermission = await _requestGalleryPermission();
        if (!hasPermission) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  'Permission denied. Unable to save certificate to gallery.'),
            ),
          );
          return;
        }

        final tempDir = await getTemporaryDirectory();
        final tempPath = '${tempDir.path}/CyberAR_certificate_$timestamp.png';
        final tempFile = File(tempPath);
        await tempFile.writeAsBytes(bytes);

        final saved = await GallerySaver.saveImage(
              tempPath,
              albumName: 'CyberAR',
            ) ??
            false;

        if (await tempFile.exists()) {
          await tempFile.delete();
        }

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(saved
                ? 'Certificate saved to your gallery.'
                : 'Failed to save certificate to gallery.'),
          ),
        );
      } else {
        final directory = await getApplicationDocumentsDirectory();
        final filePath = '${directory.path}/CyberAR_certificate_$timestamp.png';
        final file = File(filePath);

        await file.writeAsBytes(bytes);

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Certificate saved to $filePath (copy to gallery if needed).'),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save certificate: $e'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isDownloading = false);
      }
    }
  }

  // REQUEST GALLERY PERMISSION
  Future<bool> _requestGalleryPermission() async {
    if (Platform.isAndroid) {
      final photosStatus = await Permission.photos.request();
      if (photosStatus.isGranted) {
        return true;
      }

      final storageStatus = await Permission.storage.request();
      return storageStatus.isGranted;
    } else if (Platform.isIOS) {
      final status = await Permission.photosAddOnly.request();
      return status.isGranted;
    }
    return true;
  }

  // SHOW CERTIFICATE PREVIEW
  Future<void> _showCertificatePreview(BuildContext context) async {
    final userName =
        context.read<UserViewModel>().user?.name ?? 'CyberAR Student';
    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(16),
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.all(12),
                child: InteractiveViewer(
                  minScale: 0.8,
                  maxScale: 4,
                  child: ClipRRect(
                    child: _buildCertificateCanvas(userName),
                  ),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Material(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(20),
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final userName =
        context.watch<UserViewModel>().user?.name ?? 'CyberAR Student';
    return Scaffold(
      backgroundColor: OverallResultScreen.yellowish,
      drawer: const AppDrawer(userType: 'student'),
      appBar: AppBar(
        backgroundColor: OverallResultScreen.royalBlue,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: const Text(
          'Course Progress',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (widget.allCourseDone)
                  _buildCompletedContent(context, userName)
                else
                  _buildIncompleteContent(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCompletedContent(BuildContext context, String studentName) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          padding: const EdgeInsets.all(16),
          child: GestureDetector(
            onTap: () => _showCertificatePreview(context),
            child: RepaintBoundary(
              key: _certificateKey,
              child: ClipRRect(
                child: SizedBox(
                  width: 320,
                  child: _buildCertificateCanvas(studentName),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Congratulations! 🎉',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        const Text(
          'You can now download your completion certificate.',
          style: TextStyle(fontSize: 16),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        TextButton.icon(
          onPressed:
              _isDownloading ? null : () => _downloadCertificate(context),
          icon: _isDownloading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.download_rounded),
          label: Text(
            _isDownloading ? 'Preparing...' : 'Download Certificate',
          ),
          style: TextButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Colors.blueAccent,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        const SizedBox(height: 16),
        _buildBackButton(context),
      ],
    );
  }

  Widget _buildIncompleteContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.hourglass_empty_rounded,
          size: 120,
          color: Colors.black54,
        ),
        const SizedBox(height: 24),
        const Text(
          'You\'re not done yet! You haven\'t completed all the modules and quizzes.',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        const Text(
          'Make sure to finish each module and pass the quizzes to unlock your final result.',
          style: TextStyle(fontSize: 16),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        const Text(
          'Come back once you\'re done – you\'re almost there!',
          style: TextStyle(fontSize: 16),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        _buildBackButton(context),
      ],
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () => Navigator.of(context).maybePop(),
      icon: const Icon(Icons.arrow_back_rounded),
      label: const Text('Back to Courses'),
      style: ElevatedButton.styleFrom(
        backgroundColor: OverallResultScreen.royalBlue,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildCertificateCanvas(String studentName) {
    const aspectRatio = 2000 / 1414;
    final displayName =
        studentName.trim().isEmpty ? 'CyberAR Student' : studentName.trim();

    return AspectRatio(
      aspectRatio: aspectRatio,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/orig_certificate.png',
            fit: BoxFit.cover,
          ),
          Align(
            alignment: const Alignment(0, -0.08),
            child: LayoutBuilder(
              builder: (context, constraints) {
                const originalWidthPx = 2000.0;
                const nameLineWidthPx = 1300.0;
                final nameBoxWidth =
                    constraints.maxWidth * (nameLineWidthPx / originalWidthPx);

                final baseFontSize =
                    (constraints.maxWidth / originalWidthPx) * 160;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: SizedBox(
                    width: nameBoxWidth,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.center,
                      child: Text(
                        displayName.toUpperCase(),
                        maxLines: 1,
                        softWrap: false,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: baseFontSize,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                          letterSpacing: 0.8,
                          fontFamily: 'Times New Roman',
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
