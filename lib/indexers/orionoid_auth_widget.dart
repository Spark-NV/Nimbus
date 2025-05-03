import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:logger/logger.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'orionoid_auth_provider.dart';
import 'orionoid_api_service.dart';

final logger = Logger();

class OrionoidAuthWidget extends ConsumerWidget {
  const OrionoidAuthWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(orionoidAuthProvider);
    final apiService = ref.watch(orionoidApiServiceProvider);

    return FutureBuilder<bool>(
      future: apiService.hasApiKey,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final hasApiKey = snapshot.data ?? false;
        
        if (!hasApiKey) {
          return _buildNoApiKeyMessage(context);
        }

        if (apiService.hasAuthToken) {
          return _buildAlreadyAuthenticatedUI(context, ref);
        }

        switch (authState.status) {
          case OrionoidAuthStatus.idle:
            return _buildStartAuthButton(context, ref);
          case OrionoidAuthStatus.starting:
            return _buildLoadingIndicator();
          case OrionoidAuthStatus.waiting:
            return _buildWaitingUI(context, authState, ref);
          case OrionoidAuthStatus.approved:
            return _buildApprovedUI(context, ref, authState);
          case OrionoidAuthStatus.failed:
            return _buildFailedUI(context, ref, authState);
        }
      },
    );
  }

  Widget _buildNoApiKeyMessage(BuildContext context) {
    return Card(
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
          children: [
            Icon(
              Icons.key_outlined,
              size: 48.w,
              color: Colors.orange,
            ),
            SizedBox(height: 16.h),
            Text(
              'Orionoid API Key Required',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Please enter your Orionoid API key in the field above and save it before starting authentication.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withOpacity(0.7),
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStartAuthButton(BuildContext context, WidgetRef ref) {
    return ElevatedButton.icon(
      onPressed: () {
        ref.read(orionoidAuthProvider.notifier).startAuth();
      },
      icon: const Icon(Icons.login),
      label: const Text('Start Authentication'),
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 24.w),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildWaitingUI(BuildContext context, OrionoidAuthState state, WidgetRef ref) {
    final authResponse = state.authResponse;
    if (authResponse == null || authResponse.data == null) {
      return const Center(child: Text('No authentication data available'));
    }

    final data = authResponse.data!;
    final expirationTime = state.expirationTime;
    final remainingTime = expirationTime != null
        ? expirationTime.difference(DateTime.now())
        : const Duration(seconds: 0);

    return Card(
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Authentication in Progress',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
            ),
            SizedBox(height: 16.h),
            Text(
              'Please visit the following link and enter the code to authenticate:',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withOpacity(0.7),
                  ),
            ),
            SizedBox(height: 11.h),
            InkWell(
              onTap: () {
                final url = data.direct ?? data.link;
                if (url != null) {
                  launchUrl(Uri.parse(url));
                }
              },
              child: Text(
                data.direct ?? data.link ?? 'No URL available',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      decoration: TextDecoration.underline,
                    ),
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              'Authentication Code:',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Colors.white.withOpacity(0.7),
                  ),
            ),
            SizedBox(height: 8.h),
            SelectableText(
              data.code ?? 'No code available',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
            if (data.qr != null) ...[
              SizedBox(height: 16.h),
              Center(
                child: QrImageView(
                  data: data.qr!,
                  version: QrVersions.auto,
                  size: 200.w,
                  backgroundColor: Colors.white,
                ),
              ),
            ],
            SizedBox(height: 16.h),
            if (remainingTime.inSeconds > 0)
              Text(
                'Expires in: ${remainingTime.inMinutes}:${(remainingTime.inSeconds % 60).toString().padLeft(2, '0')}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.orange,
                    ),
              ),
            SizedBox(height: 16.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton.icon(
                  onPressed: () {
                    final url = data.direct ?? data.link;
                    if (url != null) {
                      launchUrl(Uri.parse(url));
                    }
                  },
                  icon: const Icon(Icons.open_in_new),
                  label: const Text('Open Link'),
                ),
                TextButton.icon(
                  onPressed: () {
                    ref.read(orionoidAuthProvider.notifier).reset();
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Cancel'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlreadyAuthenticatedUI(BuildContext context, WidgetRef ref) {
    return Card(
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 24.w,
                ),
                SizedBox(width: 8.w),
                Text(
                  'Already Authenticated',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            Text(
              'You are already authenticated with Orionoid.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withOpacity(0.7),
                  ),
            ),
            SizedBox(height: 16.h),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () async {
                  await ref.read(orionoidApiServiceProvider).clearAuthToken();
                  ref.read(orionoidAuthProvider.notifier).reset();
                },
                icon: const Icon(Icons.logout),
                label: const Text('Logout'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildApprovedUI(BuildContext context, WidgetRef ref, OrionoidAuthState state) {
    final authResponse = state.authResponse;
    if (authResponse == null) {
      return const Center(child: Text('No authentication data available'));
    }

    final user = authResponse.data?.user;
    if (user == null) {
      return const Center(child: Text('No user data available'));
    }

    return Card(
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 24.w,
                ),
                SizedBox(width: 8.w),
                Text(
                  'Authentication Successful',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            Text(
              'User ID: ${user.id}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withOpacity(0.7),
                  ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Email: ${user.email}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withOpacity(0.7),
                  ),
            ),
            if (user.username != null) ...[
              SizedBox(height: 8.h),
              Text(
                'Username: ${user.username}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withOpacity(0.7),
                    ),
              ),
            ],
            SizedBox(height: 16.h),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () async {
                  await ref.read(orionoidApiServiceProvider).clearAuthToken();
                  ref.read(orionoidAuthProvider.notifier).reset();
                },
                icon: const Icon(Icons.logout),
                label: const Text('Logout'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFailedUI(BuildContext context, WidgetRef ref, OrionoidAuthState state) {
    return Card(
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 24.w,
                ),
                SizedBox(width: 8.w),
                Text(
                  'Authentication Failed',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            Text(
              state.errorMessage ?? 'An unknown error occurred',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.red.withOpacity(0.7),
                  ),
            ),
            SizedBox(height: 16.h),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () {
                  ref.read(orionoidAuthProvider.notifier).reset();
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Try Again'),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 