import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class PremiumizeInstructionsScreen extends StatefulWidget {
  const PremiumizeInstructionsScreen({super.key});

  @override
  State<PremiumizeInstructionsScreen> createState() => _PremiumizeInstructionsScreenState();
}

class _PremiumizeInstructionsScreenState extends State<PremiumizeInstructionsScreen> {
  final List<Map<String, String>> _instructions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadInstructions();
  }

  Future<void> _loadInstructions() async {
    try {
      int index = 1;
      while (true) {
        try {
          final imagePath = 'assets/premiumize_instructions/$index.png';
          final textPath = 'assets/premiumize_instructions/$index.txt';
          
          await rootBundle.load(imagePath);
          
          final text = await rootBundle.loadString(textPath);
          
          _instructions.add({
            'image': imagePath,
            'text': text,
          });
          
          index++;
        } catch (e) {
          break;
        }
      }
    } catch (e) {
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('How to Get Premiumize API Key'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(24.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Follow these steps to get your Premiumize API key:',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  SizedBox(height: 24.h),
                  ..._instructions.map((instruction) => Column(
                        children: [
                          Text(
                            instruction['text']!,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Colors.red,
                                ),
                          ),
                          SizedBox(height: 16.h),
                          Image.asset(
                            instruction['image']!,
                            width: double.infinity,
                            fit: BoxFit.contain,
                          ),
                          SizedBox(height: 32.h),
                        ],
                      )),
                ],
              ),
            ),
    );
  }
} 