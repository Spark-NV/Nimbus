import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:logger/logger.dart';
import 'premiumize_repository.dart';
import 'premiumize_transfer.dart';

class PremiumizeTransfersScreen extends ConsumerStatefulWidget {
  const PremiumizeTransfersScreen({super.key});

  @override
  ConsumerState<PremiumizeTransfersScreen> createState() => _PremiumizeTransfersScreenState();
}

class _PremiumizeTransfersScreenState extends ConsumerState<PremiumizeTransfersScreen> {
  final _logger = Logger();

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(premiumizeRepositoryProvider.notifier).refreshTransfers());
  }

  @override
  Widget build(BuildContext context) {
    final transfersAsync = ref.watch(premiumizeRepositoryProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          'Premiumize Transfers',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20.sp,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, size: 24.sp, color: Colors.white),
            onPressed: () => ref.read(premiumizeRepositoryProvider.notifier).refreshTransfers(),
          ),
          IconButton(
            icon: Icon(Icons.delete_sweep, size: 24.sp, color: Colors.white),
            onPressed: () => _showClearFinishedDialog(),
          ),
        ],
      ),
      body: transfersAsync.when(
        data: (transfers) => _buildTransfersList(transfers),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text(
            'Error: ${error.toString()}',
            style: TextStyle(color: Colors.red, fontSize: 16.sp),
          ),
        ),
      ),
    );
  }

  Widget _buildTransfersList(List<PremiumizeTransfer> transfers) {
    if (transfers.isEmpty) {
      return Center(
        child: Text(
          'No transfers found',
          style: TextStyle(color: Colors.white, fontSize: 16.sp),
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16.r),
      itemCount: transfers.length,
      itemBuilder: (context, index) {
        final transfer = transfers[index];
        return _TransferCard(
          transfer: transfer,
          onDelete: () => _showDeleteDialog(transfer),
        );
      },
    );
  }

  Future<void> _showDeleteDialog(PremiumizeTransfer transfer) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text(
          'Delete Transfer',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Are you sure you want to delete "${transfer.name}"?',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ref.read(premiumizeRepositoryProvider.notifier).deleteTransfer(transfer.id);
        _logger.i('Transfer deleted successfully: ${transfer.id}');
      } catch (e) {
        _logger.e('Error deleting transfer', error: e);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete transfer: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _showClearFinishedDialog() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text(
          'Clear Finished Transfers',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Are you sure you want to clear all finished transfers?',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Clear',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ref.read(premiumizeRepositoryProvider.notifier).clearFinishedTransfers();
        _logger.i('Finished transfers cleared successfully');
      } catch (e) {
        _logger.e('Error clearing finished transfers', error: e);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to clear finished transfers: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}

class _TransferCard extends StatelessWidget {
  final PremiumizeTransfer transfer;
  final VoidCallback onDelete;

  const _TransferCard({
    required this.transfer,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    transfer.name,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.delete_outline, size: 20.w),
                  onPressed: onDelete,
                ),
              ],
            ),
            SizedBox(height: 8.h),
            Row(
              children: [
                Container(
                  width: 8.w,
                  height: 8.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: transfer.isError
                        ? Colors.red
                        : transfer.isFinished
                            ? Colors.green
                            : Colors.blue,
                  ),
                ),
                SizedBox(width: 8.w),
                Text(
                  transfer.status.toUpperCase(),
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: transfer.isError
                        ? Colors.red
                        : transfer.isFinished
                            ? Colors.green
                            : Colors.blue,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            LinearProgressIndicator(
              value: transfer.progress / 100,
              backgroundColor: Colors.grey[800],
              valueColor: AlwaysStoppedAnimation<Color>(
                transfer.isError
                    ? Colors.red
                    : transfer.isFinished
                        ? Colors.green
                        : Colors.blue,
              ),
            ),
            SizedBox(height: 8.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${transfer.currentSize} ${transfer.sizeUnit} of ${transfer.totalSize} ${transfer.sizeUnit}',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey[400],
                  ),
                ),
                Text(
                  '${transfer.progress.toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey[400],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
} 