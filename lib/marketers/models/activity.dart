class Activity {
  final String id;
  final String actorId;
  final String actorName;
  final String role;
  final String action;
  final String resource;
  final String resourceId;
  final Map<String, dynamic> details;
  final List<dynamic> allowedAccess;
  final String ip;
  final String userAgent;
  final DateTime createdAt;

  Activity({
    required this.id,
    required this.actorId,
    required this.actorName,
    required this.role,
    required this.action,
    required this.resource,
    required this.resourceId,
    required this.details,
    required this.allowedAccess,
    required this.ip,
    required this.userAgent,
    required this.createdAt,
  });

  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(
      id: json['id'] ?? json['_id'] ?? '',
      actorId: json['actor']?['id'] ?? json['actorId'] ?? '',
      actorName: json['actor']?['name'] ?? json['actorName'] ?? '',
      role: json['actor']?['role'] ?? json['role'] ?? '',
      action: json['action'] ?? '',
      resource: json['resource'] ?? '',
      resourceId: json['resourceId'] ?? '',
      details: Map<String, dynamic>.from(json['details'] ?? {}),
      allowedAccess: List<dynamic>.from(json['allowedAccess'] ?? []),
      ip: json['ip'] ?? '',
      userAgent: json['userAgent'] ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    );
  }
}
