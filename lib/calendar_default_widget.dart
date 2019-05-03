import 'package:intl/intl.dart' show DateFormat;
import 'package:flutter/material.dart';
 
var _dateFormat = DateFormat.yMMM("en");

class CalendarDefaultWeekday extends StatelessWidget {
  final int weekday;
  CalendarDefaultWeekday({this.weekday});

  @override
  Widget build(BuildContext context) {
    var werapWeekday = weekday % 7;
    var msg = _dateFormat.dateSymbols.STANDALONESHORTWEEKDAYS[werapWeekday]; 
    return Container(
      padding: EdgeInsets.all(12),
      child: Center(
        child: Text("$msg", textAlign: TextAlign.center,),
      )
    );
  }
}

class CalendarDefaultDay extends StatelessWidget {
  final DateTime dateTime;
  final bool isLastMonthDay;
  final bool isNextMonthDay;
  CalendarDefaultDay({this.dateTime, this.isLastMonthDay, this.isNextMonthDay});

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
  final PageController pageController;
  final DateTime dateTime;
  CalendarDefaultHeader({this.pageController, this.dateTime});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      padding: EdgeInsets.all(8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Expanded(
            child: Text("${_dateFormat.format(dateTime)}", style: TextStyle(fontSize: 20)),
          ),
          FlatButton(
            child: Text("Prev"),
            onPressed: () {
              pageController.previousPage(
                duration: Duration(milliseconds: 250), 
                curve: Curves.easeInOut
              );
            },
          ),
          FlatButton(
            child: Text("Next"),
            onPressed: () {
              pageController.nextPage(
                duration: Duration(milliseconds: 250), 
                curve: Curves.easeInOut
              );
            },
          )
        ],
      ),
    );
  }
}