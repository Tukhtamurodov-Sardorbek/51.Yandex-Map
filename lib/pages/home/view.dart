import 'package:flutter/cupertino.dart';
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
            mapObjects: watch.mapObjects,
            // nightModeEnabled: true,
            logoAlignment: const MapAlignment(
              horizontal: HorizontalAlignment.right,
              vertical: VerticalAlignment.bottom,
            ),

            onMapCreated: (YandexMapController yandexMapController) async {
              read.mapController = yandexMapController;
            },
            onMapTap: (Point point) {
              read.isMarkerEnabled
                  ? read.setMarker(point: point)
                  : null;
            },

            onUserLocationAdded: (UserLocationView view) async {
              return view.copyWith(
                  pin: view.pin.copyWith(
                    icon: PlacemarkIcon.single(
                      PlacemarkIconStyle(
                        scale: 0.2,
                        image: BitmapDescriptor.fromAssetImage(
                          'assets/icons/pin.png',
                        ),
                      ),
                    ),
                  ),
                  arrow: view.arrow.copyWith(
                    icon: PlacemarkIcon.single(
                      PlacemarkIconStyle(
                        scale: 0.5,
                        image: BitmapDescriptor.fromAssetImage(
                          'assets/icons/arrow.png',
                        ),
                      ),
                    ),
                  ),
                  accuracyCircle: view.accuracyCircle.copyWith(
                    strokeColor: Colors.orange,
                    fillColor: Colors.amberAccent.withOpacity(0.5),
                  ));
            },
          ),
          Positioned(
            right: 10.0,
            bottom: 30.0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: () async {
                    read.isMarkerEnabled = !read.isMarkerEnabled;
                  },
                  icon: Icon(
                    read.isMarkerEnabled ? Icons.location_off_outlined : Icons.location_on_outlined,
                    color: Colors.black,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 20),
                IconButton(
                  onPressed: () async {
                    read.onFloatingActionButtonPressed(context);
                  },
                  icon: const Icon(
                    Icons.my_location_outlined,
                    color: Colors.black,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 20),
                IconButton(
                  onPressed: () async {
                    read.drawPolyline(context);
                  },
                  icon: const Icon(
                    Icons.polyline,
                    color: Colors.black,
                    size: 40,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
