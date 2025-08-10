import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../../controllers/controllers_mixin.dart';
import '../../controllers/directions/directions.dart';
import '../../extensions/extensions.dart';
import '../../models/direction_model.dart';
import '../../utility/tile_provider.dart';
import '../../utility/utility.dart';

class DirectionsMapAlert extends ConsumerStatefulWidget {
  const DirectionsMapAlert({super.key, required this.origin, required this.destination});

  final String origin;
  final String destination;

  @override
  ConsumerState<DirectionsMapAlert> createState() => _DirectionsMapAlertState();
}

class _DirectionsMapAlertState extends ConsumerState<DirectionsMapAlert> with ControllersMixin<DirectionsMapAlert> {
  List<Map<String, Map<String, String>>> stepLocationList = <Map<String, Map<String, String>>>[];

  final MapController mapController = MapController();

  double currentZoomEightTeen = 18;

  List<double> latList = <double>[];
  List<double> lngList = <double>[];

  double minLat = 0.0;
  double maxLat = 0.0;
  double minLng = 0.0;
  double maxLng = 0.0;

  bool isLoading = false;

  double? currentZoom;

  Utility utility = Utility();

  List<LatLng> latLngList = <LatLng>[];

  ///
  @override
  void initState() {
    super.initState();

    // ignore: always_specify_types
    Future(() async {
      await directionsNotifier.fetch(
        origin: widget.origin,
        destination: widget.destination,
        apiKey: dotenv.env['GOOGLE_API_KEY']!,
      );

      final DirectionsModel? state = ref.read(directionsProvider);

      if (state != null) {
        final List<Map<String, Map<String, String>>> list = <Map<String, Map<String, String>>>[];

        // ignore: always_specify_types
        final steps = state.routes.expand((r) => r.legs).expand((l) => l.steps);

        // ignore: always_specify_types
        for (final step in steps) {
          list.add(<String, Map<String, String>>{
            'start': <String, String>{
              'latitude': step.startLocation.lat.toString(),
              'longitude': step.startLocation.lng.toString(),
            },
            'end': <String, String>{
              'latitude': step.endLocation.lat.toString(),
              'longitude': step.endLocation.lng.toString(),
            },
          });
        }

        setState(() => stepLocationList = list);
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() => isLoading = true);

      // ignore: always_specify_types
      Future.delayed(const Duration(seconds: 2), () {
        setDefaultBoundsMap();

        setState(() => isLoading = false);
      });
    });
  }

  ///
  @override
  Widget build(BuildContext context) {
    ref.watch(directionsProvider);

    makeMinMaxLatLng();

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            FlutterMap(
              mapController: mapController,
              options: MapOptions(
                initialCenter: const LatLng(35.718532, 139.586639),

                initialZoom: currentZoomEightTeen,

                onPositionChanged: (MapCamera position, bool isMoving) {
                  if (isMoving) {
                    appParamNotifier.setCurrentZoom(zoom: position.zoom);
                  }
                },
              ),
              children: <Widget>[
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  tileProvider: CachedTileProvider(),
                  userAgentPackageName: 'com.example.app',
                ),

                if (stepLocationList.isNotEmpty) ...<Widget>[
                  // ignore: always_specify_types
                  PolylineLayer(polylines: makeTransportationPolyline()),
                ],
              ],
            ),

            Column(
              children: <Widget>[
                Expanded(
                  child: stepLocationList.isEmpty
                      ? const Center(child: Text('データ未取得'))
                      : ListView.builder(
                          itemCount: stepLocationList.length,
                          itemBuilder: (BuildContext context, int index) {
                            final Map<String, Map<String, String>> item = stepLocationList[index];
                            final Map<String, String> start = item['start']!;
                            final Map<String, String> end = item['end']!;

                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    '${index + 1}    start    lat: ${start['latitude']}, lng: ${start['longitude']}',
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                  Text(
                                    '     end      lat: ${end['latitude']}, lng: ${end['longitude']}',
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                  const Divider(),
                                ],
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),

            if (isLoading) ...<Widget>[const Center(child: CircularProgressIndicator())],
          ],
        ),
      ),
    );
  }

  ///
  void makeMinMaxLatLng() {
    latList.clear();
    lngList.clear();

    latLngList.clear();

    for (final Map<String, Map<String, String>> element in stepLocationList) {
      element.forEach((String key, Map<String, String> value) {
        latList.add((value['latitude'] != null) ? value['latitude'].toString().toDouble() : 0);
        lngList.add((value['longitude'] != null) ? value['longitude'].toString().toDouble() : 0);

        latLngList.add(LatLng(value['latitude'].toString().toDouble(), value['longitude'].toString().toDouble()));
      });
    }

    latList = latList.toSet().toList();
    lngList = lngList.toSet().toList();

    if (latList.isNotEmpty && lngList.isNotEmpty) {
      minLat = latList.reduce(min);
      maxLat = latList.reduce(max);
      minLng = lngList.reduce(min);
      maxLng = lngList.reduce(max);
    }
  }

  ///
  void setDefaultBoundsMap() {
    if (stepLocationList.isNotEmpty) {
      mapController.rotate(0);

      final LatLngBounds bounds = LatLngBounds.fromPoints(<LatLng>[LatLng(minLat, maxLng), LatLng(maxLat, minLng)]);

      final CameraFit cameraFit = CameraFit.bounds(
        bounds: bounds,
        padding: EdgeInsets.all(appParamState.currentPaddingIndex * 10),
      );

      mapController.fitCamera(cameraFit);

      /// これは残しておく
      // final LatLng newCenter = mapController.camera.center;

      final double newZoom = mapController.camera.zoom;

      setState(() => currentZoom = newZoom);

      appParamNotifier.setCurrentZoom(zoom: newZoom);
    }
  }

  ///
  // ignore: always_specify_types
  List<Polyline> makeTransportationPolyline() {
    final List<Color> twelveColor = utility.getTwelveColor();

    // ignore: always_specify_types
    return <Polyline<Object>>[Polyline(points: latLngList, color: twelveColor[0], strokeWidth: 5)];
  }
}
