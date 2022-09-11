import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

final homeChangeNotifier = ChangeNotifierProvider<HomeChangeNotifier>((ref) => HomeChangeNotifier(),);

class HomeChangeNotifier extends ChangeNotifier {
  /// fields
  late YandexMapController _mapController;
  final List<MapObject> _mapObjects = [];
  final List<Point> _markersPoints = [];
  int _markerIdCounter = 1;
  bool _isMarkerEnabled = false;
  bool _isPolylineEnabled = false;

  /// getters & setters
  YandexMapController get mapController => _mapController;
  List<MapObject> get mapObjects => _mapObjects;
  int get markerIdCounter => _markerIdCounter;
  bool get isMarkerEnabled => _isMarkerEnabled;
  bool get isPolylineEnabled => _isPolylineEnabled;

  set mapController(YandexMapController ctr) {
    _mapController = ctr;
    notifyListeners();
  }
  set isMarkerEnabled(bool value) {
    _isMarkerEnabled = value;
    notifyListeners();
  }
  set isPolylineEnabled(bool value) {
    _isPolylineEnabled = value;
    notifyListeners();
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
    } else if (permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.deniedForever) {
        return Future.error(
            'Location permissions are permanently denied, we cannot request permissions.');
      }
    }

    final locator = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.best,
    );
    return locator;
  }

  Future<Point?> getUserPosition(BuildContext context) async {
    try {
      final position = await getGeoLocationPosition();
      debugPrint(
          '\n\t User\'s location: (${position.latitude}, ${position.longitude})');
      return Point(latitude: position.latitude, longitude: position.longitude);
    } catch (e) {
     showSnackBar(context, e.toString());
    }
    return null;
  }

  void showSnackBar(BuildContext context, String txt){
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        elevation: 10,
        shape: const StadiumBorder(),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(milliseconds: 2500),
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        content: Text(
          txt,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Future<void> gotoPlace({required Point position, double zoom = 18.0, bool putMarker = true}) async {
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
      onTap: (PlacemarkMapObject self, Point point) {
        _mapObjects.removeWhere((obj) => obj.mapId == self.mapId);
        _markersPoints.removeWhere((element) => element == self.point);
        notifyListeners();
      },
      icon: PlacemarkIcon.single(
        PlacemarkIconStyle(
          scale: 0.1,
          image: BitmapDescriptor.fromAssetImage('assets/icons/pin.png'),
          // rotationType: RotationType.rotate
        ),
      ),
    );

    _mapObjects.insert(0, marker);
    _markersPoints.add(marker.point);
    _markerIdCounter++;
    notifyListeners();
  }

  Future<void> onLocationPressed(BuildContext context) async {
    Point? position = await getUserPosition(context);
    if (position != null) {
      gotoPlace(position: position);
    }

    // if(await Permission.location.request().isGranted){
    //   final mediaQuery = MediaQuery.of(context);
    //   final height = mapKey.currentContext!.size!.height * mediaQuery.devicePixelRatio;
    //   final width = mapKey.currentContext!.size!.width * mediaQuery.devicePixelRatio;
    //
    //   await mapController.toggleUserLayer(
    //       visible: true,
    //       autoZoomEnabled: true,
    //       anchor: UserLocationAnchor(
    //           course: Offset(0.5 * height, 0.5 * width),
    //           normal: Offset(0.5 * height, 0.5 * width)
    //       )
    //   );
    // }
  }

  // {required Point point1, required Point point2}
  Future<void> drawPolyline(BuildContext context) async{
    if(_markersPoints.length >= 2){
      print('Markers(${_markersPoints.length}: $_markersPoints');
      final between = _markersPoints.getRange(1, _markersPoints.length - 1);
      // final polyline = PolylineMapObject(
      //   mapId: MapObjectId('polyline_$polylineIdCounter'),
      //   // polyline: Polyline(points: [point1, point2]),
      //   polyline: Polyline(points: _markersPoints),
      //   strokeColor: Colors.amberAccent,
      //   strokeWidth: 7.5,
      //   outlineColor: Colors.orange,
      //   outlineWidth: 2.0,
      //   turnRadius: 10.0,
      //   arcApproximationStep: 1.0,
      //   gradientLength: 1.0,
      //   isInnerOutlineEnabled: true,
      //   onTap: (PolylineMapObject self, Point point){
      //     _mapObjects.removeWhere((obj) => obj.mapId == self.mapId);
      //     notifyListeners();
      //   },
      // );

      var sessionResult = YandexDriving.requestRoutes(
          points: [
            RequestPoint(point: _markersPoints.first, requestPointType: RequestPointType.wayPoint),
            ...between.map((e) => RequestPoint(point: e, requestPointType: RequestPointType.viaPoint)).toList(),
            RequestPoint(point: _markersPoints.last, requestPointType: RequestPointType.wayPoint),
          ],
          drivingOptions: const DrivingOptions(
              initialAzimuth: 0,
              routesCount: 5,
              avoidTolls: true,
          )
      );

      final result = await sessionResult.result;

      result.routes!.asMap().forEach(
            (i, route) {
              final time = DateTime.now();
                _mapObjects.add(
                  PolylineMapObject(
                    mapId: MapObjectId('polyline $time'),
                    polyline: Polyline(points: route.geometry),
                    strokeColor: Colors.primaries[Random().nextInt(Colors.primaries.length)],
                    strokeWidth: 3,
                  ),
                );
            },
      );
      notifyListeners();
    }else{
      showSnackBar(context, 'There should be at least two points to draw a polyline');
    }
  }
}
