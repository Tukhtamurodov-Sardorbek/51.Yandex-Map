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
      body: YandexMap(
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
          read.setMarker(point: point);
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

      floatingActionButton: Container(
        margin: const EdgeInsets.only(left: 30),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              onPressed: () async {
                read.onFloatingActionButtonPressed(context);
              },
              icon: const Icon(
                Icons.my_location_outlined,
                size: 50,
              ),
            ),
            IconButton(
              onPressed: () async {
                read.drawPolyline(context);
              },
              icon: const Icon(
                Icons.polyline,
                color: Colors.black,
                size: 50,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
