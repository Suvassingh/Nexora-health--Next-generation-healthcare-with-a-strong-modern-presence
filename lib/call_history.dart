


import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../services/api_service.dart';

class CallHistoryScreen extends StatefulWidget {
  const CallHistoryScreen({super.key});

  @override
  State<CallHistoryScreen> createState() => _CallHistoryScreenState();
}

class _CallHistoryScreenState extends State<CallHistoryScreen> {
  bool _loading = true;
  List<Map<String, dynamic>> _calls = [];
  String _error = '';

  @override
  void initState() {
    super.initState();
    _fetchHistory();
  }

  Future<void> _fetchHistory() async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _error   = '';
    });

    try {
      final res  = await ApiService.dio.get('/calls/history');
      final data = res.data;
      if (data is List) {
        _calls = data.cast<Map<String, dynamic>>();
      } else {
        _calls = [];
      }
    } catch (e) {
      _error = e.toString();
      if (mounted) {
        Get.snackbar(
          'Error',
          _error,
          backgroundColor: Colors.red.shade800,
          colorText: Colors.white,
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _formatDate(String? iso) {
    if (iso == null) return '';
    try {
      final dt = DateTime.parse(iso).toLocal();
      return DateFormat.yMMMd().add_jm().format(dt);
    } catch (_) {
      return iso;
    }
  }

  String _formatDuration(dynamic raw) {
    if (raw == null) return '';
    final secs = raw is int ? raw : int.tryParse(raw.toString()) ?? 0;
    if (secs <= 0) return '';
    final m = secs ~/ 60;
    final s = secs % 60;
    if (m == 0) return '${s}s';
    return '${m}m ${s}s';
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'ended':
        return Colors.green;
      case 'missed':
        return Colors.orange;
      case 'declined':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _statusIcon(String status, bool isVideo) {
    if (status == 'missed' || status == 'declined') {
      return Icons.call_missed;
    }
    return isVideo ? Icons.videocam : Icons.call;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Call History')),
      body: RefreshIndicator(
        onRefresh: _fetchHistory,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _calls.isEmpty
            ? ListView(
          children: const [
            SizedBox(height: 120),
            Center(child: Text('No calls yet')),
          ],
        )
            : ListView.separated(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          itemCount: _calls.length,
          separatorBuilder: (_, __) => const Divider(),
          itemBuilder: (context, i) {
            final c = _calls[i];
            final otherName =
            (c['other_name'] ?? c['remote_name'] ?? 'Unknown')
            as String;
            final status  = (c['status'] ?? '') as String;
            final isVideo = (c['call_type'] ?? '') == 'video';
            final startedAt =
            _formatDate(c['started_at']?.toString());
            final duration = _formatDuration(c['duration']);

            return ListTile(
              leading: CircleAvatar(
                backgroundColor: _statusColor(status).withOpacity(0.15),
                child: Icon(
                  _statusIcon(status, isVideo),
                  color: _statusColor(status),
                  size: 20,
                ),
              ),
              title: Text(
                otherName,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                [
                  status,
                  isVideo ? 'Video' : 'Audio',
                  if (startedAt.isNotEmpty) startedAt,
                ].join(' • '),
                style: TextStyle(
                  color: _statusColor(status),
                  fontSize: 12,
                ),
              ),
              trailing: duration.isNotEmpty
                  ? Text(
                duration,
                style: const TextStyle(fontSize: 12),
              )
                  : null,
             
              // onTap: () => Get.toNamed('/call/${c['id']}'),
            );
          },
        ),
      ),
    );
  }
}