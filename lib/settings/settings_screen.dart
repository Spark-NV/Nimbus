import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';
import '../premiumize/premiumize_api_service.dart';
import '../omdb/omdb_api_key_service.dart';
import '../indexers/indexer_settings_provider.dart';
import '../indexers/orionoid_api_key_service.dart';
import '../indexers/orionoid_api_service.dart';
import '../indexers/orionoid_auth_widget.dart';
import '../indexers/orionoid_settings_widget.dart';

final logger = Logger();

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _omdbKeyController = TextEditingController();
  final _premiumizeKeyController = TextEditingController();
  final _orionoidKeyController = TextEditingController();
  bool _darkMode = true;
  bool _autoUpdate = true;
  late final PremiumizeApiService _apiService;
  late final OrionoidApiService _orionoidApiService;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _apiService = ref.read(premiumizeApiServiceProvider);
    _orionoidApiService = ref.read(orionoidApiServiceProvider);
    _loadSettings();
  }

  @override
  void dispose() {
    _omdbKeyController.dispose();
    _premiumizeKeyController.dispose();
    _orionoidKeyController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    setState(() => _isLoading = true);
    try {
      await _apiService.initialize();
      await _orionoidApiService.initialize();
      
      if (_apiService.hasApiKey) {
        _premiumizeKeyController.text = _apiService.apiKey ?? '';
      }
      
      final omdbApiKey = await ref.read(omdbApiKeyServiceProvider.future);
      if (omdbApiKey != null) {
        _omdbKeyController.text = omdbApiKey;
      }
      
      final orionoidApiKey = await ref.read(orionoidApiKeyServiceProvider.future);
      if (orionoidApiKey != null) {
        _orionoidKeyController.text = orionoidApiKey;
      }
    } catch (e) {
      logger.e('Error loading settings', error: e);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _saveSettings() async {
    setState(() => _isLoading = true);
    try {
      if (_premiumizeKeyController.text.isNotEmpty) {
        await _apiService.setApiKey(_premiumizeKeyController.text);
        if (mounted) {
          ref.invalidate(premiumizeApiServiceProvider);
        }
      }
      
      if (_omdbKeyController.text.isNotEmpty) {
        await ref.read(omdbApiKeyServiceProvider.notifier).setApiKey(_omdbKeyController.text);
        if (mounted) {
          ref.invalidate(omdbApiKeyServiceProvider);
        }
      }
      
      if (_orionoidKeyController.text.isNotEmpty) {
        await ref.read(orionoidApiKeyServiceProvider.notifier).setApiKey(_orionoidKeyController.text);
        if (mounted) {
          ref.invalidate(orionoidApiKeyServiceProvider);
        }
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Settings saved successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      logger.e('Error saving settings', error: e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving settings: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _clearOrionoidApiKey() async {
    setState(() => _isLoading = true);
    try {
      await ref.read(orionoidApiKeyServiceProvider.notifier).clearApiKey();
      _orionoidKeyController.clear();
      if (mounted) {
        ref.invalidate(orionoidApiKeyServiceProvider);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Orionoid API key cleared'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      logger.e('Error clearing Orionoid API key', error: e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error clearing Orionoid API key: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final torrentioSettings = ref.watch(torrentioSettingsProvider);
    
    return WillPopScope(
      onWillPop: () async {
        await _saveSettings();
        return true;
      },
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Settings',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
              ),
              SizedBox(height: 24.h),
              _SettingsSection(
                title: 'API Keys',
                children: [
                  Row(
                    children: [
                      Text(
                        'OMDB API Key',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                      ),
                      SizedBox(width: 8.w),
                      IconButton(
                        icon: Icon(
                          Icons.help_outline,
                          color: Colors.white.withOpacity(0.7),
                          size: 20.w,
                        ),
                        onPressed: () => context.go('/instructions/omdb'),
                        tooltip: 'How to get OMDB API key',
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  TextField(
                    controller: _omdbKeyController,
                    decoration: InputDecoration(
                      hintText: 'Enter your OMDB API key',
                      hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                      prefixIcon: Icon(
                        Icons.movie_outlined,
                        color: Colors.white.withOpacity(0.7),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                        ),
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
                  Row(
                    children: [
                      Text(
                        'Premiumize API Key',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                      ),
                      SizedBox(width: 8.w),
                      IconButton(
                        icon: Icon(
                          Icons.help_outline,
                          color: Colors.white.withOpacity(0.7),
                          size: 20.w,
                        ),
                        onPressed: () => context.go('/instructions/premiumize'),
                        tooltip: 'How to get Premiumize API key',
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  TextField(
                    controller: _premiumizeKeyController,
                    decoration: InputDecoration(
                      hintText: 'Enter your Premiumize API key',
                      hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                      prefixIcon: Icon(
                        Icons.cloud_outlined,
                        color: Colors.white.withOpacity(0.7),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                        ),
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
              SizedBox(height: 32.h),
              _SettingsSection(
                title: 'Indexers',
                children: [
                  _SettingsSwitch(
                    label: 'Torrentio',
                    icon: Icons.search_outlined,
                    value: torrentioSettings.torrentioEnabled,
                    onChanged: (value) => ref.read(torrentioSettingsProvider.notifier).setTorrentioEnabled(value),
                  ),
                  SizedBox(height: 16.h),
                  _SettingsSwitch(
                    label: 'Orionoid',
                    icon: Icons.search_outlined,
                    value: torrentioSettings.orionoidEnabled,
                    onChanged: (value) => ref.read(torrentioSettingsProvider.notifier).setOrionoidEnabled(value),
                  ),
                  SizedBox(height: 16.h),
                  _SettingsSwitch(
                    label: 'Prowlarr - NOT IMPLEMENTED YET',
                    icon: Icons.search_outlined,
                    value: torrentioSettings.prowlarrEnabled,
                    onChanged: (value) => ref.read(torrentioSettingsProvider.notifier).setProwlarrEnabled(value),
                  ),
                  SizedBox(height: 32.h),
                  _SettingsSection(
                    title: 'Cache Settings',
                    children: [
                      _SettingsSwitch(
                        label: 'Hide Cached Results',
                        icon: Icons.hide_source_outlined,
                        value: torrentioSettings.hideCachedResults,
                        onChanged: (value) => ref.read(torrentioSettingsProvider.notifier).setHideCachedResults(value),
                      ),
                    ],
                  ),
                ],
              ),
              if (torrentioSettings.orionoidEnabled) ...[
                SizedBox(height: 32.h),
                _SettingsSection(
                  title: 'Orionoid Settings',
                  children: [
                    _ApiKeyField(
                      label: 'Orionoid API Key',
                      hint: 'Enter your Orionoid API key',
                      icon: Icons.key_outlined,
                      controller: _orionoidKeyController,
                      isLoading: _isLoading,
                      onSave: _saveSettings,
                      onClear: _clearOrionoidApiKey,
                    ),
                    SizedBox(height: 16.h),
                    const OrionoidAuthWidget(),
                    SizedBox(height: 16.h),
                    const OrionoidSettingsWidget(),
                  ],
                ),
              ],
              SizedBox(height: 32.h),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({
    required this.title,
    required this.children,
  });

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
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
            padding: EdgeInsets.all(24.w),
            child: Column(
              children: children,
            ),
          ),
        ),
      ],
    );
  }
}

class _ApiKeyField extends StatelessWidget {
  const _ApiKeyField({
    required this.label,
    required this.hint,
    required this.icon,
    required this.controller,
    required this.isLoading,
    this.onSave,
    this.onClear,
  });

  final String label;
  final String hint;
  final IconData icon;
  final TextEditingController controller;
  final bool isLoading;
  final VoidCallback? onSave;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
        ),
        SizedBox(height: 8.h),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: hint,
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                  prefixIcon: Icon(
                    icon,
                    color: Colors.white.withOpacity(0.7),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                    ),
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
            ),
            SizedBox(width: 8.w),
            if (onSave != null)
              IconButton(
                onPressed: isLoading ? null : onSave,
                icon: isLoading
                    ? SizedBox(
                        width: 24.w,
                        height: 24.h,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      )
                    : Icon(
                        Icons.save,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                tooltip: 'Save',
              ),
            if (onClear != null)
              IconButton(
                onPressed: isLoading ? null : onClear,
                icon: Icon(
                  Icons.clear,
                  color: Colors.red.withOpacity(0.7),
                ),
                tooltip: 'Clear',
              ),
          ],
        ),
      ],
    );
  }
}

class _SettingsSwitch extends StatelessWidget {
  const _SettingsSwitch({
    required this.label,
    required this.icon,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final IconData icon;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          color: Colors.white.withOpacity(0.7),
        ),
        SizedBox(width: 16.w),
        Text(
          label,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.white,
              ),
        ),
        const Spacer(),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: Theme.of(context).colorScheme.primary,
        ),
      ],
    );
  }
} 