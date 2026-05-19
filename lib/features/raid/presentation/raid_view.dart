import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../providers/raid_provider.dart';
import '../models/raid_event_model.dart';

class RaidView extends StatefulWidget {
  const RaidView({super.key});

  @override
  State<RaidView> createState() => _RaidViewState();
}

class _RaidViewState extends State<RaidView>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _handleJoinRaid(
    BuildContext context,
    RaidProvider provider,
  ) async {
    if (provider.isJoining || provider.joinSuccess) return;

    final userId = 'user_${DateTime.now().millisecondsSinceEpoch}';
    final success = await provider.joinRaidSequence(userId: userId);

    if (context.mounted) {
      if (!success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Color(0xFFFF003C),
            content: Text(
              'Raid is full!',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final raidProvider = Provider.of<RaidProvider>(context);

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF101018).withAlpha(200),
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: const Color(0xFFFF003C).withAlpha(30)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF003C).withAlpha(15),
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
            child: StreamBuilder<RaidEventModel>(
              stream: raidProvider.raidEventStream,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return SizedBox(
                    height: 200.h,
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFFFF003C),
                      ),
                    ),
                  );
                }

                final event = snapshot.data!;
                final slotsFilled = event.slotsFilled;
                final maxSlots = event.maxSlots;
                final isFull = slotsFilled >= maxSlots;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'RAID SQUAD',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 4.h,
                          ),
                          decoration: BoxDecoration(
                            color: isFull
                                ? const Color(0xFFFF003C).withAlpha(20)
                                : const Color(0xFF00E5FF).withAlpha(20),
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(
                              color: isFull
                                  ? const Color(0xFFFF003C)
                                  : const Color(0xFF00E5FF),
                            ),
                          ),
                          child: Text(
                            '$slotsFilled / $maxSlots',
                            style: TextStyle(
                              color: isFull
                                  ? const Color(0xFFFF003C)
                                  : const Color(0xFF00E5FF),
                              fontWeight: FontWeight.bold,
                              fontFeatures: const [
                                FontFeature.tabularFigures(),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 24.h),

                    // Slot Grid
                    Wrap(
                      spacing: 8.w,
                      runSpacing: 8.h,
                      alignment: WrapAlignment.center,
                      children: List.generate(maxSlots, (index) {
                        final isFilled = index < slotsFilled;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: 40.w,
                          height: 40.h,
                          decoration: BoxDecoration(
                            color: isFilled
                                ? const Color(0xFF00E5FF).withAlpha(40)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(8.r),
                            border: Border.all(
                              color: isFilled
                                  ? const Color(0xFF00E5FF)
                                  : Colors.white.withAlpha(20),
                            ),
                            boxShadow: isFilled
                                ? [
                                    BoxShadow(
                                      color: const Color(
                                        0xFF00E5FF,
                                      ).withAlpha(50),
                                      blurRadius: 10.r,
                                    ),
                                  ]
                                : null,
                          ),
                          child: isFilled
                              ? Icon(
                                  Icons.person,
                                  color: const Color(0xFF00E5FF),
                                  size: 24.r,
                                )
                              : Icon(
                                  Icons.add,
                                  color: Colors.white12,
                                  size: 20.r,
                                ),
                        );
                      }),
                    ),

                    SizedBox(height: 32.h),

                    // Join Button
                    AnimatedBuilder(
                      animation: _pulseController,
                      builder: (context, child) {
                        return Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12.r),
                            boxShadow:
                                (raidProvider.joinSuccess ||
                                    raidProvider.isJoining ||
                                    isFull)
                                ? null
                                : [
                                    BoxShadow(
                                      color: const Color(0xFF00E5FF).withAlpha(
                                        (30 * _pulseController.value + 20)
                                            .toInt(),
                                      ),
                                      blurRadius:
                                          (15 * _pulseController.value + 10).r,
                                      spreadRadius: 2.r,
                                    ),
                                  ],
                          ),
                          child: child,
                        );
                      },
                      child: ElevatedButton(
                        onPressed: (isFull || raidProvider.joinSuccess)
                            ? null
                            : () => _handleJoinRaid(context, raidProvider),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: raidProvider.joinSuccess
                              ? const Color(0xFF00E5FF).withAlpha(50)
                              : const Color(0xFF00E5FF),
                          foregroundColor: Colors.black,
                          disabledBackgroundColor: const Color(0xFF1A1A24),
                          disabledForegroundColor: Colors.white54,
                          padding: EdgeInsets.symmetric(vertical: 20.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                            side: BorderSide(
                              color: raidProvider.joinSuccess
                                  ? const Color(0xFF00E5FF)
                                  : Colors.transparent,
                            ),
                          ),
                          elevation: 0,
                        ),
                        child: raidProvider.isJoining
                            ? SizedBox(
                                height: 20.h,
                                width: 20.w,
                                child: const CircularProgressIndicator(
                                  color: Colors.black,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                raidProvider.joinSuccess
                                    ? 'SQUAD JOINED'
                                    : isFull
                                    ? 'RAID FULL'
                                    : 'INITIALIZE JOIN SEQUENCE',
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing:
                                      raidProvider.joinSuccess || isFull
                                      ? 2
                                      : 1,
                                  color: raidProvider.joinSuccess
                                      ? const Color(0xFF00E5FF)
                                      : (isFull
                                            ? Colors.white54
                                            : Colors.black),
                                ),
                              ),
                      ),
                    ),

                    SizedBox(height: 16.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.security, size: 12.r, color: Colors.white30),
                        SizedBox(width: 6.w),
                        Text(
                          'HIGH CONCURRENCY PROTECTED VIA ATOMIC TRANSACTIONS',
                          style: TextStyle(
                            color: Colors.white.withAlpha(80),
                            fontSize: 9.sp,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
