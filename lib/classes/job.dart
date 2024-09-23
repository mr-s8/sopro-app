import 'package:flutter/material.dart';
import 'package:taskscout/classes/route_step.dart';

class Job {
  final String id;
  String name;
  String status;
  String buildingId;
  String buildingAddress;
  String buildingImage;
  List<RouteStep> route;

  // user spezifische daten (nicht required)
  int progress;
  Map<String, String> comments;
  String userStatus;
  bool downloaded;

  Job({
    required this.id,
    required this.name,
    required this.status,
    required this.buildingId,
    required this.buildingAddress,
    required this.buildingImage,
    required this.route,
    this.progress = 0,
    this.comments = const {},
    this.userStatus = 'unstarted',
    this.downloaded = false,
  });

  // Statische fromJson Methode
  static Job fromJson(Map<String, dynamic> json) {
    return Job(
      id: json['id'],
      name: json['name'],
      status: json['status'],
      buildingId: json['buildingId'],
      buildingAddress: json['buildingAddress'],
      buildingImage: json['buildingImage'],
      route: (json['route'] as List)
          .map((routeJson) => RouteStep.fromJson(routeJson))
          .toList(),
      progress: json['progress'] ?? 0, // Fortschritt
      comments: Map<String, String>.from(json['comments'] ?? {}),
      userStatus: json['userStatus'] ?? 'unstarted',
      downloaded: json['downloaded'] ?? false,
    );
  }

  // Statische toJson Methode
  static Map<String, dynamic> toJson(Job job) {
    return {
      'id': job.id,
      'name': job.name,
      'status': job.status,
      'buildingId': job.buildingId,
      'buildingAddress': job.buildingAddress,
      'buildingImage': job.buildingImage,
      'route': job.route.map((step) => RouteStep.toJson(step)).toList(),
      'progress': job.progress,
      'comments': job.comments,
      'userStatus': job.userStatus,
      'downloaded': job.downloaded,
    };
  }
}
