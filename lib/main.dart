import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone/Providers/user_provider.dart';
import 'package:instagram_clone/responsive/mobile_screen_layout.dart';
import 'package:instagram_clone/responsive/responsive_layout_screen.dart';
import 'package:instagram_clone/responsive/web_screen_layout.dart';
import 'package:instagram_clone/screens/add_post.dart';
import 'package:instagram_clone/screens/login_screen.dart';
import 'package:instagram_clone/utility/colors.dart';
import 'package:provider/provider.dart';

void main() async {
  // Provider.debugCheckInvalidValueType = null;
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
          apiKey: "AIzaSyC-kFdar0wrk8Dm1C8CJF6_u0W9jdk2DAU",
          appId: "1:427354926130:web:29208c058c3e505214202b",
          messagingSenderId: "427354926130",
          projectId: "instagram-clone-f4496",
          storageBucket: "instagram-clone-f4496.appspot.com"),
    );
  } else {
    await Firebase.initializeApp();
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      // This is used to add all the providers at a single place.
      providers: [
        ChangeNotifierProvider(
          create: (_) => UserProvider(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Instagram Clone',
        theme: ThemeData.dark().copyWith(
          scaffoldBackgroundColor: mobileBackgroundColor,
        ),
        home: StreamBuilder(
          // ****** For persisting the user state ******
          stream: FirebaseAuth.instance.authStateChanges(),
          // This runs only when the user has signed in or signed out
          // There are two other types as well 1) idChanges(), 2) userChanges()
          builder: (context, snapShot) {
            if (snapShot.connectionState == ConnectionState.active) {
              if (snapShot.hasData) {
                // return the responsive layout here
                return const ResponsiveLayout(
                  webScreenLayout: WebScreenLayout(),
                  mobileScreenLayout: MobileScreenLayout(),
                );
              }
            } else if (snapShot.hasError) {
              return Center(
                child: Text('${snapShot.error}'),
              );
            }
            if (snapShot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator(
                color: primaryColor,
              );
            }

            return const LoginScreen();
          },
        ),
      ),
    );
  }
}
