import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';
import 'package:url_launcher/url_launcher.dart';
import '../premiumize/premiumize_api_service.dart';
import 'torrent_sites.dart';

final logger = Logger();

class ManualScreen extends ConsumerStatefulWidget {
  const ManualScreen({super.key});

  @override
  ConsumerState<ManualScreen> createState() => _ManualScreenState();
}

class _ManualScreenState extends ConsumerState<ManualScreen> {
  final TextEditingController _controller = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _launchUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Could not launch $url'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      logger.e('Error launching URL', error: e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _submitTorrent() async {
    if (_controller.text.isEmpty) return;

    setState(() => _isLoading = true);
    try {
      final apiService = ref.read(premiumizeApiServiceProvider);
      await apiService.createTransfer(_controller.text);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Torrent sent to Premiumize successfully'),
            backgroundColor: Colors.green,
          ),
        );
        _controller.clear();
      }
    } catch (e) {
      logger.e('Error submitting torrent', error: e);
      if (mounted) {
        String errorMessage = 'Failed to send torrent to Premiumize';
        if (e.toString().contains('API key not found')) {
          errorMessage = 'Please set your Premiumize API key in settings';
        } else if (e.toString().contains('message')) {
          errorMessage = e.toString().split('message: ').last;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            action: errorMessage.contains('API key') ? SnackBarAction(
              label: 'Settings',
              textColor: Colors.white,
              onPressed: () => context.go('/settings'),
            ) : null,
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
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Manual Magnet/Torrent Entry',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            SizedBox(height: 24.h),
            Text(
              'Enter a magnet URL',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.white70,
                  ),
            ),
            SizedBox(height: 16.h),
            TextField(
              controller: _controller,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'magnet:?xt=urn:btih:...',
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.outline.withOpacity(0.5),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.primary,
                    width: 2,
                  ),
                ),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface,
              ),
              maxLines: 3,
            ),
            SizedBox(height: 24.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submitTorrent,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        'Submit to Premiumize',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
              ),
            ),
            SizedBox(height: 48.h),
            Text(
              'Recommended Torrent/Magnet Sites',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            SizedBox(height: 16.h),
            Text(
              'Click on a site to open it in your browser, NOTE: IT IS HIGHLY RECOMMENDED TO USE UBLOCK ORIGIN OR ANOTHER AD BLOCKER',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.white70,
                  ),
            ),
            Text(
              'DO NOT DOWNLOAD ANYTHING FROM THESE SITES BESIDES A TORRENT/MAGNET LINK',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.red,
                  ),
            ),
            Text(
              'Magnet links are preferred as they are more reliable and safer to use as they require no downloading of any files',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.blue,
                  ),
            ),
            SizedBox(height: 24.h),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: recommendedTorrentSites.length,
              separatorBuilder: (context, index) => SizedBox(height: 16.h),
              itemBuilder: (context, index) {
                final site = recommendedTorrentSites[index];
                return Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    side: BorderSide(
                      color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                    ),
                  ),
                  child: InkWell(
                    onTap: () => _launchUrl(site.url),
                    borderRadius: BorderRadius.circular(12.r),
                    child: Padding(
                      padding: EdgeInsets.all(16.w),
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(12.w),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Icon(
                              site.icon,
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
                                  site.name,
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  site.description,
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: Colors.white70,
                                      ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.open_in_new,
                            size: 20.w,
                            color: Colors.white.withOpacity(0.5),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
} 