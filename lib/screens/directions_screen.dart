import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controllers/directions/directions.dart';

class DirectionsScreen extends ConsumerStatefulWidget {
  const DirectionsScreen({super.key});

  @override
  ConsumerState<DirectionsScreen> createState() => _DirectionsScreenState();
}

class _DirectionsScreenState extends ConsumerState<DirectionsScreen> {
  List<Map<String, Map<String, String>>> stepLocationList = [];

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(directionsProvider);
    final notifier = ref.read(directionsProvider.notifier);

    const origin = '吉祥寺駅';
    const destination = '上石神井駅';
    const apiKey = "AIzaSyDepeW7Aff-rAasSMRlPVR_KZOlcUYqoLw";

    return Scaffold(
      appBar: AppBar(title: const Text('徒歩ルート')),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: () async {
              await notifier.fetch(origin: origin, destination: destination, apiKey: apiKey);

              final state = ref.read(directionsProvider); // 最新状態を取得
              if (state != null) {
                final List<Map<String, Map<String, String>>> list = [];

                final steps = state.routes.expand((r) => r.legs).expand((l) => l.steps);

                for (final step in steps) {
                  list.add({
                    'start': {
                      'latitude': step.startLocation.lat.toString(),
                      'longitude': step.startLocation.lng.toString(),
                    },
                    'end': {'latitude': step.endLocation.lat.toString(), 'longitude': step.endLocation.lng.toString()},
                  });
                }

                setState(() {
                  stepLocationList = list;
                });
              }
            },
            child: const Text('ルート取得'),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: stepLocationList.isEmpty
                ? const Center(child: Text('データ未取得'))
                : ListView.builder(
                    itemCount: stepLocationList.length,
                    itemBuilder: (context, index) {
                      final item = stepLocationList[index];
                      final start = item['start']!;
                      final end = item['end']!;

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
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
