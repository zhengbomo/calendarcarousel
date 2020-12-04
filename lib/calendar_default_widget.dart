import 'package:intl/intl.dart' show DateFormat;
import 'package:flutter/material.dart';
import './calendar_carousel.dart' show CalendarController;
 
class CalendarDefaultWeekday extends StatelessWidget {

  final int weekday;
  final DateFormat dateFormat;
  final TextStyle? textStyle;

  CalendarDefaultWeekday({
    required this.weekday,
    required this.dateFormat,
    this.textStyle
  });

  @override
  Widget build(BuildContext context) {
    var werapWeekday = weekday % 7;
    var msg = dateFormat.dateSymbols.STANDALONESHORTWEEKDAYS[werapWeekday]; 
    return Expanded(
      child: Padding(
        padding: EdgeInsets.all(3),
        child: Center(
          child: Text("$msg", textAlign: TextAlign.center, style: this.textStyle),
        ),
      )
    );
  }
}

class CalendarDefaultDay extends StatelessWidget {

  final DateTime dateTime;
  final bool isLastMonthDay;
  final bool isNextMonthDay;

  CalendarDefaultDay({
    required this.dateTime,
    required this.isLastMonthDay,
    required this.isNextMonthDay
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(3),
      child: Container(
        color: (isLastMonthDay || isNextMonthDay) ? Colors.black12 : Colors.green,
        child: Center(
          child: Text(
            "${dateTime.day}",
            style: TextStyle(
              color: (isLastMonthDay || isNextMonthDay) ? Colors.black : Colors.white
            ),
          )
        ),
      ),
    );
  }
}

class CalendarDefaultHeader extends StatelessWidget {
  final CalendarController calendarController;
  final DateTime dateTime;
  final DateFormat dateFormat;
  CalendarDefaultHeader({
    required this.calendarController,
    required this.dateTime,
    required this.dateFormat
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      padding: EdgeInsets.all(8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          IconButton(
            icon: Icon(Icons.chevron_left),
            onPressed: () {
              calendarController.previousPage(
                duration: Duration(milliseconds: 300), 
                curve: Curves.easeInOut
              );
            },
          ),
          Expanded(
            child: Text("${dateFormat.format(dateTime)}", style: TextStyle(fontSize: 20), textAlign: TextAlign.center),
          ),
          IconButton(
            icon: Icon(Icons.chevron_right),
            onPressed: () {
              calendarController.nextPage(
                duration: Duration(milliseconds: 300), 
                curve: Curves.easeInOut
              );
            },
          )
        ],
      ),
    );
  }
}