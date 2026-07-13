import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'pages/splash.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://tskylacvlqgruthpcfqw.supabase.co',
    anonKey: 'sb_publishable_swSgKgNAZirqkyc_YJTnWA_KUcNUN-R',
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'GoBite',
      theme: ThemeData(fontFamily: 'Plus Jakarta Sans'),
      home: SplashPage(),
    );
  }
}
