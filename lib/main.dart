import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'services/auth_service.dart';
import 'services/api_service.dart';
import 'screens/login_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/home_screen.dart';
import 'providers/auth_provider.dart';
import 'providers/product_provider.dart';
import 'providers/menu_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  
  await dotenv.load(fileName: ".env");
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProxyProvider<AuthProvider, ProductProvider>(
          create: (_) => ProductProvider(null, []),
          update: (_, authProvider, previous) => 
            ProductProvider(authProvider.token, previous?.products ?? []),
        ),
        ChangeNotifierProxyProvider<ProductProvider, MenuProvider>(
          create: (_) => MenuProvider([]),
          update: (_, productProvider, previous) => 
            MenuProvider(productProvider.products),
        ),
      ],
      child: Consumer<AuthProvider>(
        builder: (ctx, auth, _) => MaterialApp(
          title: 'Menú App',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            primarySwatch: Colors.teal,
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.teal,
              primary: Colors.teal,
              secondary: Colors.amber,
            ),
            fontFamily: 'Poppins',
            useMaterial3: true,
          ),
          home: auth.isLoading 
            ? const SplashScreen() 
            : auth.isAuth 
              ? const HomeScreen() 
              : const LoginScreen(),
        ),
      ),
    );
  }
}
