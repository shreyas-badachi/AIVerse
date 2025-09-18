import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:animate_do/animate_do.dart';
import 'package:lottie/lottie.dart';
import 'package:google_fonts/google_fonts.dart';
import 'login_page.dart'; // Import the LoginPage
import 'API_Interfaces/Hugging_DeepSeek_R1.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _controller = TextEditingController();
  String _resultText = '';
  Uint8List? _imageBytes;
  Uint8List? _editedImageBytes;
  String? _videoUrl;
  VideoPlayerController? _videoController;

  String _selectedMode = 'Text';
  bool _isLoading = false;

  final ImagePicker _picker = ImagePicker();
  Uint8List? _selectedImageForEdit;

  Future<void> _pickImage() async {
    final XFile? file = await _picker.pickImage(source: ImageSource.gallery);
    if (file != null) {
      _selectedImageForEdit = await file.readAsBytes();
      setState(() {});
    }
  }

  Future<void> _generate() async {
    final input = _controller.text.trim();
    if (input.isEmpty) return;

    setState(() {
      _isLoading = true;
      _resultText = '';
      _imageBytes = null;
      _editedImageBytes = null;
      _videoUrl = null;
    });

    if (_selectedMode == 'Text') {
      final result = await ApiService.generateText(input);
      setState(() => _resultText = result);
    } else if (_selectedMode == 'Image') {
      final result = await ApiService.generateImage(input);
      setState(() => _imageBytes = result);
    } else if (_selectedMode == 'Image Edit') {
      if (_selectedImageForEdit == null) {
        setState(() => _resultText = 'Please select an image to edit.');
      } else {
        final result = await ApiService.imageToImage(
          input,
          _selectedImageForEdit!,
        );
        setState(() => _editedImageBytes = result);
      }
    } else if (_selectedMode == 'Video') {
      final result = await ApiService.generateVideo(input);
      if (result != null) {
        _videoController = VideoPlayerController.network(result)
          ..initialize().then((_) {
            setState(() {
              _videoUrl = result;
              _videoController?.play();
            });
          });
      }
    }

    setState(() => _isLoading = false);
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
  }

  @override
  void dispose() {
    _videoController?.dispose();
    _controller.dispose();
    super.dispose();
  }

  // Custom Neumorphic Container
  Widget _neumorphicContainer({
    required Widget child,
    double borderRadius = 16,
    double? height,
    EdgeInsets? padding,
  }) {
    return Container(
      width: double.infinity,
      height: height,
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.white.withOpacity(0.8),
            offset: const Offset(-6, -6),
            blurRadius: 12,
            spreadRadius: 1,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            offset: const Offset(6, 6),
            blurRadius: 12,
            spreadRadius: 1,
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.3),
            offset: const Offset(-2, -2),
            blurRadius: 4,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            offset: const Offset(2, 2),
            blurRadius: 4,
          ),
        ],
      ),
      child: child,
    );
  }

  // Custom Neumorphic Button
  Widget _neumorphicButton({
    required VoidCallback onPressed,
    required String text,
    Color textColor = Colors.black,
    double borderRadius = 16,
    double height = 50,
    Color accentColor = Colors.transparent,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: AnimatedContainer(
        margin: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
        duration: const Duration(milliseconds: 150),
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(borderRadius),
          border: accentColor != Colors.transparent
              ? Border.all(color: accentColor.withOpacity(0.3), width: 2)
              : null,
          boxShadow: [
            BoxShadow(
              color: Colors.white.withOpacity(0.8),
              offset: const Offset(-6, -6),
              blurRadius: 12,
              spreadRadius: 1,
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              offset: const Offset(6, 6),
              blurRadius: 12,
              spreadRadius: 1,
            ),
            BoxShadow(
              color: Colors.white.withOpacity(0.4),
              offset: const Offset(-3, -3),
              blurRadius: 6,
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              offset: const Offset(3, 3),
              blurRadius: 6,
            ),
          ],
        ),
        child: Center(
          child: Text(
            text,
            style: GoogleFonts.roboto(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ),
      ),
    );
  }

  // Custom Neumorphic Selection Card
  Widget _neumorphicSelectionCard({
    required String mode,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () => setState(() => _selectedMode = mode),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 100,
        height: 50,
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: isSelected
              ? Border.all(color: Colors.deepPurple.withOpacity(0.5), width: 2)
              : null,
          boxShadow: [
            BoxShadow(
              color: Colors.white.withOpacity(0.8),
              offset: const Offset(-4, -4),
              blurRadius: 8,
              spreadRadius: 1,
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              offset: const Offset(4, 4),
              blurRadius: 8,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Center(
          child: Text(
            mode,
            style: GoogleFonts.roboto(
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected ? Colors.deepPurple : Colors.black,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    Shader linearGradient = const LinearGradient(
      colors: <Color>[Colors.purple, Colors.blue, Colors.cyan],
    ).createShader(const Rect.fromLTWH(0.0, 0.0, 200.0, 70.0));

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          user == null ? 'Login' : 'AI Playground',
          style: GoogleFonts.roboto(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        actions: [
          if (user != null)
            IconButton(
              icon: const Icon(Icons.logout, color: Colors.black54),
              onPressed: _logout,
            ),
        ],
      ),
      body: user == null
          ? const LoginPage()
          : _buildPlaygroundUI(linearGradient),
    );
  }

  // -------------------- AI PLAYGROUND UI --------------------
  Widget _buildPlaygroundUI(Shader linearGradient) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: FadeInUp(
              duration: const Duration(milliseconds: 800),
              child: Column(
                children: [
                  // Lottie Animation
                  Lottie.asset(
                    'assets/lottie/UgCISD3W42.json',
                    width: 150,
                    height: 150,
                    fit: BoxFit.contain,
                  ),
                  // Title
                  Text(
                    'AI Playground',
                    style: GoogleFonts.roboto(
                      fontSize: 36,
                      fontWeight: FontWeight.w900,
                      foreground: Paint()..shader = linearGradient,
                      letterSpacing: 2.0,
                      shadows: [
                        Shadow(
                          blurRadius: 8.0,
                          color: Colors.black.withOpacity(0.15),
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 15),
                  // Input box
                  _neumorphicContainer(
                    borderRadius: 20,
                    height: 60,
                    padding: const EdgeInsets.all(16),
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: 'Enter your prompt...',
                        hintStyle: GoogleFonts.roboto(
                          color: Colors.black54,
                          fontSize: 16,
                        ),
                        border: InputBorder.none,
                      ),
                      style: GoogleFonts.roboto(
                        color: Colors.black,
                        fontSize: 16,
                      ),
                      maxLines: null,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Pick Image Button (if Image Edit mode)
                  if (_selectedMode == 'Image Edit')
                    FadeInUp(
                      duration: const Duration(milliseconds: 1000),
                      child: _neumorphicButton(
                        onPressed: _pickImage,
                        text: 'Select Image',
                        textColor: Colors.black,
                        accentColor: Colors.blue,
                        borderRadius: 20,
                        height: 60,
                      ),
                    ),
                  if (_selectedImageForEdit != null &&
                      _selectedMode == 'Image Edit') ...[
                    const SizedBox(height: 24),
                    FadeInUp(
                      duration: const Duration(milliseconds: 1000),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.memory(
                          _selectedImageForEdit!,
                          height: 150,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  // Generated Content
                  if (_isLoading)
                    const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                      strokeWidth: 3,
                    ),
                  if (!_isLoading) ...[
                    if (_resultText.isNotEmpty)
                      FadeInUp(
                        duration: const Duration(milliseconds: 1000),
                        child: _neumorphicContainer(
                          borderRadius: 20,
                          height: null,
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            _resultText,
                            style: GoogleFonts.roboto(
                              fontSize: 16,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                    if (_imageBytes != null)
                      FadeInUp(
                        duration: const Duration(milliseconds: 1000),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.memory(
                            _imageBytes!,
                            height: 300,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    if (_editedImageBytes != null)
                      FadeInUp(
                        duration: const Duration(milliseconds: 1000),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.memory(
                            _editedImageBytes!,
                            height: 300,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    if (_videoUrl != null &&
                        _videoController != null &&
                        _videoController!.value.isInitialized)
                      FadeInUp(
                        duration: const Duration(milliseconds: 1000),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: AspectRatio(
                            aspectRatio: _videoController!.value.aspectRatio,
                            child: VideoPlayer(_videoController!),
                          ),
                        ),
                      ),
                  ],
                  const SizedBox(height: 24), // Bottom padding for scroll
                ],
              ),
            ),
          ),
        ),
        // Fixed bottom controls in one container
        Column(
          children: [
            Container(
              height: 50,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _neumorphicSelectionCard(
                    mode: 'Text',
                    isSelected: _selectedMode == 'Text',
                  ),
                  _neumorphicSelectionCard(
                    mode: 'Image',
                    isSelected: _selectedMode == 'Image',
                  ),
                  _neumorphicSelectionCard(
                    mode: 'Image Edit',
                    isSelected: _selectedMode == 'Image Edit',
                  ),
                  _neumorphicSelectionCard(
                    mode: 'Video',
                    isSelected: _selectedMode == 'Video',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // Generate Button
            FadeInUp(
              duration: const Duration(milliseconds: 1200),
              child: _neumorphicButton(
                onPressed: _generate,
                text: '✨ Generate',
                textColor: Colors.black,
                accentColor: Colors.deepPurple,
                borderRadius: 20,
                height: 55,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
