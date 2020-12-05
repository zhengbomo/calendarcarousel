import 'package:flutter/material.dart';

typedef Widget WeekdayWidgetBuilder(int weekday);

class CalendarWeekday extends StatelessWidget {
  CalendarWeekday(this.firstDayOfWeek, {this.builder})
      : assert(firstDayOfWeek >= 0 && firstDayOfWeek <= 7);

  final int firstDayOfWeek;
  final WeekdayWidgetBuilder builder;

  List<Widget> _renderWeekDays() {
    var list = [];
    for (int i = 0; i < 7; i++) {
      var weekday = (firstDayOfWeek + i) % 7;
      if (weekday == 0) weekday = 7;
      list.add(weekday);
    }
    return list.map((i) => builder(i)).toList();
  }

  @override
  Widget build(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: _renderWeekDays(),
      );
}
