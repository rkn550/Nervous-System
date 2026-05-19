import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../chat/presentation/chat_view.dart';
import '../../pulse/presentation/pulse_view.dart';
import '../../raid/presentation/raid_view.dart';

class NervousSystemScreen extends StatelessWidget {
  const NervousSystemScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topCenter,
            radius: 1.5,
            colors: [Color(0xFF121428), Color(0xFF050508)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: 24.0.w,
              vertical: 32.0.h,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const PulseView(),
                SizedBox(height: 32.h),
                const RaidView(),
                SizedBox(height: 32.h),
                const ChatView(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
