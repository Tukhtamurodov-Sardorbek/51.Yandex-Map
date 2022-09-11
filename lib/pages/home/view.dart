import 'package:flutter/material.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';
import 'package:yandexmap/pages/home/viewModel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

GlobalKey mapKey = GlobalKey();

class HomeView extends ConsumerWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final watch = ref.watch(homeChangeNotifier);
    final read = ref.read(homeChangeNotifier);
    return Scaffold(
        body: Stack(
          children: [
            YandexMap(
              key: mapKey,
              mapObjects: read.markers,
              // nightModeEnabled: true,
              logoAlignment: const MapAlignment(
                horizontal: HorizontalAlignment.right,
                vertical: VerticalAlignment.bottom,
              ),

              onMapCreated: (YandexMapController yandexMapController) async {
                watch.mapController = yandexMapController;
              },
              onMapTap: (Point point){
                read.setMarker(point: point);
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
            Point? position = await read.getUserCurrentPosition(context);
            if (position != null) {
              read.gotoSearchedPlace(position: position);
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
        ),
    );
  }
}

