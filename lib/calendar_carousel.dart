import 'package:flutter/material.dart';
import './calendar_weekday.dart';
import './animated_aspectratio.dart';
import './calendar_default_widget.dart';

const _IntegerHalfMax = 0x7fffffff ~/ 2;


typedef Widget DayWidgetBuilder(DateTime date, bool isLastMonthDay, bool isNextMonthDay);
typedef Widget WeekdayWidgetBuilder(int weekday);

class CalendarCarousel extends StatefulWidget {
  final int year;
  final int month;
  final int firstDayOfWeek;
  
  final DayWidgetBuilder dayWidgetBuilder;
  final WeekdayWidgetBuilder weekdayWidgetBuilder;

  CalendarCarousel({
    Key key,
    int year,
    int month,
    int firstDayOfWeek,
    DayWidgetBuilder dayWidgetBuilder, 
    WeekdayWidgetBuilder weekdayWidgetBuilder,
  }) : 
    this.firstDayOfWeek = firstDayOfWeek ?? 7,
    this.year = year ?? DateTime.now().year,
    this.month = month ?? DateTime.now().month,
    this.dayWidgetBuilder = dayWidgetBuilder ?? 
      ((DateTime date, bool isLastMonthDay, bool isNextMonthDay) {
        return CalendarDefaultDay(dateTime: date, isLastMonthDay: isLastMonthDay, isNextMonthDay: isNextMonthDay);
      }),
      this.weekdayWidgetBuilder = weekdayWidgetBuilder ?? 
        ((int weekday) {
          return CalendarDefaultWeekday(weekday: weekday);
        }),
      super(key: key);

  @override
  _CalendarCarouselState createState() => _CalendarCarouselState();
}

class _CalendarCarouselState extends State<CalendarCarousel> with TickerProviderStateMixin  {
  PageController _pageController;

  double _aspectRatio = 1;
  int _currentIndex = _IntegerHalfMax;

  @override
  void initState() {
    var now = DateTime.now();
    var currentDate = DateTime(widget.year, widget.month, 10);
    var monthSpan = (currentDate.year - now.year) * 12 + (currentDate.month - now.month);
    _currentIndex += monthSpan;

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
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        CalendarDefaultHeader(pageController: _pageController, dateTime: _getActualDate(_currentIndex)),
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
  }

  Widget _createWeekView() {
    return WeekdayRow(0, builder: (weekday) {
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
    return DateTime(now.year, now.month - (_IntegerHalfMax - index));
  }
}