import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/registry_service.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  Future<void> _setupWindowsIntegration(BuildContext context) async {
    final registryService = RegistryService();
    final hasAdminRights = await registryService.isUserAdmin();
    
    if (!hasAdminRights) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Admin rights required. Please restart the app as administrator.'),
            duration: Duration(seconds: 5),
          ),
        );
      }
      return;
    }

    final success = await registryService.setupRegistryHandlers();
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success 
            ? 'Windows integration setup successful!'
            : 'Failed to setup Windows integration. Please try again as administrator.'),
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nimbus'),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () => context.go('/faq'),
            tooltip: 'FAQ & Information',
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome to Nimbus',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
            ),
            SizedBox(height: 24.h),
            Text(
              'Getting Started',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
            ),
            SizedBox(height: 16.h),
            _InfoCard(
              title: 'API Keys Setup',
              description:
                  'Before you can start using Nimbus, you need to set up your API keys in the Settings screen. you only need keys for OMDB if you want to use search functionality; Premiumize is required.',
              icon: Icons.key_outlined,
              onTap: () => context.go('/settings'),
            ),
            SizedBox(height: 16.h),
            _InfoCard(
              title: 'Search Content',
              description:
                  'Use the Search screen to find movies and TV shows. Enter your search query and browse through the results. This feature requires an OMDB API key due to the metadata featching',
              icon: Icons.search,
              onTap: () => context.go('/search'),
            ),
            SizedBox(height: 16.h),
            _InfoCard(
              title: 'Premiumize Integration',
              description:
                  'Connect your Premiumize account to enable sending torrents and magnet links to your Premiumize account. This feature requires a Premiumize API key and is not required for basic functionality.',
              icon: Icons.cloud_outlined,
              onTap: () => context.go('/premiumize'),
            ),
            SizedBox(height: 16.h),
            _InfoCard(
              title: 'Manual Caching',
              description:
                  'If you would prefer to cache torrents manually, you can do so by using the Manual Caching feature. This feature allows you to manually add torrents to your cache by providing the magnet link.',
              icon: Icons.sync_alt,
              onTap: () => context.go('/manual'),
            ),
            SizedBox(height: 16.h),
            _InfoCard(
              title: 'Windows Integration',
              description:
                  'Nimbus can register itself as the default handler for magnet links and .torrent files. If you want to be able to click magnet links in a browser or open torrent files to send to premiumize you need this.\nClick here to set up Windows integration. This requires administrator privileges.',
              icon: Icons.open_in_new,
              onTap: () => _setupWindowsIntegration(context),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String description;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
        side: BorderSide(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.r),
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  icon,
                  size: 24.w,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      description.split('\n')[0],
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.white.withOpacity(0.8),
                          ),
                    ),
                    if (description.contains('\n'))
                      Text(
                        description.split('\n')[1],
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Colors.blue,
                            ),
                      ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16.w,
                color: Colors.white.withOpacity(0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 