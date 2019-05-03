import 'package:intl/intl.dart' show DateFormat;
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter/material.dart';
import 'package:calendar_carousel/calendar_carousel.dart';
import 'package:calendar_carousel/calendar_default_widget.dart';


const _kDateFormatLanguageCode = "zh";

void main() {
  initializeDateFormatting(_kDateFormatLanguageCode, null).then((_) {
    runApp(MyApp());
  });
}
  

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  CalendarController _calendarController = CalendarController();
  @override
  void initState() {
    super.initState();

    _calendarController.addListener(() {
      print(_calendarController.currentDate);
    });
  }

  @override
  Widget build(BuildContext context) {
    var dateFormat = DateFormat.yMMM(_kDateFormatLanguageCode);
    var initYear = 2019;
    var initMonth = 2;

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('calendarcarousel demo'),
        ),
        body: ListView(
          children: <Widget>[
            CalendarCarousel(
              controller: _calendarController,
              dateFormat: dateFormat,
              year: initYear,
              month: initMonth,
              weekdayWidgetBuilder: (weekday) {
                return CalendarDefaultWeekday(weekday: weekday, dateFormat: dateFormat, textStyle: TextStyle(
                  fontSize: 16,
                  color: Colors.red
                ));
              },
              dayWidgetBuilder: (date, isLastMonthDay, isNextMontyDay) {
                var today = DateTime.now();
                var isToday = today.year == date.year && today.month == date.month && today.day == date.day;
                return Padding(
                  padding: EdgeInsets.all(3),
                  child: FlatButton(
                    padding: EdgeInsets.all(0),
                    shape: CircleBorder(side: BorderSide(width: 1, color: Colors.black12)),
                    color: isToday ? Colors.blueAccent : Colors.green,
                    textColor: (isLastMonthDay || isNextMontyDay) ? Colors.black : Colors.white,
                    onPressed: (isLastMonthDay || isNextMontyDay) ? null : () {

                    },
                    child: Text(
                      isToday ? "Today" : "${date.day}", 
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16)),
                  ),
                );
              },
            ),
            Container(
              height: 80,
              color: Colors.redAccent,
              child: Center(
                child: Text("Other Widget", style: TextStyle(fontSize: 20, color: Colors.white)),
              ),
            ),
            RaisedButton(
              onPressed: () {
                _calendarController.goToToday(duration: const Duration(milliseconds: 250));
              },
              child: Text("animate to today"),
            ),
            RaisedButton(
              onPressed: () {
                _calendarController.goToMonth(year: 2012, month: 9, duration: null);
              },
              child: Text("jump to 2012-09"),
            ),
            RaisedButton(
              onPressed: () {
                _calendarController.goToMonth(year: 2018, month: 1, duration: const Duration(milliseconds: 250), curve: Curves.bounceIn);
              },
              child: Text("animate to 2018-01"),
            ),
            Builder(
              builder: (context) {
                return RaisedButton(
                  onPressed: () {
                    var date = _calendarController.getCurrentMonth();
                    var snakBar = SnackBar(
                      content: Text("${date.year}-${date.month}"), 
                    );
                    Scaffold.of(context).showSnackBar(snakBar);
                  },
                  child: Text("show current month"),
                );
              },
            )
          ],
        ),
      ),
    );
  }
}


