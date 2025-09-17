import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'API_Interfaces/Hugging_DeepSeek_R1.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _controller = TextEditingController();
  String _resultText = "";
  Uint8List? _imageBytes;
  Uint8List? _editedImageBytes;
  String? _videoUrl;
  VideoPlayerController? _videoController;

  String _selectedMode = "Text";
  bool _isLoading = false;

  final ImagePicker _picker = ImagePicker();
  Uint8List? _selectedImageForEdit;

  // For login
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _authLoading = false;

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
      _resultText = "";
      _imageBytes = null;
      _editedImageBytes = null;
      _videoUrl = null;
    });

    if (_selectedMode == "Text") {
      final result = await ApiService.generateText(input);
      setState(() => _resultText = result);
    } else if (_selectedMode == "Image") {
      final result = await ApiService.generateImage(input);
      setState(() => _imageBytes = result);
    } else if (_selectedMode == "Image Edit") {
      if (_selectedImageForEdit == null) {
        setState(() => _resultText = "Please select an image to edit.");
      } else {
        final result = await ApiService.imageToImage(input, _selectedImageForEdit!);
        setState(() => _editedImageBytes = result);
      }
    } else if (_selectedMode == "Video") {
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

  // -------------------- AUTH METHODS --------------------
  Future<void> _login() async {
    setState(() => _authLoading = true);
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? "Login failed")),
      );
    } finally {
      setState(() => _authLoading = false);
    }
  }

  Future<void> _signup() async {
    setState(() => _authLoading = true);
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? "Signup failed")),
      );
    } finally {
      setState(() => _authLoading = false);
    }
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: Text(user == null ? "Login" : "AI Playground"),
        backgroundColor: Colors.deepPurple,
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
        actions: [
          if (user != null)
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: _logout,
            )
        ],
      ),
      body: user == null ? _buildLoginUI() : _buildPlaygroundUI(),
    );
  }

  // -------------------- LOGIN UI --------------------
  Widget _buildLoginUI() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: "Email"),
            ),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: "Password"),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            _authLoading
                ? const CircularProgressIndicator()
                : Column(
              children: [
                ElevatedButton(
                  onPressed: _login,
                  child: const Text("Login"),
                ),
                TextButton(
                  onPressed: _signup,
                  child: const Text("Create Account"),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  // -------------------- AI PLAYGROUND UI --------------------
  Widget _buildPlaygroundUI() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Input box
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)],
            ),
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: "Enter your prompt...",
                border: InputBorder.none,
              ),
              maxLines: null,
            ),
          ),
          const SizedBox(height: 15),

          // Dropdown
          DropdownButton<String>(
            value: _selectedMode,
            items: ["Text", "Image", "Image Edit", "Video"].map((mode) {
              return DropdownMenuItem(value: mode, child: Text(mode));
            }).toList(),
            onChanged: (value) => setState(() => _selectedMode = value!),
          ),
          const SizedBox(height: 10),

          // Pick image button for edit mode
          if (_selectedMode == "Image Edit")
            ElevatedButton.icon(
              onPressed: _pickImage,
              icon: Icon(Icons.image),
              label: Text("Select Image"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          if (_selectedImageForEdit != null && _selectedMode == "Image Edit")
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Image.memory(_selectedImageForEdit!, height: 150),
            ),

          const SizedBox(height: 10),

          // Generate button
          ElevatedButton(
            onPressed: _generate,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 40, vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            ),
            child: Text("✨ Generate", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),

          const SizedBox(height: 20),

          // Loading spinner
          if (_isLoading) CircularProgressIndicator(color: Colors.deepPurple),

          // Results
          if (!_isLoading) ...[
            if (_resultText.isNotEmpty)
              Container(
                margin: EdgeInsets.only(top: 20),
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)],
                ),
                child: Text(_resultText, style: TextStyle(fontSize: 16)),
              ),
            if (_imageBytes != null) Image.memory(_imageBytes!, height: 300),
            if (_editedImageBytes != null) Image.memory(_editedImageBytes!, height: 300),
            if (_videoUrl != null && _videoController != null && _videoController!.value.isInitialized)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: AspectRatio(
                  aspectRatio: _videoController!.value.aspectRatio,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: VideoPlayer(_videoController!),
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }
}
