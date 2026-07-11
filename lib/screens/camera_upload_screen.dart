// =============================================================================
// screens/camera_upload_screen.dart
// =============================================================================
// AI photo-to-calorie scanning workflow.
// FLOW: Pick image → Auto-analyze → Show results → Add to log.
// =============================================================================


import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/calorie_provider.dart';
import '../services/ai_api_service.dart';
import '../theme/app_theme.dart';

class CameraUploadScreen extends StatefulWidget {
  const CameraUploadScreen({super.key});

  @override
  State<CameraUploadScreen> createState() => _CameraUploadScreenState();
}

class _CameraUploadScreenState extends State<CameraUploadScreen>
    with TickerProviderStateMixin {
  final ImagePicker _picker = ImagePicker();
  final AIAnalysisService _aiService = AIAnalysisService();

  XFile? _pickedImage;
  bool _isAnalyzing = false;
  Map<String, dynamic>? _analysisResult;
  String? _errorMessage;

  late AnimationController _resultAnimController;
  late Animation<double> _resultSlideAnimation;
  late Animation<double> _resultFadeAnimation;
  late AnimationController _scanLineController;
  late Animation<double> _scanLineAnimation;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    _resultAnimController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _resultSlideAnimation = Tween<double>(begin: 30, end: 0).animate(
        CurvedAnimation(
            parent: _resultAnimController, curve: Curves.easeOutCubic));
    _resultFadeAnimation = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
            parent: _resultAnimController, curve: Curves.easeOut));

    _scanLineController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1500));
    _scanLineAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
            parent: _scanLineController, curve: Curves.easeInOut));

    _pulseController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1000));
    _pulseAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
            parent: _pulseController, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _resultAnimController.dispose();
    _scanLineController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _takePhoto() async {
    try {
      final image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );
      if (image != null) {
        setState(() {
          _pickedImage = image;
          _analysisResult = null;
          _errorMessage = null;
        });
        _analyzeImage();
      }
    } catch (e) {
      setState(() => _errorMessage = 'Failed to access camera: $e');
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      final image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (image != null) {
        setState(() {
          _pickedImage = image;
          _analysisResult = null;
          _errorMessage = null;
        });
        _analyzeImage();
      }
    } catch (e) {
      setState(() => _errorMessage = 'Failed to access gallery: $e');
    }
  }

  Future<void> _analyzeImage() async {
    if (_pickedImage == null) return;

    setState(() {
      _isAnalyzing = true;
      _errorMessage = null;
    });
    _scanLineController.repeat();
    _pulseController.repeat(reverse: true);

    if (mounted) context.read<CalorieProvider>().setAnalyzing(true);

    try {
      // Read image bytes from XFile (works on web + mobile)
      final imageBytes = await _pickedImage!.readAsBytes();

      // Determine MIME type from file name
      final ext = _pickedImage!.name.split('.').last.toLowerCase();
      final mimeType = switch (ext) {
        'png' => 'image/png',
        'webp' => 'image/webp',
        'gif' => 'image/gif',
        _ => 'image/jpeg',
      };

      final result = await _aiService.analyzeImage(imageBytes, mimeType: mimeType);
      if (mounted) {
        setState(() {
          _analysisResult = result;
          _isAnalyzing = false;
        });
        _scanLineController.stop();
        _pulseController.stop();
        _resultAnimController.forward(from: 0);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Analysis failed: $e';
          _isAnalyzing = false;
        });
        _scanLineController.stop();
        _pulseController.stop();
      }
    } finally {
      if (mounted) context.read<CalorieProvider>().setAnalyzing(false);
    }
  }

  Future<void> _addToLog() async {
    if (_analysisResult == null) return;

    await context.read<CalorieProvider>().addFoodItem(
          name: _analysisResult!['name'] as String,
          calories: (_analysisResult!['calories'] as num).toDouble(),
          protein: (_analysisResult!['protein'] as num).toDouble(),
          carbs: (_analysisResult!['carbs'] as num).toDouble(),
          fats: (_analysisResult!['fats'] as num).toDouble(),
          imagePath: _pickedImage?.path,
          isAIScanned: true,
        );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(children: [
            const Icon(Icons.check_circle_rounded,
                color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Text('${_analysisResult!['name']} added!',
                style: GoogleFonts.outfit()),
          ]),
          backgroundColor: AppTheme.primaryDark,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('AI Food Scanner',
            style:
                GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w700)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildImagePreview(),
              const SizedBox(height: 20),
              if (!_isAnalyzing) _buildSourceButtons(),
              if (!_isAnalyzing) const SizedBox(height: 20),
              if (_isAnalyzing) _buildScanningStatus(),
              if (_errorMessage != null) _buildErrorMessage(),
              if (_analysisResult != null) _buildResultCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagePreview() {
    return Container(
      height: 280,
      decoration: BoxDecoration(
        color: AppTheme.cardGrey,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: _isAnalyzing
              ? AppTheme.primaryMint.withOpacity(0.5)
              : AppTheme.primaryMint.withOpacity(0.2),
          width: _isAnalyzing ? 2.5 : 2,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Stack(
          fit: StackFit.expand,
          children: [
            _pickedImage != null
                ? FutureBuilder<Uint8List>(
                    future: _pickedImage!.readAsBytes(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return Image.memory(snapshot.data!, fit: BoxFit.cover);
                      }
                      return const Center(child: CircularProgressIndicator());
                    },
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryMint.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: const Icon(Icons.add_a_photo_rounded,
                            size: 40, color: AppTheme.primaryMint),
                      ),
                      const SizedBox(height: 16),
                      Text('Take or select a photo of your food',
                          style: GoogleFonts.outfit(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.textSecondary)),
                      const SizedBox(height: 6),
                      Text('Supports all phone photo formats (JPEG, PNG)',
                          style: GoogleFonts.outfit(
                              fontSize: 13, color: AppTheme.textTertiary)),
                    ],
                  ),
            if (_isAnalyzing) ...[
              Container(color: Colors.black.withOpacity(0.15)),
              // Scan line animation
              AnimatedBuilder(
                animation: _scanLineAnimation,
                builder: (context, _) {
                  return Positioned(
                    top: _scanLineAnimation.value * 280,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 3,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [
                          Colors.transparent,
                          AppTheme.primaryMint.withOpacity(0.8),
                          AppTheme.primaryMint,
                          AppTheme.primaryMint.withOpacity(0.8),
                          Colors.transparent,
                        ]),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryMint.withOpacity(0.6),
                            blurRadius: 12,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              ..._buildScanCorners(),
              // Center pulse icon
              Center(
                child: AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    return Opacity(
                      opacity: 0.6 + _pulseAnimation.value * 0.4,
                      child: Transform.scale(
                        scale: 0.9 + _pulseAnimation.value * 0.1,
                        child: child,
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.auto_awesome,
                        color: AppTheme.primaryMint, size: 32),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  List<Widget> _buildScanCorners() {
    const cornerSize = 24.0;
    const cornerThickness = 3.0;
    const color = AppTheme.primaryMint;
    const inset = 12.0;

    Widget corner({required Alignment alignment}) {
      return Positioned(
        top: alignment == Alignment.topLeft ||
                alignment == Alignment.topRight
            ? inset
            : null,
        bottom: alignment == Alignment.bottomLeft ||
                alignment == Alignment.bottomRight
            ? inset
            : null,
        left: alignment == Alignment.topLeft ||
                alignment == Alignment.bottomLeft
            ? inset
            : null,
        right: alignment == Alignment.topRight ||
                alignment == Alignment.bottomRight
            ? inset
            : null,
        child: Container(
          width: cornerSize,
          height: cornerSize,
          decoration: BoxDecoration(
            border: Border(
              top: (alignment == Alignment.topLeft ||
                      alignment == Alignment.topRight)
                  ? const BorderSide(
                      color: color, width: cornerThickness)
                  : BorderSide.none,
              bottom: (alignment == Alignment.bottomLeft ||
                      alignment == Alignment.bottomRight)
                  ? const BorderSide(
                      color: color, width: cornerThickness)
                  : BorderSide.none,
              left: (alignment == Alignment.topLeft ||
                      alignment == Alignment.bottomLeft)
                  ? const BorderSide(
                      color: color, width: cornerThickness)
                  : BorderSide.none,
              right: (alignment == Alignment.topRight ||
                      alignment == Alignment.bottomRight)
                  ? const BorderSide(
                      color: color, width: cornerThickness)
                  : BorderSide.none,
            ),
          ),
        ),
      );
    }

    return [
      corner(alignment: Alignment.topLeft),
      corner(alignment: Alignment.topRight),
      corner(alignment: Alignment.bottomLeft),
      corner(alignment: Alignment.bottomRight),
    ];
  }

  Widget _buildSourceButtons() {
    return Row(children: [
      Expanded(
          child: _SourceButton(
              icon: Icons.camera_alt_rounded,
              label: 'Camera',
              onTap: _takePhoto)),
      const SizedBox(width: 12),
      Expanded(
          child: _SourceButton(
              icon: Icons.photo_library_rounded,
              label: 'Gallery',
              onTap: _pickFromGallery)),
    ]);
  }

  Widget _buildScanningStatus() {
    return Container(
      padding: const EdgeInsets.all(24),
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryMint.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(children: [
        SizedBox(
          width: 32,
          height: 32,
          child: CircularProgressIndicator(
            strokeWidth: 3,
            valueColor:
                const AlwaysStoppedAnimation<Color>(AppTheme.primaryMint),
            backgroundColor: AppTheme.primaryMint.withOpacity(0.15),
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Scanning your meal...',
                style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary)),
            const SizedBox(height: 4),
            Text('AI is identifying food & calculating nutrition',
                style: GoogleFonts.outfit(
                    fontSize: 13, color: AppTheme.textSecondary)),
          ],
        )),
      ]),
    );
  }

  Widget _buildErrorMessage() {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: AppTheme.secondaryCoral.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border:
            Border.all(color: AppTheme.secondaryCoral.withOpacity(0.3)),
      ),
      child: Row(children: [
        const Icon(Icons.error_outline_rounded,
            color: AppTheme.secondaryCoral),
        const SizedBox(width: 12),
        Expanded(
            child: Text(_errorMessage!,
                style: GoogleFonts.outfit(
                    color: AppTheme.secondaryCoral, fontSize: 14))),
      ]),
    );
  }

  Widget _buildResultCard() {
    final result = _analysisResult!;
    final calories = (result['calories'] as num).toDouble();
    final protein = (result['protein'] as num).toDouble();
    final carbs = (result['carbs'] as num).toDouble();
    final fats = (result['fats'] as num).toDouble();

    return AnimatedBuilder(
      animation: _resultAnimController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _resultSlideAnimation.value),
          child: Opacity(opacity: _resultFadeAnimation.value, child: child),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppTheme.surfaceWhite,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryMint.withOpacity(0.1),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.primaryMint.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.auto_awesome,
                    color: AppTheme.primaryMint, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('AI Analysis Complete',
                      style: GoogleFonts.outfit(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primaryMint,
                          letterSpacing: 0.5)),
                  const SizedBox(height: 2),
                  Text(result['name'] as String,
                      style: GoogleFonts.outfit(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary)),
                ],
              )),
            ]),
            const SizedBox(height: 24),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [
                  AppTheme.primaryMint.withOpacity(0.08),
                  AppTheme.primaryMint.withOpacity(0.03),
                ]),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.local_fire_department_rounded,
                      color: AppTheme.accentOrange, size: 28),
                  const SizedBox(width: 10),
                  Text('${calories.toInt()}',
                      style: GoogleFonts.outfit(
                          fontSize: 36,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.textPrimary)),
                  const SizedBox(width: 6),
                  Text('kcal',
                      style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.textSecondary)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(children: [
              _ResultMacro(
                  label: 'Protein',
                  value: protein,
                  color: AppTheme.proteinColor,
                  icon: Icons.fitness_center_rounded),
              const SizedBox(width: 12),
              _ResultMacro(
                  label: 'Carbs',
                  value: carbs,
                  color: AppTheme.carbsColor,
                  icon: Icons.grain_rounded),
              const SizedBox(width: 12),
              _ResultMacro(
                  label: 'Fats',
                  value: fats,
                  color: AppTheme.fatsColor,
                  icon: Icons.water_drop_rounded),
            ]),
            const SizedBox(height: 24),
            Row(children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    setState(() => _analysisResult = null);
                    _analyzeImage();
                  },
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: Text('Re-scan',
                      style:
                          GoogleFonts.outfit(fontWeight: FontWeight.w600)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.textSecondary,
                    side: const BorderSide(color: AppTheme.cardGrey),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  onPressed: _addToLog,
                  icon: const Icon(Icons.add_rounded, size: 20),
                  label: Text('Add to Log',
                      style:
                          GoogleFonts.outfit(fontWeight: FontWeight.w600)),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
            ]),
          ],
        ),
      ),
    );
  }
}

class _SourceButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SourceButton(
      {required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.surfaceWhite,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.cardGrey, width: 1.5),
          ),
          child: Column(children: [
            Icon(icon, size: 28, color: AppTheme.primaryMint),
            const SizedBox(height: 8),
            Text(label,
                style: GoogleFonts.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary)),
          ]),
        ),
      ),
    );
  }
}

class _ResultMacro extends StatelessWidget {
  final String label;
  final double value;
  final Color color;
  final IconData icon;

  const _ResultMacro(
      {required this.label,
      required this.value,
      required this.color,
      required this.icon});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(height: 6),
          Text('${value.toInt()}g',
              style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary)),
          const SizedBox(height: 2),
          Text(label,
              style: GoogleFonts.outfit(
                  fontSize: 12, color: AppTheme.textSecondary)),
        ]),
      ),
    );
  }
}
