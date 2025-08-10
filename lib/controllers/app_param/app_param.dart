import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../utility/utility.dart';

part 'app_param.freezed.dart';

part 'app_param.g.dart';

@freezed
class AppParamState with _$AppParamState {
  const factory AppParamState({
    ///
    List<OverlayEntry>? firstEntries,
    List<OverlayEntry>? secondEntries,

    Offset? overlayPosition,

    ///
    @Default(0) double currentZoom,
    @Default(5) int currentPaddingIndex,

    ///
    @Default('') String selectedYearMonth,
    @Default(<String>[]) List<String> monthlyGeolocMapSelectedDateList,

    @Default(0) int selectedGraphYear,
  }) = _AppParamState;
}

@riverpod
class AppParam extends _$AppParam {
  final Utility utility = Utility();

  ///
  @override
  AppParamState build() => const AppParamState();

  ///
  void setCurrentZoom({required double zoom}) => state = state.copyWith(currentZoom: zoom);
}
