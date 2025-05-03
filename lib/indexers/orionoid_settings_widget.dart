import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'orionoid_settings.dart';
import 'indexer_settings_provider.dart';
import 'dart:async';

class OrionoidSettingsWidget extends ConsumerWidget {
  const OrionoidSettingsWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(indexerSettingsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSection(
          context,
          title: 'Result Limits',
          children: [
            _buildNumberField(
              context,
              label: 'Movie Results Limit',
              value: settings.movieLimit,
              onChanged: (value) => ref
                  .read(indexerSettingsProvider.notifier)
                  .setMovieLimit(value),
            ),
            SizedBox(height: 16.h),
            _buildNumberField(
              context,
              label: 'TV Show Results Limit',
              value: settings.tvShowLimit,
              onChanged: (value) => ref
                  .read(indexerSettingsProvider.notifier)
                  .setTvShowLimit(value),
            ),
          ],
        ),
        SizedBox(height: 24.h),
        _buildSection(
          context,
          title: 'Sort Settings',
          children: [
            _buildSortSettings(
              context,
              label: 'Movie Sort',
              value: settings.movieSortValue,
              order: settings.movieSortOrder,
              onValueChanged: (value) => ref
                  .read(indexerSettingsProvider.notifier)
                  .setMovieSortValue(value),
              onOrderChanged: (order) => ref
                  .read(indexerSettingsProvider.notifier)
                  .setMovieSortOrder(order),
            ),
            SizedBox(height: 16.h),
            _buildSortSettings(
              context,
              label: 'TV Show Sort',
              value: settings.tvShowSortValue,
              order: settings.tvShowSortOrder,
              onValueChanged: (value) => ref
                  .read(indexerSettingsProvider.notifier)
                  .setTvShowSortValue(value),
              onOrderChanged: (order) => ref
                  .read(indexerSettingsProvider.notifier)
                  .setTvShowSortOrder(order),
            ),
          ],
        ),
        SizedBox(height: 24.h),
        _buildSection(
          context,
          title: 'Size Limits (in MB)',
          children: [
            _buildSizeLimits(
              context,
              label: 'Movie Size Limits',
              minValue: settings.movieMinBytes != null
                  ? settings.movieMinBytes! ~/ (1024 * 1024)
                  : null,
              maxValue: settings.movieMaxBytes != null
                  ? settings.movieMaxBytes! ~/ (1024 * 1024)
                  : null,
              onChanged: (min, max) => ref
                  .read(indexerSettingsProvider.notifier)
                  .setMovieSizeLimits(
                    min != null ? min * 1024 * 1024 : null,
                    max != null ? max * 1024 * 1024 : null,
                  ),
            ),
            SizedBox(height: 16.h),
            _buildSizeLimits(
              context,
              label: 'TV Show Size Limits',
              minValue: settings.tvShowMinBytes != null
                  ? settings.tvShowMinBytes! ~/ (1024 * 1024)
                  : null,
              maxValue: settings.tvShowMaxBytes != null
                  ? settings.tvShowMaxBytes! ~/ (1024 * 1024)
                  : null,
              onChanged: (min, max) => ref
                  .read(indexerSettingsProvider.notifier)
                  .setTvShowSizeLimits(
                    min != null ? min * 1024 * 1024 : null,
                    max != null ? max * 1024 * 1024 : null,
                  ),
            ),
          ],
        ),
        SizedBox(height: 24.h),
        _buildSection(
          context,
          title: 'Language Settings',
          children: [
            _buildLanguageField(
              context,
              label: 'Movie Subtitle Language',
              value: settings.movieSubtitleLanguage,
              onChanged: (value) => ref
                  .read(indexerSettingsProvider.notifier)
                  .setMovieSubtitleLanguage(value),
            ),
            SizedBox(height: 16.h),
            _buildLanguageField(
              context,
              label: 'TV Show Subtitle Language',
              value: settings.tvShowSubtitleLanguage,
              onChanged: (value) => ref
                  .read(indexerSettingsProvider.notifier)
                  .setTvShowSubtitleLanguage(value),
            ),
            SizedBox(height: 16.h),
            _buildLanguageField(
              context,
              label: 'Movie Audio Language',
              value: settings.movieAudioLanguage,
              onChanged: (value) => ref
                  .read(indexerSettingsProvider.notifier)
                  .setMovieAudioLanguage(value),
            ),
            SizedBox(height: 16.h),
            _buildLanguageField(
              context,
              label: 'TV Show Audio Language',
              value: settings.tvShowAudioLanguage,
              onChanged: (value) => ref
                  .read(indexerSettingsProvider.notifier)
                  .setTvShowAudioLanguage(value),
            ),
          ],
        ),
        SizedBox(height: 24.h),
        _buildSection(
          context,
          title: 'Seeder Limits',
          children: [
            _buildNumberField(
              context,
              label: 'Movie Minimum Seeders',
              value: settings.movieSeederLimit,
              onChanged: (value) => ref
                  .read(indexerSettingsProvider.notifier)
                  .setMovieSeederLimit(value),
            ),
            SizedBox(height: 16.h),
            _buildNumberField(
              context,
              label: 'TV Show Minimum Seeders',
              value: settings.tvShowSeederLimit,
              onChanged: (value) => ref
                  .read(indexerSettingsProvider.notifier)
                  .setTvShowSeederLimit(value),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
        ),
        SizedBox(height: 16.h),
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
            side: BorderSide(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
            ),
          ),
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              children: children,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNumberField(
    BuildContext context, {
    required String label,
    required int? value,
    required ValueChanged<int?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white.withOpacity(0.7),
              ),
        ),
        SizedBox(height: 8.h),
        SizedBox(
          width: double.infinity,
          child: TextField(
            controller: TextEditingController(
              text: value?.toString() ?? '',
            ),
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: 'Enter number (default: 100)',
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
            onChanged: (value) {
              if (value.isEmpty) {
                onChanged(null);
              } else {
                onChanged(int.tryParse(value));
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSortSettings(
    BuildContext context, {
    required String label,
    required SortValue value,
    required SortOrder order,
    required ValueChanged<SortValue> onValueChanged,
    required ValueChanged<SortOrder> onOrderChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white.withOpacity(0.7),
              ),
        ),
        SizedBox(height: 8.h),
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<SortValue>(
                value: value,
                decoration: InputDecoration(
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
                dropdownColor: Theme.of(context).colorScheme.surface,
                style: TextStyle(color: Colors.white),
                items: SortValue.values.map((value) {
                  return DropdownMenuItem(
                    value: value,
                    child: Text(
                      value.toString().split('.').last,
                      style: TextStyle(color: Colors.white),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    onValueChanged(value);
                  }
                },
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: DropdownButtonFormField<SortOrder>(
                value: order,
                decoration: InputDecoration(
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
                dropdownColor: Theme.of(context).colorScheme.surface,
                style: TextStyle(color: Colors.white),
                items: SortOrder.values.map((value) {
                  return DropdownMenuItem(
                    value: value,
                    child: Text(
                      value.toString().split('.').last,
                      style: TextStyle(color: Colors.white),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    onOrderChanged(value);
                  }
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSizeLimits(
    BuildContext context, {
    required String label,
    required int? minValue,
    required int? maxValue,
    required Function(int?, int?) onChanged,
  }) {
    return SizeLimitsField(
      label: label,
      minValue: minValue,
      maxValue: maxValue,
      onChanged: onChanged,
    );
  }

  Widget _buildLanguageField(
    BuildContext context, {
    required String label,
    required String? value,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white.withOpacity(0.7),
              ),
        ),
        SizedBox(height: 8.h),
        SizedBox(
          width: double.infinity,
          child: TextField(
            controller: TextEditingController(text: value ?? ''),
            decoration: InputDecoration(
              hintText: 'Enter language code (e.g., en, es, fr)',
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
            onChanged: (value) {
              onChanged(value.isEmpty ? null : value);
            },
          ),
        ),
      ],
    );
  }
}

class SizeLimitsField extends StatefulWidget {
  const SizeLimitsField({
    super.key,
    required this.label,
    required this.minValue,
    required this.maxValue,
    required this.onChanged,
  });

  final String label;
  final int? minValue;
  final int? maxValue;
  final Function(int?, int?) onChanged;

  @override
  State<SizeLimitsField> createState() => _SizeLimitsFieldState();
}

class _SizeLimitsFieldState extends State<SizeLimitsField> {
  late final TextEditingController _minController;
  late final TextEditingController _maxController;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _minController = TextEditingController(text: widget.minValue?.toString() ?? '');
    _maxController = TextEditingController(text: widget.maxValue?.toString() ?? '');
  }

  @override
  void dispose() {
    _minController.dispose();
    _maxController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onChanged(String value, bool isMin) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(seconds: 5), () {
      final min = isMin ? (value.isEmpty ? null : int.tryParse(value)) : widget.minValue;
      final max = !isMin ? (value.isEmpty ? null : int.tryParse(value)) : widget.maxValue;
      widget.onChanged(min, max);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white.withOpacity(0.7),
              ),
        ),
        SizedBox(height: 8.h),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _minController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Min MB (default: 100)',
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
                onChanged: (value) => _onChanged(value, true),
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: TextField(
                controller: _maxController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Max MB (default: 10000)',
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
                onChanged: (value) => _onChanged(value, false),
              ),
            ),
          ],
        ),
      ],
    );
  }
} 