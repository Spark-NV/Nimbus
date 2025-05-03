import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'premiumize_api_service.dart';
import 'premiumize_repository.dart';
import 'premiumize_account_info.dart';

class PremiumizeScreen extends ConsumerStatefulWidget {
  const PremiumizeScreen({super.key});

  @override
  ConsumerState<PremiumizeScreen> createState() => _PremiumizeScreenState();
}

class _PremiumizeScreenState extends ConsumerState<PremiumizeScreen> {
  bool _isInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      _initializeService();
    }
  }

  Future<void> _initializeService() async {
    final apiService = ref.read(premiumizeApiServiceProvider);
    await apiService.initialize();
    if (mounted) {
      setState(() {
        _isInitialized = true;
      });
      ref.read(premiumizeAccountInfoNotifierProvider.notifier).refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    final apiService = ref.watch(premiumizeApiServiceProvider);
    final hasApiKey = apiService.hasApiKey;
    final accountInfoAsync = ref.watch(premiumizeAccountInfoNotifierProvider);

    if (!_isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    return Padding(
      padding: EdgeInsets.all(32.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Premiumize Account',
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
          ),
          SizedBox(height: 24.h),
          _AccountStatusCard(
            hasApiKey: hasApiKey,
            onSettingsTap: () => context.go('/settings'),
          ),
          SizedBox(height: 24.h),
          Text(
            'Account Details',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
          ),
          SizedBox(height: 16.h),
          accountInfoAsync.when(
            data: (accountInfo) => _AccountDetailsGrid(accountInfo: accountInfo),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(
              child: Text(
                'Error: ${error.toString()}',
                style: TextStyle(color: Colors.red, fontSize: 16.sp),
              ),
            ),
          ),
          SizedBox(height: 24.h),
          ElevatedButton.icon(
            onPressed: () => context.go('/premiumize/transfers'),
            icon: Icon(Icons.list_alt, size: 20.w),
            label: const Text('View Transfers'),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(
                horizontal: 24.w,
                vertical: 12.h,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AccountStatusCard extends StatelessWidget {
  final bool hasApiKey;
  final VoidCallback onSettingsTap;

  const _AccountStatusCard({
    required this.hasApiKey,
    required this.onSettingsTap,
  });

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
                Icons.cloud_outlined,
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
                    'Account Status',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    hasApiKey ? 'Connected' : 'API Key Not Set',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: hasApiKey 
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.error,
                        ),
                  ),
                ],
              ),
            ),
            TextButton.icon(
              onPressed: onSettingsTap,
              icon: Icon(Icons.settings_outlined, size: 20.w),
              label: const Text('Settings'),
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(
                  horizontal: 24.w,
                  vertical: 12.h,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AccountDetailsGrid extends StatelessWidget {
  final PremiumizeAccountInfo accountInfo;

  const _AccountDetailsGrid({
    required this.accountInfo,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      mainAxisSpacing: 16.h,
      crossAxisSpacing: 16.w,
      childAspectRatio: 1.5,
      children: [
        _DetailCard(
          title: 'Storage Used',
          value: accountInfo.formattedSpaceUsed,
          icon: Icons.storage_outlined,
        ),
        _DetailCard(
          title: 'Premium Until',
          value: accountInfo.formattedPremiumUntil,
          icon: Icons.stars_outlined,
        ),
        _DetailCard(
          title: 'Limit Used',
          value: '${accountInfo.limitUsed} GB',
          icon: Icons.swap_horiz_outlined,
        ),
      ],
    );
  }
}

class _DetailCard extends StatelessWidget {
  const _DetailCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  final String title;
  final String value;
  final IconData icon;

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
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 24.w,
              color: Theme.of(context).colorScheme.primary,
            ),
            SizedBox(height: 8.h),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                  ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 4.h),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
} 