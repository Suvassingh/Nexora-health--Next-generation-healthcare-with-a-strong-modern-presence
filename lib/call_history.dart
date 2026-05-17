import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/api_service.dart';
import 'package:intl/intl.dart';

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
    setState(() {
      _loading = true;
      _error = '';
    });
    try {
      final res = await ApiService.dio.get('/calls/history');
      final data = res.data as List<dynamic>;
      _calls = data.cast<Map<String, dynamic>>();
    } catch (e) {
      _error = e.toString();
      if (mounted) Get.snackbar('Error', _error);
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
                      c['other_name'] ?? c['remote_name'] ?? 'Unknown';
                  final status = c['status'] ?? '';
                  final isVideo = (c['call_type'] ?? '') == 'video';
                  final startedAt = _formatDate(c['started_at']?.toString());
                  final duration = c['duration'] != null
                      ? '${c['duration']}s'
                      : '';
                  return ListTile(
                    leading: CircleAvatar(
                      child: Text(
                        otherName.isNotEmpty ? otherName[0].toUpperCase() : '?',
                      ),
                    ),
                    title: Text(otherName),
                    subtitle: Text(
                      '$status • ${isVideo ? 'Video' : 'Audio'}${startedAt.isNotEmpty ? ' • $startedAt' : ''}',
                    ),
                    trailing: duration.isNotEmpty ? Text(duration) : null,
                    onTap: () {
                      Get.toNamed('/call/${c['id']}'); // TODO: navigate to call screen
                      },
                  );
                },
              ),
      ),
    );
  }
}
