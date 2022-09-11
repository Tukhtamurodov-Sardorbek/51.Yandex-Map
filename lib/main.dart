import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yandexmap/pages/home/view.dart';

Future<void> main() async{
  WidgetsFlutterBinding.ensureInitialized();

  // * Orientation
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(
    const ProviderScope(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Yandex Map',
        home: HomeView(),
      ),
    ),
  );
}
