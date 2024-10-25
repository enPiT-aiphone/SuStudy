import 'package:flutter/material.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart';

class BadgeViewModel extends ChangeNotifier {
  int _badgeCount = 0;

  int get badgeCount => _badgeCount;

  // バッジ数を更新する
  void updateBadgeCount(int count) {
    _badgeCount = count;
    if (count > 0) {
      FlutterAppBadger.updateBadgeCount(count); // 通知数が1以上の場合、バッジを表示
    } else {
      FlutterAppBadger.removeBadge(); // 通知数が0の場合、バッジを消去
    }
    notifyListeners(); // 状態の更新を通知
  }

  // バッジを増やす
  void incrementBadge() {
    updateBadgeCount(_badgeCount + 1);
  }

  // バッジを減らす
  void decrementBadge() {
    if (_badgeCount > 0) {
      updateBadgeCount(_badgeCount - 1);
    }
  }

  // バッジをクリアする
  void clearBadge() {
    updateBadgeCount(0);
  }
}
