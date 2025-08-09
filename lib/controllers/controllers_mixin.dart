import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'directions/directions.dart';

mixin ControllersMixin<T extends ConsumerStatefulWidget> on ConsumerState<T> {
  //==========================================//

  Directions get directionsNotifier => ref.read(directionsProvider.notifier);

  //==========================================//
}
