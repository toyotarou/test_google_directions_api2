import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controllers/controllers_mixin.dart';
import '../controllers/directions/directions.dart';
import '../models/direction_model.dart';

class DirectionsScreen extends ConsumerStatefulWidget {
  const DirectionsScreen({super.key, required this.origin, required this.destination});

  final String origin;
  final String destination;

  @override
  ConsumerState<DirectionsScreen> createState() => _DirectionsScreenState();
}

class _DirectionsScreenState extends ConsumerState<DirectionsScreen> with ControllersMixin<DirectionsScreen> {
  List<Map<String, Map<String, String>>> stepLocationList = <Map<String, Map<String, String>>>[];

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
  }

  ///
  @override
  Widget build(BuildContext context) {
    ref.watch(directionsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('徒歩ルート')),
      body: Column(
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
    );
  }
}
