import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nervous_system/firebase_options.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'features/raid/services/raid_service.dart';
import 'features/pulse/services/pulse_service.dart';
import 'features/chat/services/chat_service.dart';

import 'features/raid/providers/raid_provider.dart';
import 'features/pulse/providers/pulse_provider.dart';
import 'features/chat/providers/chat_provider.dart';

import 'features/dashboard/presentation/dashboard_screen.dart';
import 'core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final firestore = FirebaseFirestore.instance;

  final docRef = firestore.collection('events').doc('dragon_raid');
  final docSnap = await docRef.get();
  if (!docSnap.exists) {
    await docRef.set({'slots_filled': 0, 'max_slots': 15});
  }

  final pulseService = PulseService();
  final raidService = RaidService(firestore: firestore);
  final chatService = ChatService(firestore: firestore);

  runApp(
    MultiProvider(
      providers: [
        Provider<PulseService>.value(value: pulseService),
        Provider<RaidService>.value(value: raidService),
        Provider<ChatService>.value(value: chatService),
        ChangeNotifierProvider<PulseProvider>(
          create: (_) => PulseProvider(pulseService: pulseService),
        ),
        ChangeNotifierProvider<RaidProvider>(
          create: (_) => RaidProvider(raidService: raidService),
        ),
        ChangeNotifierProvider<ChatProvider>(
          create: (_) => ChatProvider(chatService: chatService),
        ),
      ],
      child: const AetherApp(),
    ),
  );
}

class AetherApp extends StatelessWidget {
  const AetherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          title: 'Aether Dashboard',
          theme: AppTheme.darkTheme,
          home: const NervousSystemScreen(),
        );
      },
    );
  }
}
