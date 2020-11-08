import 'dart:math';
import 'package:flutter/material.dart';

double getLightRedViaHour(double hour) {
  final double a = -1.31004,
      b = 94.6404,
      c = -137.295,
      d = 68.0758,
      e = -14.7418,
      f = 1.64884,
      g = -0.0969477,
      h = 0.00256625,
      i = -5.11382 * pow(10, -6),
      j = -7.04052 * pow(10, -7);
  return a +
      b * hour +
      c * pow(hour, 2) +
      d * pow(hour, 3) -
      e * pow(hour, 4) +
      f * pow(hour, 5) +
      g * pow(hour, 6) +
      h * pow(hour, 7) +
      i * pow(hour, 8) +
      j * pow(hour, 9);
}

double getLightGreenViaHour(double hour) {
  final double a = 24.5474,
      b = 27.8814,
      c = -35.7181,
      d = 35.0174,
      e = -11.8376,
      f = 1.99829,
      g = -0.189334,
      h = 0.0102199,
      j = -0.000293351,
      k = 3.47462 * pow(10, -6);
  return a +
      b * hour +
      c * pow(hour, 2) +
      d * pow(hour, 3) -
      e * pow(hour, 4) +
      f * pow(hour, 5) +
      g * pow(hour, 6) +
      h * pow(hour, 7) +
      j * pow(hour, 8) +
      k * pow(hour, 9);
}

double getLightBlueViaHour(double hour) {
  final double a = 44.4208,
      b = -0.163395,
      c = 15.2644,
      d = 10.0952,
      e = -6.38685,
      f = 1.30662,
      g = -0.134333,
      h = 0.00754987,
      j = -0.00022217,
      k = 2.68613 * pow(10, -6);
  return a +
      b * hour +
      c * pow(hour, 2) +
      d * pow(hour, 3) -
      e * pow(hour, 4) +
      f * pow(hour, 5) +
      g * pow(hour, 6) +
      h * pow(hour, 7) +
      j * pow(hour, 8) +
      k * pow(hour, 9);
}

Color getLightColorViaHour(double hour) {
  return dayNightGradient[hour.round()].colors[0];
  // return Color.fromARGB(255, getLightRedViaHour(hour).round(), getLightGreenViaHour(hour).round(), getLightBlueViaHour(hour).round());
  // return Color.fromARGB(255, (dayNightGradient[8].colors[1].red * (hour / 24)).round(), (dayNightGradient[8].colors[1].green * (hour / 24)).round(), (dayNightGradient[8].colors[1].blue * (hour / 24)).round());
}

final Alignment dayNightBegin = Alignment.centerLeft,
    dayNightEnd = Alignment.centerRight;

final List<LinearGradient> dayNightGradient = [
  //0
  LinearGradient(
    begin: dayNightBegin,
    end: dayNightEnd,
    colors: [
      Color.fromARGB(255, 1, 36, 89),
      Color.fromARGB(255, 0, 19, 34),
    ],
    tileMode: TileMode.repeated,
  ),
//1
  LinearGradient(
    begin: dayNightBegin,
    end: dayNightEnd,
    colors: [
      Color.fromARGB(255, 0, 57, 114),
      Color.fromARGB(255, 0, 19, 34),
    ],
    tileMode: TileMode.repeated,
  ),
//2
  LinearGradient(
    begin: dayNightBegin,
    end: dayNightEnd,
    colors: [
      Color.fromARGB(255, 0, 57, 114),
      Color.fromARGB(255, 0, 19, 34),
    ],
    tileMode: TileMode.repeated,
  ),
//3
  LinearGradient(
    begin: dayNightBegin,
    end: dayNightEnd,
    colors: [
      Color.fromARGB(255, 0, 67, 114),
      Color.fromARGB(255, 0, 24, 43),
    ],
    tileMode: TileMode.repeated,
  ),
//4
  LinearGradient(
    begin: dayNightBegin,
    end: dayNightEnd,
    colors: [
      Color.fromARGB(255, 0, 67, 114),
      Color.fromARGB(255, 1, 29, 52),
    ],
    tileMode: TileMode.repeated,
  ),
//5
  LinearGradient(
    begin: dayNightBegin,
    end: dayNightEnd,
    colors: [
      Color.fromARGB(255, 1, 103, 146),
      Color.fromARGB(255, 0, 24, 43),
    ],
    tileMode: TileMode.repeated,
  ),
//6
  LinearGradient(
    begin: dayNightBegin,
    end: dayNightEnd,
    colors: [
      Color.fromARGB(255, 7, 114, 159),
      Color.fromARGB(255, 4, 44, 71),
    ],
    tileMode: TileMode.repeated,
  ),
//7
  LinearGradient(
    begin: dayNightBegin,
    end: dayNightEnd,
    colors: [
      Color.fromARGB(255, 18, 161, 192),
      Color.fromARGB(255, 7, 80, 110),
    ],
    tileMode: TileMode.repeated,
  ),
//8
  LinearGradient(
    begin: dayNightBegin,
    end: dayNightEnd,
    colors: [
      Color.fromARGB(255, 116, 212, 204),
      Color.fromARGB(255, 19, 134, 166),
    ],
    tileMode: TileMode.repeated,
  ),
//9
  LinearGradient(
    begin: dayNightBegin,
    end: dayNightEnd,
    colors: [
      Color.fromARGB(255, 239, 238, 188),
      Color.fromARGB(255, 97, 208, 207),
    ],
    tileMode: TileMode.repeated,
  ),
//10
  LinearGradient(
    begin: dayNightBegin,
    end: dayNightEnd,
    colors: [
      Color.fromARGB(255, 254, 225, 84),
      Color.fromARGB(255, 163, 222, 198),
    ],
    tileMode: TileMode.repeated,
  ),
//11
  LinearGradient(
    begin: dayNightBegin,
    end: dayNightEnd,
    colors: [
      Color.fromARGB(255, 253, 195, 82),
      Color.fromARGB(255, 232, 237, 146),
    ],
    tileMode: TileMode.repeated,
  ),
//12
  LinearGradient(
    begin: dayNightBegin,
    end: dayNightEnd,
    colors: [
      Color.fromARGB(255, 255, 172, 111),
      Color.fromARGB(255, 255, 228, 103),
    ],
    tileMode: TileMode.repeated,
  ),
//13
  LinearGradient(
    begin: dayNightBegin,
    end: dayNightEnd,
    colors: [
      Color.fromARGB(255, 253, 166, 90),
      Color.fromARGB(255, 255, 228, 103),
    ],
    tileMode: TileMode.repeated,
  ),
//14
  LinearGradient(
    begin: dayNightBegin,
    end: dayNightEnd,
    colors: [
      Color.fromARGB(255, 253, 158, 88),
      Color.fromARGB(255, 255, 228, 103),
    ],
    tileMode: TileMode.repeated,
  ),
//15
  LinearGradient(
    begin: dayNightBegin,
    end: dayNightEnd,
    colors: [
      Color.fromARGB(255, 241, 132, 72),
      Color.fromARGB(255, 255, 211, 100),
    ],
    tileMode: TileMode.repeated,
  ),
//16
  LinearGradient(
    begin: dayNightBegin,
    end: dayNightEnd,
    colors: [
      Color.fromARGB(255, 240, 107, 126),
      Color.fromARGB(255, 249, 168, 86),
    ],
    tileMode: TileMode.repeated,
  ),
//17
  LinearGradient(
    begin: dayNightBegin,
    end: dayNightEnd,
    colors: [
      Color.fromARGB(255, 202, 90, 146),
      Color.fromARGB(255, 244, 137, 107),
    ],
    tileMode: TileMode.repeated,
  ),
//18
  LinearGradient(
    begin: dayNightBegin,
    end: dayNightEnd,
    colors: [
      Color.fromARGB(255, 91, 44, 131),
      Color.fromARGB(255, 209, 98, 139),
    ],
    tileMode: TileMode.repeated,
  ),
//19
  LinearGradient(
    begin: dayNightBegin,
    end: dayNightEnd,
    colors: [
      Color.fromARGB(255, 55, 26, 121),
      Color.fromARGB(255, 113, 54, 132),
    ],
    tileMode: TileMode.repeated,
  ),
//20
  LinearGradient(
    begin: dayNightBegin,
    end: dayNightEnd,
    colors: [
      Color.fromARGB(255, 40, 22, 107),
      Color.fromARGB(255, 69, 33, 124),
    ],
    tileMode: TileMode.repeated,
  ),
//21
  LinearGradient(
    begin: dayNightBegin,
    end: dayNightEnd,
    colors: [
      Color.fromARGB(255, 25, 40, 97),
      Color.fromARGB(255, 55, 32, 116),
    ],
    tileMode: TileMode.repeated,
  ),
//22
  LinearGradient(
    begin: dayNightBegin,
    end: dayNightEnd,
    colors: [
      Color.fromARGB(255, 4, 11, 60),
      Color.fromARGB(255, 35, 48, 114),
    ],
    tileMode: TileMode.repeated,
  ),
//23
  LinearGradient(
    begin: dayNightBegin,
    end: dayNightEnd,
    colors: [
      Color.fromARGB(255, 4, 11, 60),
      Color.fromARGB(255, 1, 36, 89),
    ],
    tileMode: TileMode.repeated,
  ),
];
