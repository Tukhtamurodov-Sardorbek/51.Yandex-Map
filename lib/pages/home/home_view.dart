import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';
import 'package:yandexmap/service/permission_service.dart';

GlobalKey mapKey = GlobalKey();

class HomeView extends StatefulWidget {
  HomeView({Key? key}) : super(key: key);

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  late YandexMapController mapController;

  final List<MapObject> markers = [];
  int markerIdCounter = 1;

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
      onTap: (PlacemarkMapObject self, Point point) {
        markers.;
      },
      icon: PlacemarkIcon.single(
        PlacemarkIconStyle(
          scale: 0.2,
          image: BitmapDescriptor.fromAssetImage('assets/icons/pin.png'),
          // rotationType: RotationType.rotate
        ),
      ),
    );

    setState(() {
      markers.add(marker);
      markerIdCounter++;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
          children: [
            YandexMap(
              key: mapKey,
              mapObjects: markers,
              // nightModeEnabled: true,
              logoAlignment: const MapAlignment(
                  horizontal: HorizontalAlignment.right,
                  vertical: VerticalAlignment.bottom,
              ),

              onMapCreated: (YandexMapController yandexMapController) async {
                mapController = yandexMapController;
              },
              onMapTap: (Point point){
                setMarker(point: point);
              },
              onObjectTap: (geoObj){
                print(geoObj);
              },
              onUserLocationAdded: (UserLocationView view) async {
                return view.copyWith(
                    pin: view.pin.copyWith(
                        icon: PlacemarkIcon.single(
                          PlacemarkIconStyle(
                            image: BitmapDescriptor.fromAssetImage(
                              'assets/icons/pin.png',
                            ),
                          ),
                        ),
                    ),
                    arrow: view.arrow.copyWith(
                        icon: PlacemarkIcon.single(
                          PlacemarkIconStyle(
                            image: BitmapDescriptor.fromAssetImage(
                              'assets/icons/arrow.png',
                            ),
                          ),
                        ),
                    ),
                    accuracyCircle: view.accuracyCircle.copyWith(fillColor: Colors.green.withOpacity(0.5)));
                },
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          elevation: 0.0,
          backgroundColor: Colors.transparent,
          child: const Icon(
            Icons.my_location_outlined,
            size: 50,
          ),
          onPressed: () async {
            Point? position = await getUserCurrentPosition(context);
            if (position != null) {
              gotoSearchedPlace(position: position);
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
          },
        ));
  }
}
