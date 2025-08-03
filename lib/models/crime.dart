class Crime {
  final String? id;
  final String crimeType;
  final String location;
  final String description;
  final DateTime? dateTime;
  final String? status;
  final String? reportedBy;
  final List<String>? images; // This will now store Base64 strings
  final String? criminalStatus; // New field

  Crime({
    this.id,
    required this.crimeType,
    required this.location,
    required this.description,
    this.dateTime,
    this.status,
    this.reportedBy,
    this.images,
    this.criminalStatus, // Initialize new field
  });

  factory Crime.fromJson(Map<String, dynamic> json) {
    return Crime(
      id: json['id'],
      crimeType: json['crimeType'],
      location: json['location'],
      description: json['description'],
      dateTime: json['dateTime'] != null ? DateTime.parse(json['dateTime']) : null,
      status: json['status'],
      reportedBy: json['reportedBy'],
      images: json['images'] != null ? List<String>.from(json['images']) : null,
      criminalStatus: json['criminalStatus'], // Parse new field
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id, // Include ID for updates
      'crimeType': crimeType,
      'location': location,
      'description': description,
      'reportedBy': reportedBy ?? 'Anonymous',
      'images': images, // Send Base64 strings directly
      'status': status, // Include status for updates
      'criminalStatus': criminalStatus, // Include new field for updates
    };
  }

  // Helper method to create a copy with updated fields
  Crime copyWith({
    String? id,
    String? crimeType,
    String? location,
    String? description,
    DateTime? dateTime,
    String? status,
    String? reportedBy,
    List<String>? images,
    String? criminalStatus,
  }) {
    return Crime(
      id: id ?? this.id,
      crimeType: crimeType ?? this.crimeType,
      location: location ?? this.location,
      description: description ?? this.description,
      dateTime: dateTime ?? this.dateTime,
      status: status ?? this.status,
      reportedBy: reportedBy ?? this.reportedBy,
      images: images ?? this.images,
      criminalStatus: criminalStatus ?? this.criminalStatus,
    );
  }
}
