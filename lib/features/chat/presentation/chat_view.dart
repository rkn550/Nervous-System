import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../providers/chat_provider.dart';
import '../models/chat_message_model.dart';

class ChatView extends StatefulWidget {
  const ChatView({super.key});

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  final TextEditingController _messageController = TextEditingController();

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage(ChatProvider chatProvider) async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    _messageController.clear();

    final success = await chatProvider.sendMessage(text);
    if (!success && mounted) {
      final error = chatProvider.errorMessage ?? 'Unknown transmission error';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFFFF003C),
          content: Text(
            'Transmission failed: $error',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);

    return Container(
      height: 400.h,
      decoration: BoxDecoration(
        color: const Color(0xFF101018).withAlpha(200),
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: Colors.white.withAlpha(20)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00E5FF).withAlpha(5),
            blurRadius: 30.r,
            spreadRadius: -5.r,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24.r),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Column(
            children: [
              // Header
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(5),
                  border: Border(
                    bottom: BorderSide(color: Colors.white.withAlpha(10)),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'GLOBAL CHAT',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                        fontSize: 14.sp,
                      ),
                    ),
                    Row(
                      children: [
                        Container(
                          width: 8.r,
                          height: 8.r,
                          decoration: const BoxDecoration(
                            color: Color(0xFF00E5FF),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Color(0xFF00E5FF),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          'LIVE FREQUENCY FEED',
                          style: TextStyle(
                            color: Colors.white54,
                            fontSize: 10.sp,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Chat Messages Area
              Expanded(
                child: StreamBuilder<List<ChatMessageModel>>(
                  stream: chatProvider.messagesStream,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF00E5FF),
                        ),
                      );
                    }

                    final messages = snapshot.data!;
                    if (messages.isEmpty) {
                      return Center(
                        child: Text(
                          'NO ACTIVE TRANSMISSIONS',
                          style: TextStyle(
                            color: Colors.white.withAlpha(50),
                            fontSize: 12.sp,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                          ),
                        ),
                      );
                    }

                    return ListView.builder(
                      reverse: true,
                      padding: EdgeInsets.all(16.r),
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final msg = messages[index];
                        final message = msg.message;
                        final senderName = msg.senderName;
                        final senderId = msg.senderId;
                        final timestamp = msg.timestamp;

                        final timeStr = timestamp != null
                            ? '${timestamp.toDate().hour.toString().padLeft(2, '0')}:${timestamp.toDate().minute.toString().padLeft(2, '0')}'
                            : '--:--';

                        final isMe = senderId == chatProvider.myUserId;

                        return Padding(
                          padding: EdgeInsets.only(bottom: 16.h),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment:
                                isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
                            children: [
                              if (!isMe) ...[
                                Container(
                                  width: 32.r,
                                  height: 32.r,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFF003C).withAlpha(20),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: const Color(0xFFFF003C).withAlpha(50),
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.person,
                                    size: 16.r,
                                    color: const Color(0xFFFF003C),
                                  ),
                                ),
                                SizedBox(width: 12.w),
                              ],
                              Flexible(
                                child: Column(
                                  crossAxisAlignment: isMe
                                      ? CrossAxisAlignment.end
                                      : CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        if (!isMe)
                                          Text(
                                            senderName,
                                            style: TextStyle(
                                              color: Colors.white.withAlpha(150),
                                              fontSize: 12.sp,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        if (!isMe) SizedBox(width: 8.w),
                                        Text(
                                          timeStr,
                                          style: TextStyle(
                                            color: Colors.white.withAlpha(80),
                                            fontSize: 10.sp,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 4.h),
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 16.w,
                                        vertical: 12.h,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isMe
                                            ? const Color(0xFF00E5FF).withAlpha(15)
                                            : Colors.white.withAlpha(5),
                                        borderRadius: BorderRadius.circular(12.r).copyWith(
                                          topLeft: isMe
                                              ? Radius.circular(12.r)
                                              : Radius.circular(4.r),
                                          topRight: isMe
                                              ? Radius.circular(4.r)
                                              : Radius.circular(12.r),
                                        ),
                                        border: Border.all(
                                          color: isMe
                                              ? const Color(0xFF00E5FF).withAlpha(30)
                                              : Colors.white.withAlpha(10),
                                        ),
                                      ),
                                      child: Text(
                                        message,
                                        style: TextStyle(
                                          color: Colors.white.withAlpha(220),
                                          fontSize: 14.sp,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (isMe) ...[
                                SizedBox(width: 12.w),
                                Container(
                                  width: 32.r,
                                  height: 32.r,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF00E5FF).withAlpha(20),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: const Color(0xFF00E5FF).withAlpha(50),
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.person,
                                    size: 16.r,
                                    color: const Color(0xFF00E5FF),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),

              // Input Area
              Container(
                padding: EdgeInsets.all(16.r),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(5),
                  border: Border(
                    top: BorderSide(color: Colors.white.withAlpha(10)),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        decoration: BoxDecoration(
                          color: Colors.black.withAlpha(100),
                          borderRadius: BorderRadius.circular(20.r),
                          border: Border.all(color: Colors.white.withAlpha(20)),
                        ),
                        child: TextField(
                          controller: _messageController,
                          style: const TextStyle(color: Colors.white),
                          onSubmitted: (_) => _sendMessage(chatProvider),
                          decoration: InputDecoration(
                            hintText: 'Transmit message...',
                            hintStyle: TextStyle(
                              color: Colors.white.withAlpha(80),
                              fontSize: 14.sp,
                            ),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(vertical: 12.h),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF00E5FF).withAlpha(20),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFF00E5FF).withAlpha(50),
                        ),
                      ),
                      child: IconButton(
                        icon: Icon(
                          Icons.send,
                          color: const Color(0xFF00E5FF),
                          size: 18.r,
                        ),
                        onPressed: () => _sendMessage(chatProvider),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
