import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yandexmap/pages/home/home_view.dart';

import 'package:permission_handler/permission_handler.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';


Future<void> main() async{
  WidgetsFlutterBinding.ensureInitialized();

  // * Orientation
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(
    ProviderScope(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Yandex Map',
        theme: ThemeData(
          primarySwatch: Colors.amber,
          brightness: Brightness.dark,
        ),
        home: HomeView(),
      ),
    ),
  );
}
