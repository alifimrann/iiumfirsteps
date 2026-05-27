class Place {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final String operatingHours;
  final String contactInfo;
  final String category;
  final double lat;
  final double lng;

  Place({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.operatingHours,
    required this.contactInfo,
    required this.category,
    required this.lat,
    required this.lng,
  });
}

class Lecturer {
  final String id;
  final String name;
  final String email;
  final String? telephone;
  final String office;
  final String department;
  final List<String> subjects;
  final double lat;
  final double lng;
  final String imageUrl;

  Lecturer({
    required this.id,
    required this.name,
    required this.email,
    this.telephone,
    required this.office,
    required this.department,
    required this.subjects,
    required this.lat,
    required this.lng,
    required this.imageUrl,
  });
}

class BusRoute {
  final String id;
  final String routeName;
  final List<String> stops;
  final List<String> scheduleTimes;

  BusRoute({
    required this.id,
    required this.routeName,
    required this.stops,
    required this.scheduleTimes,
  });
}

class BusScheduleEntry {
  final String time;
  final String route1;
  final String route2;

  BusScheduleEntry({
    required this.time,
    required this.route1,
    required this.route2,
  });
}
