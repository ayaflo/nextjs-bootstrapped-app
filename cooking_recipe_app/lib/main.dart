import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cooking_recipe_app/providers/auth_provider.dart';
import 'package:cooking_recipe_app/screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: MaterialApp(
        title: 'Spoonie - Recipe Sharing App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          fontFamily: 'Poppins',
          scaffoldBackgroundColor: Colors.white,
        ),
        home: const SplashScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
