import 'package:flutter/material.dart';

import 'components/directions_map_alert.dart';
import 'parts/directions_dialog.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                directionsDialog(
                  context: context,
                  widget: const DirectionsMapAlert(origin: '東京都大田区北嶺町37-20', destination: '東京都大田区田園調布1-55-12'),
                );
              },
              child: const Text('aaa'),
            ),
          ],
        ),
      ),
    );
  }
}

/*



    I/flutter ( 5903): 大田区北嶺町　御嶽神社【嶺の御嶽さん】
I/flutter ( 5903): 東京都大田区北嶺町37-20
I/flutter ( 5903): 浅間神社【多摩川浅間神社】
I/flutter ( 5903): 東京都大田区田園調布1-55-12



    */
