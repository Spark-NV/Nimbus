import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TvShowSelectionDialog extends ConsumerStatefulWidget {
  const TvShowSelectionDialog({super.key});

  @override
  ConsumerState<TvShowSelectionDialog> createState() => _TvShowSelectionDialogState();
}

class _TvShowSelectionDialogState extends ConsumerState<TvShowSelectionDialog> {
  final _seasonController = TextEditingController();
  final _episodeController = TextEditingController();

  @override
  void dispose() {
    _seasonController.dispose();
    _episodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
      ),
      title: Text(
        'Select Season and Episode',
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.white,
            ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _seasonController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Season Number',
              labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
              hintText: 'Enter season number',
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              filled: true,
              fillColor: Theme.of(context).colorScheme.surface,
            ),
            style: TextStyle(color: Colors.white),
          ),
          SizedBox(height: 16.h),
          TextField(
            controller: _episodeController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Episode Number',
              labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
              hintText: 'Enter episode number',
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              filled: true,
              fillColor: Theme.of(context).colorScheme.surface,
            ),
            style: TextStyle(color: Colors.white),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            'Cancel',
            style: TextStyle(color: Colors.white.withOpacity(0.7)),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            final season = int.tryParse(_seasonController.text);
            final episode = int.tryParse(_episodeController.text);
            if (season != null && episode != null) {
              Navigator.of(context).pop((season, episode));
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
          ),
          child: const Text('Search'),
        ),
      ],
    );
  }
} 