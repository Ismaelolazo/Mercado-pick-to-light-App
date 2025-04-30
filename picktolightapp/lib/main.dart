import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'screens/home_screen.dart';

late List<CameraDescription> cameras;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final Color azulPrincipal = Color(0xFF1976D2);
    final Color naranjaSecundario = Color(0xFFFFA000);

    return MaterialApp(
      title: 'Pick-to-Light Market',
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        primaryColor: azulPrincipal,
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.blue,
        ).copyWith(
          secondary: naranjaSecundario,
        ),
        checkboxTheme: CheckboxThemeData(
          fillColor: MaterialStateProperty.all(naranjaSecundario),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: azulPrincipal,
            foregroundColor: Colors.white,
            textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: azulPrincipal,
          foregroundColor: Colors.white,
          centerTitle: true,
          elevation: 4,
        ),
      ),
      home: HomeScreen(cameras: cameras),
    );
  }
}
