import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../providers/pulse_provider.dart';

class PulseView extends StatefulWidget {
  const PulseView({super.key});

  @override
  State<PulseView> createState() => _PulseViewState();
}

class _PulseViewState extends State<PulseView>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pulseProvider = Provider.of<PulseProvider>(context);
    final state = pulseProvider.state;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF101018).withAlpha(200),
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: const Color(0xFF00E5FF).withAlpha(50)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00E5FF).withAlpha(20),
            blurRadius: 30.r,
            spreadRadius: -5.r,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24.r),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Padding(
            padding: EdgeInsets.all(24.0.r),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        AnimatedBuilder(
                          animation: _pulseController,
                          builder: (context, child) {
                            return Container(
                              width: 8.r,
                              height: 8.r,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color.lerp(
                                  const Color(0xFF00E5FF),
                                  Colors.white,
                                  _pulseController.value,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(
                                      0xFF00E5FF,
                                    ).withAlpha(150),
                                    blurRadius:
                                        (8 * _pulseController.value + 4).r,
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          'SERVER: ${state.serverStatus}',
                          style: TextStyle(
                            color: const Color(0xFF00E5FF),
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                            fontSize: 12.sp,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.people_outline,
                          color: Colors.white54,
                          size: 16.r,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          state.concurrentPlayers.toString().replaceAllMapped(
                            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                            (Match m) => '${m[1]},',
                          ),
                          style: TextStyle(
                            color: Colors.white70,
                            fontWeight: FontWeight.bold,
                            fontSize: 12.sp,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 24.h),
                // Title
                Text(
                  'WORLD EVENT',
                  style: TextStyle(
                    color: const Color(0xFFFF003C),
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 4,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'ANCIENT DRAGON AWAKENS',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24.sp,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                  ),
                ),
                SizedBox(height: 32.h),
                RepaintBoundary(
                  child: ValueListenableBuilder<int>(
                    valueListenable: pulseProvider.timeRemaining,
                    builder: (context, timeRemaining, child) {
                      final seconds = (timeRemaining / 1000.0);
                      final progress = timeRemaining / 600000;
                      return Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 140.w,
                            height: 140.h,
                            child: CircularProgressIndicator(
                              value: progress,
                              strokeWidth: 6.r,
                              backgroundColor: const Color(
                                0xFF00E5FF,
                              ).withAlpha(20),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Color.lerp(
                                      const Color(0xFFFF003C),
                                      const Color(0xFF00E5FF),
                                      progress,
                                    ) ??
                                    const Color(0xFF00E5FF),
                              ),
                            ),
                          ),
                          Container(
                            width: 120.w,
                            height: 120.h,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF00E5FF).withAlpha(10),
                                  blurRadius: 20.r,
                                  spreadRadius: 5.r,
                                ),
                              ],
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              '${seconds.toStringAsFixed(1)}s',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 32.sp,
                                fontWeight: FontWeight.w900,
                                fontFeatures: const [
                                  FontFeature.tabularFigures(),
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
