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

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'operatingHours': operatingHours,
      'contactInfo': contactInfo,
      'category': category,
      'lat': lat,
      'lng': lng,
    };
  }

  factory Place.fromMap(Map<String, dynamic> map) {
    return Place(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      operatingHours: map['operatingHours'] ?? '',
      contactInfo: map['contactInfo'] ?? '',
      category: map['category'] ?? '',
      lat: (map['lat'] ?? 0.0).toDouble(),
      lng: (map['lng'] ?? 0.0).toDouble(),
    );
  }
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

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'telephone': telephone,
      'office': office,
      'department': department,
      'subjects': subjects,
      'lat': lat,
      'lng': lng,
      'imageUrl': imageUrl,
    };
  }

  factory Lecturer.fromMap(Map<String, dynamic> map) {
    return Lecturer(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      telephone: map['telephone'],
      office: map['office'] ?? '',
      department: map['department'] ?? '',
      subjects: List<String>.from(map['subjects'] ?? []),
      lat: (map['lat'] ?? 0.0).toDouble(),
      lng: (map['lng'] ?? 0.0).toDouble(),
      imageUrl: map['imageUrl'] ?? '',
    );
  }
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

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'routeName': routeName,
      'stops': stops,
      'scheduleTimes': scheduleTimes,
    };
  }

  factory BusRoute.fromMap(Map<String, dynamic> map) {
    return BusRoute(
      id: map['id'] ?? '',
      routeName: map['routeName'] ?? '',
      stops: List<String>.from(map['stops'] ?? []),
      scheduleTimes: List<String>.from(map['scheduleTimes'] ?? []),
    );
  }
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

  Map<String, dynamic> toMap() {
    return {
      'time': time,
      'route1': route1,
      'route2': route2,
    };
  }

  factory BusScheduleEntry.fromMap(Map<String, dynamic> map) {
    return BusScheduleEntry(
      time: map['time'] ?? '',
      route1: map['route1'] ?? '',
      route2: map['route2'] ?? '',
    );
  }
}
