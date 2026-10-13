import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../core/constants/app_constants.dart';
import '../../data/models/chat_message_model.dart';
import 'badge_counter_provider.dart';

class ChatProvider with ChangeNotifier {
  final FirebaseFirestore? _customFirestore;
  BadgeCounterNotifier? _badgeCounterNotifier;

  ChatProvider({FirebaseFirestore? firestore})
      : _customFirestore = firestore;

  FirebaseFirestore? get _firestore {
    if (_customFirestore != null) return _customFirestore;
    try {
      return FirebaseFirestore.instance;
    } catch (_) {
      return null;
    }
  }

  List<ChatMessageModel> _messages = [];
  List<ChatMessageModel> get messages => _messages;

  StreamSubscription? _chatSubscription;

  void setBadgeCounterNotifier(BadgeCounterNotifier? notifier) {
    _badgeCounterNotifier = notifier;
  }

  /// Cập nhật badge counter tự động dựa trên số lượng tin nhắn chưa đọc từ đối phương
  void updateUnreadBadgeCount(String currentUserId) {
    if (_badgeCounterNotifier == null) return;
    int unreadCount = 0;
    for (var msg in _messages) {
      final isForMe = msg.maNguoiNhan == currentUserId ||
          msg.maNguoiNhan == 'CURRENT_USER' ||
          currentUserId == 'CURRENT_USER';
      final isNotFromMe = msg.maNguoiGui != currentUserId &&
          !(currentUserId == 'CURRENT_USER' && msg.maNguoiGui == 'CURRENT_USER');
      if (isForMe && isNotFromMe && !msg.isDaXem) {
        unreadCount++;
      }
    }
    _badgeCounterNotifier!.setCount(unreadCount);
  }

  /// Đánh dấu tất cả tin nhắn từ người gửi [targetUserId] cho [currentUserId] là đã xem
  void markMessagesAsRead(String currentUserId, String targetUserId) {
    bool updated = false;
    for (int i = 0; i < _messages.length; i++) {
      final msg = _messages[i];
      final isFromTarget = msg.maNguoiGui == targetUserId ||
          (targetUserId == 'LANDLORD_1' && msg.maNguoiGui.contains('LANDLORD'));
      final isForMe = msg.maNguoiNhan == currentUserId ||
          msg.maNguoiNhan == 'CURRENT_USER' ||
          currentUserId == 'CURRENT_USER';

      if (isFromTarget && isForMe && !msg.isDaXem) {
        _messages[i] = ChatMessageModel(
          maTinNhan: msg.maTinNhan,
          maNguoiGui: msg.maNguoiGui,
          maNguoiNhan: msg.maNguoiNhan,
          maPhong: msg.maPhong,
          noiDung: msg.noiDung,
          thoiGian: msg.thoiGian,
          imageUrl: msg.imageUrl,
          isDaXem: true,
        );
        updated = true;

        if (_firestore != null) {
          try {
            _firestore!
                .collection(AppConstants.colTinNhan)
                .doc(msg.maTinNhan)
                .update({'IsDaXem': true});
          } catch (e) {
            debugPrint('Error updating IsDaXem in firestore: $e');
          }
        }
      }
    }

    if (updated) {
      notifyListeners();
      updateUnreadBadgeCount(currentUserId);
    }
  }

  /// Khởi tạo lắng nghe tin nhắn cho người dùng từ Firestore
  void listenToMessages(String currentUserId) {
    if (_firestore == null || currentUserId.isEmpty) return;

    _chatSubscription?.cancel();
    try {
      _chatSubscription = _firestore!
          .collection(AppConstants.colTinNhan)
          .orderBy('ThoiGian', descending: false)
          .snapshots()
          .listen((snapshot) {
        _messages = snapshot.docs
            .map((doc) => ChatMessageModel.fromMap(doc.data(), doc.id))
            .where((m) =>
                m.maNguoiGui == currentUserId ||
                m.maNguoiNhan == currentUserId ||
                m.maNguoiGui == 'CURRENT_USER' ||
                m.maNguoiNhan == 'CURRENT_USER')
            .toList();
        notifyListeners();
        updateUnreadBadgeCount(currentUserId);
      }, onError: (e) {
        debugPrint('Error listening to chat messages: $e');
      });
    } catch (e) {
      debugPrint('Error initializing chat listener: $e');
    }
  }

  /// Tải tin nhắn ban đầu (Mock hoặc Firestore)
  Future<void> fetchMessages(String currentUserId) async {
    if (_firestore != null) {
      try {
        final snapshot = await _firestore!
            .collection(AppConstants.colTinNhan)
            .get();
        _messages = snapshot.docs
            .map((doc) => ChatMessageModel.fromMap(doc.data(), doc.id))
            .toList();
        notifyListeners();
        updateUnreadBadgeCount(currentUserId);
      } catch (e) {
        debugPrint('Error fetching chat messages: $e');
      }
    }
  }

  /// Gửi tin nhắn mới
  Future<bool> sendMessage(ChatMessageModel msg, {String? currentUserId}) async {
    _messages.add(msg);
    notifyListeners();

    // Tự động tăng/cập nhật badge counter nếu đây là tin nhắn từ đối phương gửi tới mình
    final activeUserId = currentUserId ?? 'CURRENT_USER';
    final isForMe = msg.maNguoiNhan == activeUserId || msg.maNguoiNhan == 'CURRENT_USER';
    final isNotFromMe = msg.maNguoiGui != activeUserId &&
        !(activeUserId == 'CURRENT_USER' && msg.maNguoiGui == 'CURRENT_USER');

    if (!msg.isDaXem && isForMe && isNotFromMe) {
      _badgeCounterNotifier?.incrementMessages();
    }

    if (_firestore != null) {
      try {
        await _firestore!
            .collection(AppConstants.colTinNhan)
            .doc(msg.maTinNhan)
            .set(msg.toMap());
      } catch (e) {
        debugPrint('Error saving chat message to firestore: $e');
      }
    }
    return true;
  }

  /// Lấy danh sách tin nhắn giữa 2 người dùng cụ thể
  List<ChatMessageModel> getMessagesBetween(String user1, String user2) {
    final list = _messages.where((m) {
      final isSender1 = m.maNguoiGui == user1 || (user1 == 'CURRENT_USER' && m.maNguoiGui == user1);
      final isReceiver2 = m.maNguoiNhan == user2 || (user2 == 'LANDLORD_1' && m.maNguoiNhan == user2);
      final isSender2 = m.maNguoiGui == user2 || (user2 == 'LANDLORD_1' && m.maNguoiGui == user2);
      final isReceiver1 = m.maNguoiNhan == user1 || (user1 == 'CURRENT_USER' && m.maNguoiNhan == user1);

      return (isSender1 && isReceiver2) || (isSender2 && isReceiver1);
    }).toList();

    list.sort((a, b) => a.thoiGian.compareTo(b.thoiGian));
    return list;
  }

  /// Hàm chuyển đổi ID đối phương sang Tên hiển thị chuẩn ("Chủ trọ 1", "Sinh viên 1", ...)
  String getUserDisplayName(String id, {bool isLandlord = false}) {
    final clean = id.trim().toUpperCase();
    if (clean.isEmpty) return isLandlord ? 'Sinh viên 1' : 'Chủ trọ 1';

    // Trích xuất số đuôi thứ tự (ví dụ: CT002 -> 2, SV-20260808-003 -> 3, LANDLORD_1 -> 1)
    int? number;
    final match = RegExp(r'(\d+)$').firstMatch(clean);
    if (match != null) {
      number = int.tryParse(match.group(1)!);
    }
    final numStr = number != null ? '$number' : '1';

    if (clean.contains('LANDLORD') || clean.contains('CT')) {
      return 'Chủ trọ $numStr';
    }
    if (clean.contains('STUDENT') || clean.contains('SV')) {
      return 'Sinh viên $numStr';
    }

    if (clean == 'CURRENT_USER') {
      return isLandlord ? 'Sinh viên 1' : 'Chủ trọ 1';
    }

    return isLandlord ? 'Sinh viên $numStr' : 'Chủ trọ $numStr';
  }

  /// Lấy danh sách các cuộc trò chuyện (Conversations) cho màn hình MessagesScreen
  List<Map<String, String>> getConversationsForUser(String currentUserId, {bool isLandlord = false}) {
    final Map<String, ChatMessageModel> latestMsgs = {};

    for (var msg in _messages) {
      String counterpartId = '';
      if (msg.maNguoiGui == currentUserId || msg.maNguoiGui == 'CURRENT_USER') {
        counterpartId = msg.maNguoiNhan;
      } else {
        counterpartId = msg.maNguoiGui;
      }

      if (counterpartId.isEmpty) continue;

      if (!latestMsgs.containsKey(counterpartId)) {
        latestMsgs[counterpartId] = msg;
      } else {
        final existing = latestMsgs[counterpartId]!;
        if (msg.thoiGian.isAfter(existing.thoiGian)) {
          latestMsgs[counterpartId] = msg;
        }
      }
    }

    final conversations = latestMsgs.entries.map((entry) {
      final counterpartId = entry.key;
      final lastMsg = entry.value;

      String name = getUserDisplayName(counterpartId, isLandlord: isLandlord);

      final isForMe = lastMsg.maNguoiNhan == currentUserId ||
          lastMsg.maNguoiNhan == 'CURRENT_USER' ||
          currentUserId == 'CURRENT_USER';
      final isUnread = !lastMsg.isDaXem && isForMe && lastMsg.maNguoiGui != currentUserId;

      return {
        'id': counterpartId,
        'name': name,
        'phone': '0988776655',
        'room': lastMsg.maPhong,
        'lastMsg': lastMsg.noiDung.isNotEmpty ? lastMsg.noiDung : '[Hình ảnh]',
        'time': '${lastMsg.thoiGian.hour.toString().padLeft(2, '0')}:${lastMsg.thoiGian.minute.toString().padLeft(2, '0')}',
        'unread': isUnread ? '1' : '0',
      };
    }).toList();

    return conversations;
  }

  @override
  void dispose() {
    _chatSubscription?.cancel();
    super.dispose();
  }
}
