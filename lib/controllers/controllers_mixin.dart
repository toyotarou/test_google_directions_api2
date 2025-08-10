import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app_param/app_param.dart';
import 'directions/directions.dart';

mixin ControllersMixin<T extends ConsumerStatefulWidget> on ConsumerState<T> {
  //==========================================//

  AppParamState get appParamState => ref.watch(appParamProvider);

  AppParam get appParamNotifier => ref.read(appParamProvider.notifier);

  //==========================================//

  Directions get directionsNotifier => ref.read(directionsProvider.notifier);

  //==========================================//
}
