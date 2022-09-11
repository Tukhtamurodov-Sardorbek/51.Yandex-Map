import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

final homeChangeNotifier = ChangeNotifierProvider<HomeChangeNotifier>((ref) => HomeChangeNotifier(),);

class HomeChangeNotifier extends ChangeNotifier {
  /// fields
  late YandexMapController _mapController;
  final List<MapObject> _markers = [];
  int _markerIdCounter = 1;

  /// getters & setters
  YandexMapController get mapController => _mapController;
  List<MapObject> get markers => _markers;
  int get markerIdCounter => _markerIdCounter;

  set mapController(YandexMapController ctr){
    _mapController = ctr;
    notifyListeners();
  }
  set markerIdCounter(int value){
    if(_markerIdCounter != value){
      _markerIdCounter = value;
      notifyListeners();
    }
  }

  /// methods
  Future<Position> getGeoLocationPosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      return Future.error('Location services are disabled.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }
    else if (permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.deniedForever) {
        return Future.error('Location permissions are permanently denied, we cannot request permissions.');
      }
    }

    final locator =  await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.best,
    );
    return locator;
  }

  getUserCurrentPosition(BuildContext context) async {
    try {
      final position = await getGeoLocationPosition();
      debugPrint('\n\t User\'s location: (${position.latitude}, ${position.longitude})');
      return Point(latitude: position.latitude, longitude: position.longitude);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          elevation: 10,
          shape: const StadiumBorder(),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(milliseconds: 2500),
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          content: Text(
            e.toString(),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
  }

  Future<void> gotoSearchedPlace({required Point position, double zoom = 18.0, bool putMarker = true}) async {
    mapController.moveCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: position,
          zoom: zoom,
        ),
      ),
    );
    if (putMarker) {
      setMarker(point: position);
    }
  }

  void setMarker({required Point point}) async {
    final marker = PlacemarkMapObject(
      mapId: MapObjectId('marker_$markerIdCounter'),
      point: point,
      opacity: 0.7,
      onTap: (PlacemarkMapObject self, Point point) {},
      icon: PlacemarkIcon.single(
        PlacemarkIconStyle(
          scale: 0.2,
          image: BitmapDescriptor.fromAssetImage('assets/icons/pin.png'),
          // rotationType: RotationType.rotate
        ),
      ),
    );

    markers.add(marker);
    markerIdCounter++;
    notifyListeners();
  }
}