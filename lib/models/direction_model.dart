import '../../extensions/extensions.dart';

//////////////////////////////////////////////////////////

class DirectionsModel {
  DirectionsModel({required this.geocodedWaypoints, required this.routes, required this.status});

  factory DirectionsModel.fromJson(Map<String, dynamic> json) {
    return DirectionsModel(
      // ignore: always_specify_types
      geocodedWaypoints: (json['geocoded_waypoints'] as List<dynamic>)
          // ignore: always_specify_types
          .map((e) => GeocodedWaypoint.fromJson(e as Map<String, dynamic>))
          .toList(),
      // ignore: always_specify_types
      routes: (json['routes'] as List).map((e) => Route.fromJson(e as Map<String, dynamic>)).toList(),
      status: json['status'].toString(),
    );
  }

  final List<GeocodedWaypoint> geocodedWaypoints;
  final List<Route> routes;
  final String status;
}

//////////////////////////////////////////////////////////

class GeocodedWaypoint {
  GeocodedWaypoint({
    required this.geocoderStatus,
    required this.partialMatch,
    required this.placeId,
    required this.types,
  });

  factory GeocodedWaypoint.fromJson(Map<String, dynamic> json) {
    return GeocodedWaypoint(
      geocoderStatus: json['geocoder_status'].toString(),
      partialMatch: json['partial_match'] as bool? ?? false, // null対策も追加
      placeId: json['place_id'].toString(),
      // ignore: always_specify_types
      types: (json['types'] as List).map((e) => e.toString()).toList(),
    );
  }

  final String geocoderStatus;
  final bool partialMatch;
  final String placeId;
  final List<String> types;
}

//////////////////////////////////////////////////////////

class Route {
  Route({
    required this.bounds,
    required this.copyrights,
    required this.legs,
    required this.overviewPolyline,
    required this.summary,
    required this.warnings,
    required this.waypointOrder,
  });

  factory Route.fromJson(Map<String, dynamic> json) {
    return Route(
      bounds: Bounds.fromJson(json['bounds'] as Map<String, dynamic>),
      copyrights: json['copyrights'].toString(),
      // ignore: always_specify_types
      legs: (json['legs'] as List).map((e) => Leg.fromJson(e as Map<String, dynamic>)).toList(),
      overviewPolyline: OverviewPolyline.fromJson(json['overview_polyline'] as Map<String, dynamic>),
      summary: json['summary'].toString(),
      // ignore: always_specify_types
      warnings: (json['warnings'] as List).map((e) => e.toString()).toList(),
      waypointOrder: json['waypoint_order'] as List<dynamic>,
    );
  }

  final Bounds bounds;
  final String copyrights;
  final List<Leg> legs;
  final OverviewPolyline overviewPolyline;
  final String summary;
  final List<String> warnings;
  final List<dynamic> waypointOrder;
}

//////////////////////////////////////////////////////////

class Bounds {
  Bounds({required this.northeast, required this.southwest});

  factory Bounds.fromJson(Map<String, dynamic> json) {
    return Bounds(
      northeast: LatLng.fromJson(json['northeast'] as Map<String, dynamic>),
      southwest: LatLng.fromJson(json['southwest'] as Map<String, dynamic>),
    );
  }

  final LatLng northeast;
  final LatLng southwest;
}

//////////////////////////////////////////////////////////

class Leg {
  Leg({
    required this.distance,
    required this.duration,
    required this.endAddress,
    required this.endLocation,
    required this.startAddress,
    required this.startLocation,
    required this.steps,
  });

  factory Leg.fromJson(Map<String, dynamic> json) {
    return Leg(
      distance: Distance.fromJson(json['distance'] as Map<String, dynamic>),
      duration: Duration.fromJson(json['duration'] as Map<String, dynamic>),
      endAddress: json['end_address'].toString(),
      endLocation: LatLng.fromJson(json['end_location'] as Map<String, dynamic>),
      startAddress: json['start_address'].toString(),
      startLocation: LatLng.fromJson(json['start_location'] as Map<String, dynamic>),
      // ignore: always_specify_types
      steps: (json['steps'] as List).map((e) => Step.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }

  final Distance distance;
  final Duration duration;
  final String endAddress;
  final LatLng endLocation;
  final String startAddress;
  final LatLng startLocation;
  final List<Step> steps;
}

//////////////////////////////////////////////////////////

class Step {
  Step({
    required this.distance,
    required this.duration,
    required this.endLocation,
    required this.htmlInstructions,
    required this.polyline,
    required this.startLocation,
    required this.travelMode,
    this.maneuver,
  });

  factory Step.fromJson(Map<String, dynamic> json) {
    return Step(
      distance: Distance.fromJson(json['distance'] as Map<String, dynamic>),
      duration: Duration.fromJson(json['duration'] as Map<String, dynamic>),
      endLocation: LatLng.fromJson(json['end_location'] as Map<String, dynamic>),
      htmlInstructions: json['html_instructions'].toString(),
      polyline: Polyline.fromJson(json['polyline'] as Map<String, dynamic>),
      startLocation: LatLng.fromJson(json['start_location'] as Map<String, dynamic>),
      travelMode: json['travel_mode'].toString(),
      maneuver: json['maneuver'].toString(),
    );
  }

  final Distance distance;
  final Duration duration;
  final LatLng endLocation;
  final String htmlInstructions;
  final Polyline polyline;
  final LatLng startLocation;
  final String travelMode;
  final String? maneuver;
}

//////////////////////////////////////////////////////////

class Distance {
  Distance({required this.text, required this.value});

  factory Distance.fromJson(Map<String, dynamic> json) {
    return Distance(text: json['text'].toString(), value: json['value'].toString().toInt());
  }

  final String text;
  final int value;
}

//////////////////////////////////////////////////////////

class Duration {
  Duration({required this.text, required this.value});

  factory Duration.fromJson(Map<String, dynamic> json) {
    return Duration(text: json['text'].toString(), value: json['value'].toString().toInt());
  }

  final String text;
  final int value;
}

//////////////////////////////////////////////////////////

class LatLng {
  LatLng({required this.lat, required this.lng});

  factory LatLng.fromJson(Map<String, dynamic> json) {
    return LatLng(lat: json['lat'].toString().toDouble(), lng: json['lng'].toString().toDouble());
  }

  final double lat;
  final double lng;
}

//////////////////////////////////////////////////////////

class Polyline {
  Polyline({required this.points});

  factory Polyline.fromJson(Map<String, dynamic> json) {
    return Polyline(points: json['points'].toString());
  }

  final String points;
}

//////////////////////////////////////////////////////////

class OverviewPolyline {
  OverviewPolyline({required this.points});

  factory OverviewPolyline.fromJson(Map<String, dynamic> json) {
    return OverviewPolyline(points: json['points'].toString());
  }

  final String points;
}

//////////////////////////////////////////////////////////
