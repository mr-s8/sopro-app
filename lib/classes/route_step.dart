class RouteStep {
  final String id;
  String routeImage;
  String type; // Das Feld heißt im JSON "type", nicht "path"
  String description;

  RouteStep({
    required this.id,
    required this.routeImage,
    required this.type,
    required this.description,
  });

  // Statische fromJson Methode
  static RouteStep fromJson(Map<String, dynamic> json) {
    return RouteStep(
      id: json['id'],
      routeImage: json['routeImage'],
      type: json['type'],
      description: json['description'],
    );
  }

  // Statische toJson Methode
  static Map<String, dynamic> toJson(RouteStep step) {
    return {
      'id': step.id,
      'routeImage': step.routeImage,
      'type': step.type,
      'description': step.description,
    };
  }
}
