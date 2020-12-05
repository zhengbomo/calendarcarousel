import 'package:intl/intl.dart' show DateFormat;
import 'package:flutter/material.dart';
import 'package:stateful_builder_controller/stateful_builder_controller.dart';
import './calendar_weekday.dart';
import './animated_aspectratio.dart';
import './calendar_default_widget.dart';

const _IntegerHalfMax = 0x7fffffff ~/ 2;
const _kTodayIndex = _IntegerHalfMax;

typedef Widget DayWidgetBuilder(
    DateTime date, bool isLastMonthDay, bool isNextMonthDay);
typedef Widget WeekdayWidgetBuilder(int weekday);
typedef Widget CalendarHeaderWidgetBuilder(
    CalendarController controller, DateFormat dateFormat, DateTime dateTime);

typedef void ChangeIsMinimal(bool isminimal, DateTime? dateTime);

class CalendarCarousel extends StatefulWidget {
  final int year;
  final int month;
  final int day;
  final int firstDayOfWeek;
  final double childAspectRatio;
  final DateFormat dateFormat;
  final CalendarController controller;

  final CalendarHeaderWidgetBuilder headerWidgetBuilder;
  final DayWidgetBuilder dayWidgetBuilder;
  final WeekdayWidgetBuilder weekdayWidgetBuilder;

  CalendarCarousel(
      {Key? key,
      int? year,
      int? month,
      int? firstDayOfWeek,
      CalendarHeaderWidgetBuilder? headerWidgetBuilder,
      DayWidgetBuilder? dayWidgetBuilder,
      WeekdayWidgetBuilder? weekdayWidgetBuilder,
      CalendarController? controller,
      this.day = 1,
      this.childAspectRatio = 1,
      required this.dateFormat})
      : this.firstDayOfWeek = firstDayOfWeek ?? 7,
        this.year = year ?? DateTime.now().year,
        this.month = month ?? DateTime.now().month,
        this.controller = controller ?? CalendarController(),
        this.headerWidgetBuilder = headerWidgetBuilder ??
            ((controller, dateFormat, dateTime) {
              return CalendarDefaultHeader(
                calendarController: controller,
                dateTime: dateTime,
                dateFormat: dateFormat,
              );
            }),
        this.dayWidgetBuilder = dayWidgetBuilder ??
            ((DateTime date, bool isLastMonthDay, bool isNextMonthDay) {
              return CalendarDefaultDay(
                  dateTime: date,
                  isLastMonthDay: isLastMonthDay,
                  isNextMonthDay: isNextMonthDay);
            }),
        this.weekdayWidgetBuilder = weekdayWidgetBuilder ??
            ((int weekday) {
              return CalendarDefaultWeekday(
                  weekday: weekday, dateFormat: dateFormat);
              // return CalendarDefaultWeekday(weekday: weekday, dateFormat: dateFormat);
            }),
        super(key: key);

  @override
  _CalendarCarouselState createState() => _CalendarCarouselState();
}

class _CalendarCarouselState extends State<CalendarCarousel>
    with TickerProviderStateMixin {
  PageController? _pageController;

  // aspectRatio for monthView
  double _aspectRatio = 1;

  final _aspectRatioUpdateController = SetterController();
  final _headerUpdateController = SetterController();

  int _currentIndex = 0;

  @override
  void initState() {
    widget.controller._changeIsMinimal = _changeIsMinimal;
    widget.controller._firstDayOfWeek = widget.firstDayOfWeek;

    if (widget.controller.isMinimal) {
      _currentIndex = widget.controller
          ._getWeekIndexOfDate(DateTime(widget.year, widget.month, widget.day));
      _aspectRatio = 7.0 / 1 * widget.childAspectRatio;
    } else {
      _currentIndex =
          widget.controller._getIndexOfDate(widget.year, widget.month);
      var rowCount = _getRowCount(widget.year, widget.month);
      _aspectRatio = 7.0 / rowCount * widget.childAspectRatio;
    }
    _pageController = PageController(
      viewportFraction: 1,
      initialPage: _currentIndex,
      keepPage: false,
    );

    widget.controller._pageController = _pageController;
    widget.controller
        ._setCurrentDate(DateTime(widget.year, widget.month, widget.day));

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        _createHeaderView(),
        _createWeekView(),
        _createPageView()
      ],
    );
  }

  _changeIsMinimal(bool isMinimal, DateTime? dateTime) {
    var date = dateTime ?? widget.controller.currentDate;
    widget.controller._setIsMinimal(isMinimal);

    double aspectRatio = 1;
    if (isMinimal) {
      aspectRatio = 7.0 / 1 * widget.childAspectRatio;
      var currentPage = widget.controller._getWeekIndexOfDate(date);
      _pageController!.jumpToPage(currentPage);
    } else {
      var rowCount = _getRowCount(date.year, date.month);
      aspectRatio = 7.0 / rowCount * widget.childAspectRatio;
      var currentPage =
          widget.controller._getIndexOfDate(date.year, date.month);
      _pageController!.jumpToPage(currentPage);
    }

    if (_aspectRatio != aspectRatio) {
      _aspectRatioUpdateController.update(() {
        _aspectRatio = aspectRatio;
      });
    }
  }

  _pageChanged(int index) {
    // update header
    _headerUpdateController.update(() {});

    if (widget.controller.isMinimal) {
      var date = this._getActualDate(index);
      widget.controller._setCurrentDate(date);
      _currentIndex = index;
    } else {
      var date = this._getActualDate(index);
      var rowCount = _getRowCount(date.year, date.month);
      double aspectRatio = 7.0 / rowCount * widget.childAspectRatio;
      if (_aspectRatio != aspectRatio) {
        _aspectRatioUpdateController.update(() {
          _aspectRatio = aspectRatio;
        });
      }
      _currentIndex = index;
      widget.controller._setCurrentDate(date);
    }
  }

  int _getRowCount(int year, int month) {
    var firstWeekDay = DateTime(year, month, 1).weekday % 7;

    var lastMonthRestDayCount =
        (firstWeekDay - (widget.firstDayOfWeek % 7)) % 7;
    var thisMonthDayCount = DateTime(year, month + 1, 0).day;

    return ((thisMonthDayCount + lastMonthRestDayCount) / 7.0).ceil();
  }

  Widget _createHeaderView() {
    return StatefulBuilder1(
        builder: (context, setter, _) {
          return widget.headerWidgetBuilder(widget.controller,
              widget.dateFormat, _getActualDate(_currentIndex));
        },
        controller: _headerUpdateController);
  }

  Widget _createWeekView() {
    return CalendarWeekday(
        firstDayOfWeek: widget.firstDayOfWeek,
        builder: (weekday) {
          return widget.weekdayWidgetBuilder(weekday);
        });
  }

  Widget _createPageView() {
    return StatefulBuilder1<Widget>(
        builder: (context, setter, value) {
          return AnimatedAspectRatio(
              aspectRatio: _aspectRatio,
              duration: Duration(milliseconds: 300),
              curve: Curves.easeOut,
              child: value!);
        },
        controller: _aspectRatioUpdateController,
        value: PageView.builder(
          onPageChanged: _pageChanged,
          controller: _pageController,
          itemBuilder: (BuildContext context, int index) {
            if (widget.controller.isMinimal) {
              var date = this._getActualDate(index);
              return _createWeekRawView(date);
            } else {
              var date = this._getActualDate(index);
              return _createMonthView(date.year, date.month);
            }
          },
          scrollDirection: Axis.horizontal,
        ));
  }

  Widget _createWeekRawView(DateTime currentDate) {
    return Container(
      width: double.infinity,
      child: GridView.count(
        physics: NeverScrollableScrollPhysics(),
        crossAxisCount: 7,
        childAspectRatio: widget.childAspectRatio,
        children: List.generate(7, (index) {
          // 左边的日期个数
          var leftCount =
              (currentDate.weekday % 7) - (widget.firstDayOfWeek % 7);

          var date = currentDate.add(Duration(days: index - leftCount));

          // last month day
          var isLastMonthDay = date.month < currentDate.month;
          // next month day
          var isNextMonthDay = date.month > currentDate.month;
          return widget.dayWidgetBuilder(date, isLastMonthDay, isNextMonthDay);
        }),
      ),
    );
  }

  Widget _createMonthView(int year, int month) {
    var firstWeekDay = DateTime(year, month, 1).weekday % 7;
    var lastMonthRestDayCount =
        (firstWeekDay - (widget.firstDayOfWeek % 7)) % 7;

    var thisMonthDayCount = DateTime(year, month + 1, 0).day;
    var lastMonthDayCount = DateTime(year, month, 0).day;

    /// 行数
    var rowCount = ((thisMonthDayCount + lastMonthRestDayCount) / 7.0).ceil();

    return Container(
      width: double.infinity,
      child: GridView.count(
        physics: NeverScrollableScrollPhysics(),
        crossAxisCount: 7,
        childAspectRatio: widget.childAspectRatio,
        children: List.generate(rowCount * 7, (index) {
          var currentDay = index + 1 - lastMonthRestDayCount;
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
          return widget.dayWidgetBuilder(
              DateTime(year, currentMonth, currentDay),
              isLastMonthDay,
              isNextMonthDay);
        }),
      ),
    );
  }

  /// get actual month for PageView index
  DateTime _getActualDate(int index) {
    if (widget.controller.isMinimal) {
      var now = DateTime.now();
      return now.add(Duration(days: 7 * (index - _kTodayIndex)));
    } else {
      var now = DateTime.now();
      return DateTime(now.year, now.month - (_kTodayIndex - index));
    }
  }
}

class CalendarController extends ChangeNotifier {
  int _firstDayOfWeek;
  ChangeIsMinimal? _changeIsMinimal;
  PageController? _pageController;

  bool _isMinimal = false;
  bool get isMinimal => _isMinimal;
  _setIsMinimal(bool isminimal) {
    _isMinimal = isminimal;
  }

  DateTime _currentDate;
  DateTime get currentDate => _currentDate;
  _setCurrentDate(DateTime dateTime) {
    _currentDate = dateTime;
    notifyListeners();
  }

  CalendarController(
      {Key? key,
      int firstDayOfWeek = 0,
      DateTime? currentDate,
      bool isMinimal = false})
      : _isMinimal = isMinimal,
        _firstDayOfWeek = firstDayOfWeek,
        _currentDate = DateTime.now();

  /// scroll to next month / week
  ///
  /// it will do animate while duration is not null
  nextPage({Duration? duration, Curve curve = Curves.bounceInOut}) {
    if (duration != null) {
      _pageController!.nextPage(duration: duration, curve: curve);
    } else {
      _pageController!.jumpToPage((_pageController!.page! + 1).toInt());
    }
  }

  /// scroll to previous month / week
  ///
  /// it will do animate while duration is not null
  previousPage({Duration? duration, Curve curve = Curves.bounceInOut}) {
    if (duration != null) {
      _pageController!.previousPage(duration: duration, curve: curve);
    } else {
      _pageController!.jumpToPage((_pageController!.page! - 1).toInt());
    }
  }

  /// scroll to now
  ///
  /// it will do animate while duration is not null
  goToToday({Duration? duration, Curve curve = Curves.bounceInOut}) {
    var now = DateTime.now();
    goToDate(dateTime: now, duration: duration, curve: curve);
  }

  /// scroll to special day in month / week
  ///
  /// it will do animate while duration is not null
  goToDate(
      {required DateTime dateTime,
      Duration? duration,
      Curve curve = Curves.bounceInOut}) {
    int index;
    if (isMinimal) {
      index = _getWeekIndexOfDate(dateTime);
    } else {
      index = _getIndexOfDate(dateTime.year, dateTime.month);
    }

    if (duration != null) {
      _pageController!.animateToPage(index, duration: duration, curve: curve);
    } else {
      _pageController!.jumpToPage(index);
    }
  }

  /// expand/collapse month view
  changeIsMinimal(bool isMinimal, DateTime? dateTime) {
    if (_changeIsMinimal != null) {
      _changeIsMinimal!(isMinimal, dateTime);
    }
  }

  /// get page index of month
  int _getIndexOfDate(int year, int month) {
    var now = DateTime.now();
    var monthSpan = (year - now.year) * 12 + (month - now.month);
    return _kTodayIndex + monthSpan;
  }

  /// get week row page index
  int _getWeekIndexOfDate(DateTime dateTime) {
    var now = DateTime.now();
    var nowFirstDate =
        now.add(Duration(days: -((now.weekday - (_firstDayOfWeek % 7)) % 7)));

    var pageSpan = dateTime.difference(nowFirstDate).inDays / 7;
    return _IntegerHalfMax + pageSpan.floor();
  }
}
