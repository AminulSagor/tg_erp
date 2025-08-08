import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'firebase_options.dart';
import 'routes.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await Supabase.initialize(
    url: 'https://bakvhwctfncjpopdguky.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJha3Zod2N0Zm5janBvcGRndWt5Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTA5NTI4NTcsImV4cCI6MjA2NjUyODg1N30.Os0AzWW8cLV5M31ecK1AxwYXWUiZUhVjhI3Rs348eTY',
  );


  runApp(
    GetMaterialApp(
      initialRoute: AppRoutes.home,
      getPages: AppRoutes.routes,
    ),
  );
}
