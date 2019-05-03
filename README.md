# calendar_carousel

[![Pub Package](https://img.shields.io/pub/v/calendar_carousel.svg?style=flat-square)](https://pub.dartlang.org/packages/calendar_carousel)
[![Awesome Flutter](https://img.shields.io/badge/Awesome-Flutter-52bdeb.svg?longCache=true&style=flat-square)](https://github.com/zhengbomo/calendarcarousel)

A lightweight and highly customizable calendar view for your Flutter app.

## Showcase

![demo演示](https://github.com/zhengbomo/calendarcarousel/blob/master/images/demo.gif?raw=true)

![demo演示](https://github.com/zhengbomo/calendarcarousel/blob/master/images/demo.jpg?raw=true)

## Feature

* Extensive, yet easy to use API
* Custom Builders for true UI control
* Locale support
* Vertical autosizing
* Animation with height
* Month change handling

## Example

the calendar dependent on `intl` library, you have to init dateformatting first, like this

```dart
import 'package:intl/date_symbol_data_local.dart';

void main() {
  initializeDateFormatting("en", null).then((_) {
    runApp(MyApp());
  });
}
```

define `CalendarController` if you want to operate the calendar

```dart
CalendarController _calendarController = CalendarController();
var dateFormat = DateFormat.yMMM("en");

CalendarCarousel(
  controller: _calendarController,
  dateFormat: dateFormat,
  year: 2019,
  month: 5,
  weekdayWidgetBuilder: (weekday) {
    // customize the weekday header widget, the sunday for weekday is 7
    return CalendarDefaultWeekday(
      weekday: weekday,
      dateFormat: dateFormat,
      textStyle: TextStyle(
        fontSize: 16,
        color: Colors.red
      )
    );
  },
  dayWidgetBuilder: (date, isLastMonthDay, isNextMontyDay) {
    // customize the day widget in month widget
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
          print("$date");
        },
        child: Text(
          isToday ? "Today" : "${date.day}",
          style: TextStyle(fontSize: 16)
        ),
      ),
    );
  },
)
```

opeartion for calendar

```dart
// animate to today
_calendarController.goToToday(duration: const Duration(milliseconds: 250));

// jump to month without animation
_calendarController.goToMonth(year: 2015, month: 9);

// animate to month
_calendarController.goToMonth(
  year: 2018,
  month: 1,
  duration: const Duration(milliseconds: 250),
  curve: Curves.bounceIn
);

// get current month
var date = _calendarController.getCurrentMonth();
print("${date.year}-${date.month}");
```

listen calendar's month changed

```dart
_calendarController.addListener(() {
  print("month changed ${_calendarController.currentDate}");
});
```

## Getting Started

This project is a starting point for a Flutter
[plug-in package](https://flutter.io/developing-packages/),
a specialized package that includes platform-specific implementation code for
Android and/or iOS.

For help getting started with Flutter, view our
[online documentation](https://flutter.io/docs), which offers tutorials, 
samples, guidance on mobile development, and a full API reference.