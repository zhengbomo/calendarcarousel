import 'package:intl/intl.dart' show DateFormat;
import 'package:flutter/material.dart';
import './calendar_weekday.dart';
import './animated_aspectratio.dart';
import './calendar_default_widget.dart';

const _IntegerHalfMax = 0x7fffffff ~/ 2;
const _kTodayIndex = _IntegerHalfMax;

typedef Widget DayWidgetBuilder(DateTime date, bool isLastMonthDay, bool isNextMonthDay);
typedef Widget WeekdayWidgetBuilder(int weekday);

class CalendarCarousel extends StatefulWidget {
  final int year;
  final int month;
  final int firstDayOfWeek;
  final DateFormat dateFormat;
  final CalendarController controller;
  
  final DayWidgetBuilder dayWidgetBuilder;
  final WeekdayWidgetBuilder weekdayWidgetBuilder;

  CalendarCarousel({
    Key key,
    int year,
    int month,
    int firstDayOfWeek,
    DayWidgetBuilder dayWidgetBuilder, 
    WeekdayWidgetBuilder weekdayWidgetBuilder,
    CalendarController controller,
    @required this.dateFormat
  }) : 
    this.firstDayOfWeek = firstDayOfWeek ?? 7,
    this.year = year ?? DateTime.now().year,
    this.month = month ?? DateTime.now().month,
    this.controller = controller ?? CalendarController(),
    this.dayWidgetBuilder = dayWidgetBuilder ?? 
      ((DateTime date, bool isLastMonthDay, bool isNextMonthDay) {
        return CalendarDefaultDay(
          dateTime: date, 
          isLastMonthDay: isLastMonthDay, 
          isNextMonthDay: isNextMonthDay
        );
      }),
      this.weekdayWidgetBuilder = weekdayWidgetBuilder ?? 
        ((int weekday) {
          return CalendarDefaultWeekday(weekday: weekday, dateFormat: dateFormat);
        }),
      super(key: key);

  @override
  _CalendarCarouselState createState() => _CalendarCarouselState();
}

class _CalendarCarouselState extends State<CalendarCarousel> with TickerProviderStateMixin  {
  PageController _pageController;

  double _aspectRatio = 1;

  int _currentIndex = 0;
  
  @override
  void initState() {
    var now = DateTime.now();
    var currentDate = DateTime(widget.year, widget.month, 10);
    var monthSpan = (currentDate.year - now.year) * 12 + (currentDate.month - now.month);
    _currentIndex = _kTodayIndex + monthSpan;

    _pageController = PageController(
      viewportFraction: 1,
      initialPage: _currentIndex,
      keepPage: false,
    );

    var date = this._getActualDate(_currentIndex);
    var firstWeekDay = DateTime(date.year, date.month, 1).weekday % 7;
    var thisMonthDayCount = DateTime(date.year, date.month + 1, 0).day;

    /// 行数
    var rowCount = ((thisMonthDayCount + firstWeekDay) / 7.0).ceil();
    setState(() {
      _aspectRatio = 7.0 / rowCount; 
    });

    widget.controller._pageController = _pageController;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        CalendarDefaultHeader(
          calendarController: widget.controller, 
          dateTime: _getActualDate(_currentIndex),
          dateFormat: widget.dateFormat,
        ),
        _createWeekView(),
        _createPageView()
      ],
    );
  } 

  _pageChanged(int index) {
    var date = this._getActualDate(index);
    var firstWeekDay = DateTime(date.year, date.month, 1).weekday % 7;
    var thisMonthDayCount = DateTime(date.year, date.month + 1, 0).day;

    /// 行数
    var rowCount = ((thisMonthDayCount + firstWeekDay) / 7.0).ceil();
    setState(() {
      _aspectRatio = 7.0 / rowCount; 
    });
    _currentIndex = index;
    widget.controller._setCurrentDate(date);
  }

  Widget _createWeekView() {
    return CalendarWeekday(0, builder: (weekday) {
      return widget.weekdayWidgetBuilder(weekday);
    });
  }

  Widget _createPageView() {
    return AnimatedAspectRatio(
      aspectRatio: _aspectRatio, 
      duration: Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      child: PageView.builder(
        onPageChanged: _pageChanged,
        controller: _pageController,
        itemBuilder:(BuildContext context,int index) {
          var date = this._getActualDate(index);
          return createMonthView(date.year, date.month);
        },
        scrollDirection: Axis.horizontal,
      )
    );
  }

  Widget createMonthView(int year, int month) {
    var firstWeekDay = DateTime(year, month, 1).weekday % 7;
    var lastMonthDayCount = DateTime(year, month, 0).day;
    var thisMonthDayCount = DateTime(year, month + 1, 0).day;

    /// 行数
    var rowCount = ((thisMonthDayCount + firstWeekDay) / 7.0).ceil();
    return Container(
      width: double.infinity,
      child: GridView.count(
        physics: NeverScrollableScrollPhysics(),
        crossAxisCount: 7,
        childAspectRatio: 1,
        children: List.generate(rowCount * 7, (index) {
          var currentDay = index + 1 - firstWeekDay;
          // last month day
          var isLastMonthDay = false;
          // next month day
          var isNextMonthDay = false;
          
          var currentMonth = month;
          if (currentDay <= 0) {
            isLastMonthDay = true;
            currentDay = lastMonthDayCount + currentDay;
            currentMonth -= 1;
          } else if (currentDay > thisMonthDayCount) {
            isNextMonthDay = true;
            currentDay = currentDay - thisMonthDayCount;

            currentMonth += 1;
          }
          return widget.dayWidgetBuilder(DateTime(year, currentMonth, currentDay), isLastMonthDay, isNextMonthDay);
        }),
      ),
    );
  }

  DateTime _getActualDate(int index) {
    var now = DateTime.now();
    return DateTime(now.year, now.month - (_kTodayIndex - index));
  }
}


class CalendarController extends ChangeNotifier {
  PageController _pageController;
  DateTime _currentDate;

  DateTime get currentDate => _currentDate;
  _setCurrentDate(DateTime dateTime) {
    _currentDate = dateTime;
    notifyListeners();
  }

  ValueNotifier<bool> canListenLoading = ValueNotifier(false);


  nextPage({ 
    Duration duration,
    Curve curve = Curves.bounceInOut 
  }) {
    if (duration != null) {
      _pageController.nextPage(
        duration: duration, 
        curve: curve
      );
    } else {
      _pageController.jumpToPage((_pageController.page + 1).toInt());
    }    
  }

  previousPage({
    Duration duration,
    Curve curve = Curves.bounceInOut 
  }) {
    if (duration != null) {
      _pageController.previousPage(
        duration: duration, 
        curve: curve
      );
    } else {
      _pageController.jumpToPage((_pageController.page - 1).toInt());
    }    
  }

  goToToday({
    Duration duration,
    Curve curve = Curves.bounceInOut 
  }) {
    var now = DateTime.now();
    goToMonth(year: now.year, month: now.month, duration: duration, curve: curve);
  }

  goToMonth({
    @required int year, 
    @required int month,
    Duration duration,
    Curve curve = Curves.bounceInOut 
  }) {
    var index = _getIndexOfDate(year, month);
    if (duration != null) {
      _pageController.animateToPage(
        index, 
        duration: duration, 
        curve: curve
      );
    } else {
      _pageController.jumpToPage(index);
    }
  }

  DateTime getCurrentMonth() {
    return currentDate;
    // var index = _pageController.page.toInt();
    // var monthSpan = index - _kTodayIndex;
    // var now = DateTime.now();
    // return DateTime(now.year, now.month + monthSpan);
  }

  // get page index of month
  int _getIndexOfDate(int year, int month) {
    var now = DateTime.now();
    var monthSpan = (year - now.year) * 12 + (month - now.month);
    return _kTodayIndex + monthSpan;
  }

  
}