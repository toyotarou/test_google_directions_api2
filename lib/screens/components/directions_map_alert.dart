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

  // List<Marker> markerList = <Marker>[];
  //
  // final List<OverlayEntry> _firstEntries = <OverlayEntry>[];
  // final List<OverlayEntry> _secondEntries = <OverlayEntry>[];
  //
  // List<LatLng> latLngList = <LatLng>[];
  //
  // List<LatLng> polygonPoints = <LatLng>[];
  //
  // double centerLat = 0.0;
  // double centerLng = 0.0;

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
                // initialCenter: (monthlyGeolocList.isNotEmpty)
                //     ? LatLng(monthlyGeolocList[0].latitude.toDouble(), monthlyGeolocList[0].longitude.toDouble())
                //     : const LatLng(35.718532, 139.586639),
                //
                //
                //
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

                // MarkerLayer(markers: markerList),
                //
                // if (polygonPoints.isNotEmpty) ...<Widget>[
                //   // ignore: always_specify_types
                //   PolygonLayer(
                //     polygons: <Polygon<Object>>[
                //       // ignore: always_specify_types
                //       Polygon(
                //         points: polygonPoints,
                //         color: Colors.purpleAccent.withValues(alpha: 0.2),
                //         borderColor: Colors.purpleAccent.withValues(alpha: 0.4),
                //         borderStrokeWidth: 2,
                //       ),
                //     ],
                //   ),
                // ],
                //
                //
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
    // selectedGeolocList.clear();
    //
    //
    //

    latList.clear();
    lngList.clear();
    //
    // latLngList.clear();
    //
    //
    //

    // if (appParamState.monthlyGeolocMapSelectedDateList.isNotEmpty) {
    //   for (final String element in appParamState.monthlyGeolocMapSelectedDateList) {
    //     appParamState.keepGeolocMap[element]?.forEach((GeolocModel element2) {
    //       selectedGeolocList.add(element2);
    //
    //       latList.add(element2.latitude.toDouble());
    //       lngList.add(element2.longitude.toDouble());
    //
    //       latLngList.add(LatLng(element2.latitude.toDouble(), element2.longitude.toDouble()));
    //     });
    //   }
    // }

    for (final Map<String, Map<String, String>> element in stepLocationList) {
      element.forEach((String key, Map<String, String> value) {
        latList.add((value['latitude'] != null) ? value['latitude'].toString().toDouble() : 0);
        lngList.add((value['longitude'] != null) ? value['longitude'].toString().toDouble() : 0);
      });
    }

    latList = latList.toSet().toList();
    lngList = lngList.toSet().toList();

    /*





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
                          */

    if (latList.isNotEmpty && lngList.isNotEmpty) {
      // polygonPoints = utility.getBoundingBoxPoints(selectedGeolocList);
      //
      // centerLat = (polygonPoints[0].latitude + polygonPoints[2].latitude) / 2;
      // centerLng = (polygonPoints[0].longitude + polygonPoints[2].longitude) / 2;
      //
      //
      //
      //

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
}
