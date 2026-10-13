import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart' as legacy_provider;
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_gradients.dart';
import '../../../core/utils/code_generator_util.dart';
import '../../../data/models/chat_message_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/badge_counter_provider.dart';
import '../../providers/chat_provider.dart';

class ChatDetailScreen extends ConsumerStatefulWidget {
  final String targetUserId;
  final String targetUserName;
  final String targetUserPhone;
  final String roomId;

  const ChatDetailScreen({
    super.key,
    String? targetUserId,
    String? targetUserName,
    String? receiverId,
    String? receiverName,
    String? roomTitle,
    this.targetUserPhone = '0988776655',
    String? roomId,
  })  : targetUserId = targetUserId ?? receiverId ?? 'LANDLORD_1',
        targetUserName = targetUserName ?? receiverName ?? 'Chủ trọ',
        roomId = roomId ?? roomTitle ?? '';

  @override
  ConsumerState<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends ConsumerState<ChatDetailScreen> {
  final _msgController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = legacy_provider.Provider.of<AuthProvider>(context, listen: false);
      final chatProvider = legacy_provider.Provider.of<ChatProvider>(context, listen: false);
      final myId = authProvider.currentUser?.maTK ?? 'CURRENT_USER';
      chatProvider.setBadgeCounterNotifier(ref.read(badgeCounterProvider.notifier));
      chatProvider.markMessagesAsRead(myId, widget.targetUserId);
    });
  }

  void _simulateOpponentMessage() async {
    final authProvider = legacy_provider.Provider.of<AuthProvider>(context, listen: false);
    final chatProvider = legacy_provider.Provider.of<ChatProvider>(context, listen: false);

    final currentUser = authProvider.currentUser;
    final myId = currentUser?.maTK ?? 'CURRENT_USER';

    chatProvider.setBadgeCounterNotifier(ref.read(badgeCounterProvider.notifier));

    final incomingMsg = ChatMessageModel(
      maTinNhan: CodeGeneratorUtil.generateMessageCode(),
      maNguoiGui: widget.targetUserId,
      maNguoiNhan: myId,
      maPhong: widget.roomId,
      noiDung: 'Chào bạn, phòng trọ hiện tại vẫn còn trống nhé! Vui lòng cho mình biết thêm thông tin.',
      thoiGian: DateTime.now(),
      isDaXem: false,
    );

    await chatProvider.sendMessage(incomingMsg, currentUserId: myId);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã nhận 1 tin nhắn mới từ đối phương! (Badge +1)'),
          backgroundColor: AppColors.success,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _sendMessage({String? imageUrl}) async {
    final text = _msgController.text.trim();
    if (text.isEmpty && imageUrl == null) return;

    if (text.length > 1000) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tin nhắn không vượt quá 1000 ký tự')),
      );
      return;
    }

    final authProvider = legacy_provider.Provider.of<AuthProvider>(context, listen: false);
    final chatProvider = legacy_provider.Provider.of<ChatProvider>(context, listen: false);

    final currentUser = authProvider.currentUser;
    final senderId = currentUser?.maTK ?? 'CURRENT_USER';

    final newMsg = ChatMessageModel(
      maTinNhan: CodeGeneratorUtil.generateMessageCode(),
      maNguoiGui: senderId,
      maNguoiNhan: widget.targetUserId,
      maPhong: widget.roomId,
      noiDung: text,
      imageUrl: imageUrl,
      thoiGian: DateTime.now(),
      isDaXem: false,
    );

    _msgController.clear();
    await chatProvider.sendMessage(newMsg);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _makePhoneCall(String displayName) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: const [
              Icon(Icons.phone_rounded, color: AppColors.primaryLight),
              SizedBox(width: 8),
              Text('Gọi điện thoại'),
            ],
          ),
          content: Text(
            'Thực hiện cuộc gọi điện thoại trực tiếp tới $displayName qua số:\n\n${widget.targetUserPhone}',
            style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Hủy'),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Đang kết nối cuộc gọi thoại tới ${widget.targetUserPhone}...'),
                    backgroundColor: AppColors.success,
                  ),
                );
              },
              icon: const Icon(Icons.call_rounded, size: 18, color: Colors.white),
              label: const Text('Gọi ngay', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
            ),
          ],
        );
      },
    );
  }

  void _sendSampleContractImage() {
    _sendMessage(
      imageUrl: 'https://images.unsplash.com/photo-1450133064473-71024230f91b?w=800',
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = legacy_provider.Provider.of<AuthProvider>(context);
    final chatProvider = legacy_provider.Provider.of<ChatProvider>(context);

    final currentUser = authProvider.currentUser;
    final myId = currentUser?.maTK ?? 'CURRENT_USER';
    final isLandlord = currentUser?.vaiTro == AppConstants.roleLandlord;

    String displayName = widget.targetUserName;
    if (displayName.isEmpty ||
        displayName == 'Chủ trọ' ||
        displayName == 'Sinh viên' ||
        displayName.contains('LANDLORD') ||
        displayName.contains('STUDENT') ||
        displayName.contains('SV') ||
        displayName.contains('CT') ||
        displayName.contains('(')) {
      displayName = chatProvider.getUserDisplayName(widget.targetUserId, isLandlord: isLandlord);
    }

    final messages = chatProvider.getMessagesBetween(myId, widget.targetUserId);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(displayName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
            Text('SĐT: ${widget.targetUserPhone} • Trực tuyến', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.mark_chat_unread_outlined),
            tooltip: 'Đối phương nhắn tin (+1)',
            onPressed: _simulateOpponentMessage,
          ),
          IconButton(
            icon: const Icon(Icons.phone_rounded),
            tooltip: 'Gọi điện trực tiếp',
            onPressed: () => _makePhoneCall(displayName),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppGradients.background),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: const BoxDecoration(
                color: AppColors.surface,
                border: Border(bottom: BorderSide(color: AppColors.border)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.home_work_rounded, size: 18, color: AppColors.primaryLight),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Đang trao đổi về phòng trọ: #${widget.roomId}',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                    ),
                  ),
                  TextButton(
                    onPressed: _sendSampleContractImage,
                    child: const Text('Gửi hợp đồng mẫu', style: TextStyle(fontSize: 11, color: AppColors.primaryLight, fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
            ),

            Expanded(
              child: messages.isEmpty
                  ? const Center(
                      child: Text(
                        'Bắt đầu cuộc trò chuyện...',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final msg = messages[index];
                        final isMe = msg.maNguoiGui == myId || msg.maNguoiGui == 'CURRENT_USER';
                        return _buildMessageBubble(msg, isMe);
                      },
                    ),
            ),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: const BoxDecoration(
                color: AppColors.surface,
                border: Border(top: BorderSide(color: AppColors.border)),
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.photo_outlined, color: AppColors.primaryLight),
                      tooltip: 'Gửi thêm hình ảnh',
                      onPressed: () {
                        _sendMessage(
                          imageUrl: 'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?w=800',
                        );
                      },
                    ),
                    Expanded(
                      child: TextField(
                        controller: _msgController,
                        maxLength: 1000,
                        style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
                        buildCounter: (context, {required currentLength, required isFocused, maxLength}) => null,
                        decoration: InputDecoration(
                          hintText: 'Nhập tin nhắn (tối đa 1000 ký tự)...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: AppColors.surfaceLight,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        ),
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.send_rounded, color: AppColors.primaryLight),
                      onPressed: () => _sendMessage(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessageModel msg, bool isMe) {
    final timeStr = DateFormat('HH:mm').format(msg.thoiGian);
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isMe ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMe ? 16 : 4),
            bottomRight: Radius.circular(isMe ? 4 : 16),
          ),
          border: isMe ? null : Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (msg.imageUrl != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  msg.imageUrl!,
                  height: 140,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 6),
            ],
            if (msg.noiDung.isNotEmpty)
              Text(
                msg.noiDung,
                style: TextStyle(
                  color: isMe ? Colors.white : AppColors.textPrimary,
                  fontSize: 14,
                ),
              ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  timeStr,
                  style: TextStyle(
                    fontSize: 10,
                    color: isMe ? Colors.white70 : AppColors.textLight,
                  ),
                ),
                if (isMe) ...[
                  const SizedBox(width: 4),
                  Icon(
                    msg.isDaXem ? Icons.done_all_rounded : Icons.done_rounded,
                    size: 14,
                    color: msg.isDaXem ? AppColors.accent : Colors.white70,
                  ),
                  const SizedBox(width: 2),
                  Text(
                    msg.isDaXem ? 'Đã xem' : 'Đã gửi',
                    style: const TextStyle(fontSize: 9, color: Colors.white70),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
