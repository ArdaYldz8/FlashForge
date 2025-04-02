import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flashforge/presentation/app.dart';
import 'package:flashforge/config/app_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp();
  
  // Initialize app configuration
  await AppConfig.initialize();
  
  runApp(
    // ProviderScope enables Riverpod for the entire app
    const ProviderScope(
      child: FlashForgeApp(),
    ),
  );
}
