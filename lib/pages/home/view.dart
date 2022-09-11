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
            mapObjects: watch.markers,
            // nightModeEnabled: true,
            logoAlignment: const MapAlignment(
              horizontal: HorizontalAlignment.right,
              vertical: VerticalAlignment.bottom,
            ),

            onMapCreated: (YandexMapController yandexMapController) async {
              read.mapController = yandexMapController;
            },
            onMapTap: (Point point) {
              read.setMarker(point: point);
            },

            onUserLocationAdded: (UserLocationView view) async {
              return view.copyWith(
                  pin: view.pin.copyWith(
                    icon: PlacemarkIcon.single(
                      PlacemarkIconStyle(
                        scale: 0.2,
                        image: BitmapDescriptor.fromAssetImage('assets/icons/pin.png',),
                      ),
                    ),
                  ),
                  arrow: view.arrow.copyWith(
                    icon: PlacemarkIcon.single(
                      PlacemarkIconStyle(
                        scale: 0.5,
                        image: BitmapDescriptor.fromAssetImage('assets/icons/arrow.png',),
                      ),
                    ),
                  ),
                  accuracyCircle: view.accuracyCircle.copyWith(
                    strokeColor: const Color(0xff0960fe),
                    fillColor: const Color(0xff9f0ace).withOpacity(0.4), //Colors.amberAccent.withOpacity(0.5),
                  ));
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
          read.onFloatingActionButtonPressed(context);
        },
      ),
    );
  }
}
