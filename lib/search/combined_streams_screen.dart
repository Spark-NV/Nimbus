import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:logger/logger.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../indexers/torrentio_response.dart';
import '../indexers/orionoid_response.dart';
import '../premiumize/premiumize_repository.dart';
import '../premiumize/premiumize_api_service.dart';
import '../indexers/indexer_settings_provider.dart';

final logger = Logger();

class CombinedStreamsScreen extends ConsumerWidget {
  final List<dynamic> streams;
  final String title;

  const CombinedStreamsScreen({
    Key? key,
    required this.streams,
    required this.title,
  }) : super(key: key);

  String _getStreamStatus(dynamic stream) {
    logger.i('Stream status check: name=${stream.name}, contains PM+=${stream.name.contains('[PM+]')}');
    if (stream.name.contains('[PM+]')) {
      return 'Cached';
    } else if (stream.name.contains('[PM download]')) {
      return 'Uncached';
    }
    return 'Uncached';
  }

  Color _getStatusColor(dynamic stream) {
    logger.i('Stream color check: name=${stream.name}, contains PM+=${stream.name.contains('[PM+]')}');
    if (stream.name.contains('[PM+]')) {
      return Colors.green;
    } else if (stream.name.contains('[PM download]')) {
      return Colors.red;
    }
    return Colors.red;
  }

  String _cleanStreamName(dynamic stream) {
    return stream.name
        .replaceAll('[PM+]', '')
        .replaceAll('[PM download]', '')
        .trim();
  }

  String _getStreamTitle(dynamic stream) {
    return stream.title;
  }

  String _getStreamFilename(dynamic stream) {
    return stream.behaviorHints?.filename ?? '';
  }

  String _getStreamUrl(dynamic stream) {
    return stream.url;
  }

  Future<void> _sendToPremiumize(BuildContext context, WidgetRef ref, String url) async {
    try {
      final apiService = ref.read(premiumizeApiServiceProvider);
      await apiService.createTransfer(url);
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Stream sent to Premiumize successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      logger.e('Error sending stream to Premiumize', error: e);
      if (context.mounted) {
        String errorMessage = 'Failed to send stream to Premiumize';
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
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hideCachedResults = ref.watch(torrentioSettingsProvider).hideCachedResults;
    
    final filteredStreams = hideCachedResults
        ? streams.where((stream) => !stream.name.contains('[PM+]')).toList()
        : streams;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          title,
          style: TextStyle(
            color: Colors.white,
            fontSize: 20.sp,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: filteredStreams.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.search_off,
                    size: 64.w,
                    color: Colors.grey[600],
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'No streams found',
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 18.sp,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: EdgeInsets.all(16.r),
              itemCount: filteredStreams.length,
              itemBuilder: (context, index) {
                final stream = filteredStreams[index];
                return Card(
                  margin: EdgeInsets.only(bottom: 16.h),
                  color: Colors.grey[900],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: ListTile(
                    contentPadding: EdgeInsets.all(16.r),
                    title: Row(
                      children: [
                        Text(
                          _getStreamStatus(stream),
                          style: TextStyle(
                            color: _getStatusColor(stream),
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Text(
                            _cleanStreamName(stream),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 8.h),
                        Text(
                          _getStreamTitle(stream),
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 14.sp,
                          ),
                        ),
                        if (_getStreamFilename(stream).isNotEmpty) ...[
                          SizedBox(height: 4.h),
                          Text(
                            _getStreamFilename(stream),
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 12.sp,
                            ),
                          ),
                        ],
                      ],
                    ),
                    trailing: IconButton(
                      icon: Icon(
                        Icons.upload,
                        color: stream.name.contains('[PM+]') ? Colors.grey[600] : Colors.white,
                        size: 32.w,
                      ),
                      onPressed: stream.name.contains('[PM+]') 
                          ? null 
                          : () => _sendToPremiumize(context, ref, _getStreamUrl(stream)),
                    ),
                  ),
                );
              },
            ),
    );
  }
} 