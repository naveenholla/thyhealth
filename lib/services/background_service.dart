import 'dart:async';

class BackgroundService {
  final _notificationController = StreamController<int>.broadcast();
  int _unreadNotificationsCount = 0;

  Stream<int> get notificationStream => _notificationController.stream;
  int get unreadNotificationsCount => _unreadNotificationsCount;

  void updateNotificationCount(int count) {
    _unreadNotificationsCount = count;
    _notificationController.add(count);
  }

  void incrementNotificationCount() {
    _unreadNotificationsCount++;
    _notificationController.add(_unreadNotificationsCount);
  }

  void clearNotifications() {
    _unreadNotificationsCount = 0;
    _notificationController.add(0);
  }
} 