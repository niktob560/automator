import 'package:flutter/material.dart';
import 'package:automator/rest_api/models.dart';

@immutable
class Meta<T extends Record> {
  final IconData icon;
  final String title;
  final Widget content;

  Meta(this.icon, this.title, this.content);
}
