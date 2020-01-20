import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:intl/intl.dart';
import 'package:vector_math/vector_math_64.dart' show radians;

import 'package:flutter_clock_helper/model.dart';

import 'clockface.dart';
import 'clockwise.dart';

/// Total distance traveled by a second or a minute hand, each second or minute,
/// respectively.
final radiansPerTick = radians(360 / 60);

/// Total distance traveled by an hour hand, each hour, in radians.
final radiansPerHour = radians(360 / 12);

class AnalogClock extends StatefulWidget {
  const AnalogClock(this.model);

  final ClockModel model;

  @override
  _AnalogClockState createState() => _AnalogClockState();
}

class _AnalogClockState extends State<AnalogClock>
    with SingleTickerProviderStateMixin {
  var _now = DateTime.now();
  var _temperature = '';
  var _temperatureRange = '';
  var _condition = '';
  var _location = '';
  Timer _timer;

  @override
  void initState() {
    super.initState();
    widget.model.addListener(_updateModel);
    // Set the initial values.
    _updateTime();
    _updateModel();
  }

  @override
  void didUpdateWidget(AnalogClock oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.model != oldWidget.model) {
      oldWidget.model.removeListener(_updateModel);
      widget.model.addListener(_updateModel);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    widget.model.removeListener(_updateModel);
    super.dispose();
  }

  void _updateModel() {
    setState(() {
      _temperature = widget.model.temperatureString;
      _temperatureRange = '(${widget.model.low} - ${widget.model.highString})';
      _condition = widget.model.weatherString;
      _location = widget.model.location;
    });
  }

  void _updateTime() {
    setState(() {
      _now = DateTime.now();
      // Update once per second. Make sure to do it at the beginning of each
      // new second, so that the clock is accurate.
      _timer = Timer(
        Duration(seconds: 1) - Duration(milliseconds: _now.millisecond),
        _updateTime,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    // There are many ways to apply themes to your clock. Some are:
    //  - Inherit the parent Theme (see ClockCustomizer in the
    //    flutter_clock_helper package).
    //  - Override the Theme.of(context).colorScheme.
    //  - Create your own [ThemeData], demonstrated in [AnalogClock].
    //  - Create a map of [Color]s to custom keys, demonstrated in
    //    [DigitalClock].
    final customTheme = (Theme.of(context).brightness == Brightness.light
        ? Theme.of(context).copyWith(
            // Hours
            primaryColor: Colors.black,
            // Minute
            highlightColor: Colors.black38,
            // Seconds
            focusColor: Colors.grey[600],

            primaryColorDark: Color(0xffdadada),
            primaryColorLight: Color(0xff999999),
            accentColor: Color(0xffcccccc),
            backgroundColor: Color(0xffbdbdbd),
          )
        : Theme.of(context).copyWith(
            // Hours
            primaryColor: Colors.white,
            // Minutes
            highlightColor: Colors.white38,
            // Seconds
            focusColor: Colors.red,

            primaryColorDark: Colors.black,
            primaryColorLight: Color(0xff353235),
            accentColor: Color(0xff141516),
            backgroundColor: Color(0xff1E2025),
          ));

    final time = DateFormat.yMMMMd().format(DateTime.now());

    return Semantics.fromProperties(
      properties: SemanticsProperties(
        label: 'Analog clock with time $time',
        value: time,
      ),
      child: Container(
        color: customTheme.backgroundColor,
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: <Widget>[
            Expanded(
              flex: 2,
              child: Container(
                margin: const EdgeInsets.all(16.0),
                padding: const EdgeInsets.all(4.0),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: customTheme.primaryColorDark,
                      offset: Offset(4, 4),
                      blurRadius: 15,
                      spreadRadius: 4,
                    ),
                    BoxShadow(
                      color: customTheme.primaryColorLight,
                      offset: Offset(-4, -4),
                      blurRadius: 15,
                      spreadRadius: 4,
                    ),
                  ],
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      customTheme.primaryColorDark,
                      customTheme.primaryColorLight,
                    ],
                  ),
                ),
                child: Container(
                  child: Stack(
                    alignment: Alignment.center,
                    children: <Widget>[
                      Clockface(
                        hoursStyle: TextStyle(
                          color: customTheme.primaryColor,
                          fontSize: 16.0,
                        ),
                        secondsColor: customTheme.focusColor,
                      ),
                      Clockwise(
                        color: customTheme.primaryColor,
                        thickness: 3,
                        size: 0.4,
                        angleRadians: _now.hour * radiansPerHour +
                            (_now.minute / 60) * radiansPerHour,
                      ),
                      Clockwise(
                        color: customTheme.highlightColor,
                        thickness: 2,
                        size: 0.5,
                        angleRadians: _now.minute * radiansPerTick,
                      ),
                      Clockwise(
                        color: Colors.red,
                        thickness: 1,
                        size: 0.6,
                        angleRadians: _now.second * radiansPerTick,
                      ),
                    ],
                  ),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        customTheme.backgroundColor,
                        customTheme.accentColor,
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    _location,
                    style: TextStyle(
                      color: customTheme.primaryColor,
                    ),
                  ),
                  Text(
                    time,
                    style: TextStyle(
                      color: customTheme.primaryColor.withOpacity(0.6),
                      fontSize: 12.0,
                    ),
                  ),
                  Text(
                    _temperature,
                    style: TextStyle(
                      color: customTheme.primaryColor.withOpacity(0.4),
                      fontSize: 12.0,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
