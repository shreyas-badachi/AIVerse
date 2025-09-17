import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:fal_client/fal_client.dart';
import 'package:cross_file/cross_file.dart';

class ApiService {
  static final String hfToken = dotenv.env['HF_TOKEN'] ?? "";
  static final String falApiKey = dotenv.env['FAL_KEY'] ?? "";

  // Hugging Face Models
  static const String textModel = "deepseek-ai/DeepSeek-R1:fireworks-ai";
  static const String imageModel = "stabilityai/stable-diffusion-xl-base-1.0";
  static const String imageApiUrl = "https://api-inference.huggingface.co/models/$imageModel";

  // Fal.ai Models
  static const String imageToImageModel = "fal-ai/flux-pro/kontext";
  static const String textToVideoModel = "fal-ai/veo3";

  /// Generate text using DeepSeek
  static Future<String> generateText(String input) async {
    try {
      final response = await http.post(
        Uri.parse("https://router.huggingface.co/v1/chat/completions"),
        headers: {
          "Authorization": "Bearer $hfToken",
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "model": textModel,
          "messages": [{"role": "user", "content": input}]
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data["choices"][0]["message"]["content"] ?? "No content";
      } else {
        return "Error: ${response.body}";
      }
    } catch (e) {
      return "Exception: $e";
    }
  }

  /// Generate image using Stable Diffusion
  static Future<Uint8List?> generateImage(String prompt) async {
    try {
      final response = await http.post(
        Uri.parse(imageApiUrl),
        headers: {
          "Authorization": "Bearer $hfToken",
          "Content-Type": "application/json",
          "Accept": "image/png",
        },
        body: jsonEncode({"inputs": prompt}),
      );

      if (response.statusCode == 200 && response.bodyBytes.isNotEmpty) {
        return response.bodyBytes;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  /// Image-to-image transformation using Fal.ai (Kontext)
  static Future<Uint8List?> imageToImage(String prompt, Uint8List inputImage) async {
    try {
      final fal = FalClient.withCredentials(falApiKey);

      // Step 1: Upload image
      final file = XFile.fromData(inputImage, name: "input.png", mimeType: "image/png");
      final imageUrl = await fal.storage.upload(file);

      // Step 2: Call Kontext
      final output = await fal.subscribe(
        imageToImageModel,
        input: {
          "prompt": prompt,
          "image_url": imageUrl,
        },
        logs: true,
      );

      // Step 3: Get result
      if (output.data != null && output.data["images"] != null && output.data["images"].isNotEmpty) {
        final resultUrl = output.data["images"][0]["url"];
        final imageRes = await http.get(Uri.parse(resultUrl));
        return imageRes.bodyBytes;
      } else {
        print("DEBUG: No image returned: ${output.data}");
        return null;
      }
    } catch (e) {
      print("DEBUG: Exception $e");
      return null;
    }
  }

  /// Text-to-video generation using Fal.ai (Veo3)
  static Future<String?> generateVideo(String prompt) async {
    try {
      final fal = FalClient.withCredentials(falApiKey);

      final output = await fal.subscribe(
        textToVideoModel,
        input: {"prompt": prompt},
        logs: true,
      );

      if (output.data != null && output.data["videos"] != null && output.data["videos"].isNotEmpty) {
        return output.data["videos"][0]["url"];
      } else {
        print("DEBUG: No video returned: ${output.data}");
        return null;
      }
    } catch (e) {
      print("DEBUG: Exception $e");
      return null;
    }
  }
}
