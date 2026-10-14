class StoreSchema {
  final String name;
  final String address;
  final String distance;
  final bool openNow;
  final bool closingSoon;
  final bool hasParking;
  final String parkingDetails;
  final String mapUrl;

  const StoreSchema({
    this.name = '',
    this.address = '',
    this.distance = '',
    this.openNow = false,
    this.closingSoon = false,
    this.hasParking = false,
    this.parkingDetails = '',
    this.mapUrl = '',
  });

  factory StoreSchema.fromJson(Map<String, dynamic> json) {
    return StoreSchema(
      name: json['name'] as String? ?? '',
      address: json['address'] as String? ?? '',
      distance: json['distance'] as String? ?? '',
      openNow: json['openNow'] as bool? ?? false,
      closingSoon: json['closingSoon'] as bool? ?? false,
      hasParking: json['hasParking'] as bool? ?? false,
      parkingDetails: json['parkingDetails'] as String? ?? '',
      mapUrl: json['mapUrl'] as String? ?? '',
    );
  }
}

class StoreFinderResult {
  final List<StoreSchema> stores;

  const StoreFinderResult({this.stores = const []});

  factory StoreFinderResult.fromJson(Map<String, dynamic> json) {
    return StoreFinderResult(
      stores: (json['stores'] as List<dynamic>?)
              ?.whereType<Map<String, dynamic>>()
              .map(StoreSchema.fromJson)
              .toList() ??
          const [],
    );
  }
}
