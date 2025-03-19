import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io' show Platform;
import '../services/background_service.dart';

class NotificationCenter extends StatefulWidget {
  const NotificationCenter({super.key});

  @override
  State<NotificationCenter> createState() => _NotificationCenterState();
}

class _NotificationCenterState extends State<NotificationCenter> {
  final BackgroundService _backgroundService = BackgroundService();
  List<Map<String, dynamic>> _notifications = [];

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  void _loadNotifications() {
    // TODO: Implement actual notification loading
    _notifications = [
      {
        'id': 1,
        'title': 'New Report Available',
        'message': 'A new medical report has been added to your profile.',
        'timestamp': DateTime.now(),
        'isRead': false,
      },
      // Add more sample notifications as needed
    ];
  }

  Widget _buildIOSContent() {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Notifications'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: Text('Clear All'),
          onPressed: null, // TODO: Implement clear all
        ),
      ),
      child: SafeArea(
        child: _buildNotificationsList(),
      ),
    );
  }

  Widget _buildMaterialContent() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () {
              // TODO: Implement clear all
            },
          ),
        ],
      ),
      body: _buildNotificationsList(),
    );
  }

  Widget _buildNotificationsList() {
    if (_notifications.isEmpty) {
      return Center(
        child: Text(
          'No notifications',
          style: Theme.of(context).textTheme.titleLarge,
        ),
      );
    }

    return ListView.builder(
      itemCount: _notifications.length,
      itemBuilder: (context, index) {
        final notification = _notifications[index];
        return ListTile(
          title: Text(notification['title']),
          subtitle: Text(notification['message']),
          trailing: Text(
            _formatTimestamp(notification['timestamp']),
            style: Theme.of(context).textTheme.bodySmall,
          ),
          onTap: () {
            // TODO: Handle notification tap
          },
        );
      },
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Platform.isIOS ? _buildIOSContent() : _buildMaterialContent();
  }
} 