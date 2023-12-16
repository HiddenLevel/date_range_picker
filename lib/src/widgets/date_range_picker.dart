import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_date_range_picker/flutter_date_range_picker.dart';
import 'package:intl/intl.dart';

/// The default [CalendarTheme] used by the date range picker.
const CalendarTheme kTheme = CalendarTheme(
  selectedColor: Colors.blue,
  dayNameTextStyle: TextStyle(color: Colors.black45, fontSize: 10),
  inRangeColor: Color(0xFFD9EDFA),
  inRangeTextStyle: TextStyle(color: Colors.blue),
  selectedTextStyle: TextStyle(color: Colors.white),
  todayTextStyle: TextStyle(fontWeight: FontWeight.bold),
  defaultTextStyle: TextStyle(color: Colors.black, fontSize: 12),
  radius: 10,
  tileSize: 40,
  disabledTextStyle: TextStyle(color: Colors.grey),
);

/// A function that builds a day tile for the date range picker.
///
/// * [dayModel] - The model for the day tile to be built.
/// * [theme] - The theme to apply to the day tile.
/// * [onTap] - A callback function to be called when the day tile is tapped.
Widget kDayTileBuilder(
  DayModel dayModel,
  CalendarTheme theme,
  ValueChanged<DateTime> onTap,
) {
  TextStyle combinedTextStyle = theme.defaultTextStyle;

  if (dayModel.isToday) {
    combinedTextStyle = combinedTextStyle.merge(theme.todayTextStyle);
  }

  if (dayModel.isInRange) {
    combinedTextStyle = combinedTextStyle.merge(theme.inRangeTextStyle);
  }

  if (dayModel.isSelected) {
    combinedTextStyle = combinedTextStyle.merge(theme.selectedTextStyle);
  }

  if (!dayModel.isSelectable) {
    combinedTextStyle = combinedTextStyle.merge(theme.disabledTextStyle);
  }

  return DayTileWidget(
    size: theme.tileSize,
    textStyle: combinedTextStyle,
    backgroundColor: dayModel.isInRange ? theme.inRangeColor : null,
    color: dayModel.isSelected ? theme.selectedColor : null,
    text: dayModel.date.day.toString(),
    value: dayModel.date,
    onTap: dayModel.isSelectable ? onTap : null,
    radius: BorderRadius.horizontal(
      left: Radius.circular(
          dayModel.isEnd && dayModel.isInRange ? 0 : theme.radius),
      right: Radius.circular(
          dayModel.isStart && dayModel.isInRange ? 0 : theme.radius),
    ),
    backgroundRadius: BorderRadius.horizontal(
      left: Radius.circular(dayModel.isStart ? theme.radius : 0),
      right: Radius.circular(dayModel.isEnd ? theme.radius : 0),
    ),
  );
}

/// A widget that displays the names of the days of the week for the date range picker.
class DayNamesRow extends StatelessWidget {
  /// Creates a [DayNamesRow].
  ///
  /// * [key] - The [Key] for this widget.
  /// * [textStyle] - The style to apply to the day names text.
  /// * [weekDays] - The names of the days of the week to display. If null, defaults to the default week days.
  DayNamesRow({
    Key? key,
    required this.textStyle,
    List<String>? weekDays,
  })  : weekDays = weekDays ?? defaultWeekDays(),
        super(key: key);

  final TextStyle textStyle;
  final List<String> weekDays;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var day in weekDays)
          Expanded(
            child: Center(
              child: Text(
                day,
                style: textStyle,
              ),
            ),
          ),
      ],
    );
  }
}

/// A widget that displays a date range picker.
///
/// The onDateRangeChanged callback is called whenever the selected date range
/// is changed.
///
/// The initialDisplayedDate is the date that is initially displayed when the
/// picker is opened. If no initial date is provided, the current date is used.
///
/// The minimumDateRangeLength and maximumDateRangeLength properties can be used
/// to limit the length of the selected date range.
///
/// The doubleMonth property can be set to true to display two months at a time.
///
/// The disabledDates property can be used to disable specific dates.
///
/// The quickDateRanges property can be used to display a list of quick selection
/// dateRanges at the top of the picker.
///
/// The height property can be used to set the height of the picker.
///
/// The theme property can be used to customize the appearance of the picker.
class DateRangePickerWidget extends StatefulWidget {
  const DateRangePickerWidget(
      {Key? key,
      required this.onDateRangeChanged,
      this.initialDisplayedDate,
      this.minimumDateRangeLength,
      this.initialDateRange,
      this.minDate,
      this.maxDate,
      this.theme = kTheme,
      this.maximumDateRangeLength,
      this.disabledDates = const [],
      this.quickDateRanges = const [],
      this.doubleMonth = true,
      this.height = 600,
      this.displayMonthsSeparator = true,
      this.separatorThickness = 1,
      this.minimunHTimeDiff = 1})
      : super(key: key);

  /// Called whenever the selected date range is changed.
  final ValueChanged<DateRange?> onDateRangeChanged;

  /// A list of quick selection dateRanges displayed at the top of the picker.
  final List<QuickDateRange> quickDateRanges;

  /// The initial selected date range.
  final DateRange? initialDateRange;

  /// The maximum length of the selected date range.
  final int? maximumDateRangeLength;

  /// The minimum length of the selected date range.
  final int? minimumDateRangeLength;

  /// The minimum time hour difference between the date range.
  final int minimunHTimeDiff;

  /// Set to true to display two months at a time.
  final bool doubleMonth;

  /// The earliest selectable date.
  final DateTime? minDate;

  /// The latest selectable date.
  final DateTime? maxDate;

  /// The date that is initially displayed when the picker is opened.
  final DateTime? initialDisplayedDate;

  /// The height of the picker.
  final double height;

  /// A list of dates that are disabled and cannot be selected.
  final List<DateTime> disabledDates;

  /// The theme used to customize the appearance of the picker.
  final CalendarTheme theme;

  /// Used to either display or hide the vertical separator between months if [doubleMonth] mode is active
  final bool displayMonthsSeparator;

  /// Thickness of the vertical separator between months if [doubleMonth] mode is active
  final double separatorThickness;

  @override
  State<DateRangePickerWidget> createState() => DateRangePickerWidgetState();
}

class DateRangePickerWidgetState extends State<DateRangePickerWidget> {
  late final controller = RangePickerController(
      dateRange: widget.initialDateRange,
      minDate: widget.minDate,
      maxDate: widget.maxDate,
      onDateRangeChanged: widget.onDateRangeChanged,
      disabledDates: widget.disabledDates,
      minimumDateRangeLength: widget.minimumDateRangeLength,
      maximumDateRangeLength: widget.maximumDateRangeLength,
      minimunHTimeDiff: widget.minimunHTimeDiff);

  late final calendarController = CalendarWidgetController(
    controller: controller,
    currentMonth: widget.initialDisplayedDate ??
        widget.initialDateRange?.start ??
        DateTime.now(),
  );

  late final StreamSubscription subscription;

  @override
  void initState() {
    super.initState();
    subscription = calendarController.updateStream.listen((event) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    super.dispose();
    subscription.cancel();
  }

  @override
  Widget build(BuildContext context) {
    Widget child = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: widget.theme.tileSize * 7 * (widget.doubleMonth ? 2 : 1),
          child: MonthSelectorAndDoubleIndicator(
            doubleMonth: widget.doubleMonth,
            onPrevious: calendarController.previous,
            onNext: calendarController.next,
            currentMonth: calendarController.currentMonth,
            nextMonth: calendarController.nextMonth,
            style: widget.theme.monthTextStyle,
          ),
        ),
        const SizedBox(
          height: 20,
        ),
        IntrinsicHeight(
          child: Row(
            children: [
              EnrichedMonthWrapWidget(
                theme: widget.theme,
                onDateChanged: calendarController.onDateChanged,
                days: calendarController.retrieveDatesForMonth(),
                delta: calendarController.retrieveDeltaForMonth(),
                rangePickerController: controller,
                calendarWidgetController: calendarController,
                use: widget.doubleMonth ? 0 : 2,
              ),
              if (widget.doubleMonth) ...{
                if (widget.displayMonthsSeparator)
                  VerticalDivider(
                    thickness: widget.separatorThickness,
                    color: widget.theme.separatorColor,
                  ),
                EnrichedMonthWrapWidget(
                  theme: widget.theme,
                  onDateChanged: calendarController.onDateChanged,
                  days: calendarController.retrieveDatesForNextMonth(),
                  delta: calendarController.retrieveDeltaForNextMonth(),
                  rangePickerController: controller,
                  calendarWidgetController: calendarController,
                  use: 1,
                ),
              }
            ],
          ),
        ),
      ],
    );

    if (widget.quickDateRanges.isNotEmpty) {
      child = Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 150,
            child: QuickSelectorWidget(
              selectedDateRange: controller.dateRange,
              quickDateRanges: widget.quickDateRanges,
              onDateRangeChanged: (dateRange) {
                calendarController.setDateRange(dateRange);
              },
              theme: widget.theme,
            ),
          ),
          Container(
            color: Colors.black12,
            width: 1,
            height: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 16),
          ),
          child,
          if (widget.quickDateRanges.isNotEmpty)
            const SizedBox(
              width: 16,
            ),
        ],
      );
    }

    return SizedBox(
      height: widget.height,
      child: child,
    );
  }
}

/// A widget that displays a vertical column of days in a month grid, along with the day names row.
class EnrichedMonthWrapWidget extends StatelessWidget {
  EnrichedMonthWrapWidget({
    Key? key,
    required this.theme,
    required this.onDateChanged,
    required this.days,
    required this.delta,
    required this.rangePickerController,
    required this.calendarWidgetController,
    this.minHTimeDiff = 1,
    required this.use,
  }) : super(key: key);

  /// The theme to use for the calendar.
  final CalendarTheme theme;

  /// A callback that is called when the selected date changes.
  final ValueChanged<DateTime> onDateChanged;

  /// The days to display in the month grid.
  final List<DayModel> days;

  /// The number of days to pad at the beginning of the grid.
  final int delta;

  final int use;

  final RangePickerController rangePickerController;

  final CalendarWidgetController calendarWidgetController;

  final int minHTimeDiff;

  final DateFormat dateFormat = DateFormat('yyyy/MM/dd');
  final DateFormat timeFormat = DateFormat('HH:MM:ss');

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: theme.tileSize * 7,
      child: Column(
        children: [
          DayNamesRow(
            textStyle: theme.dayNameTextStyle,
          ),
          const SizedBox(height: 16),
          MonthWrapWidget(
            days: days,
            delta: delta,
            dayTileBuilder: (dayModel) => kDayTileBuilder(
              dayModel,
              theme,
              onDateChanged,
            ),
            placeholderBuilder: (index) => buildPlaceholder(),
          ),
          if (use == 0)
            Row(
              children: [
                getDateFormInput(true),
                getTimeFormInput(true),
              ],
            ),
          if (use == 1)
            Row(
              children: [
                getDateFormInput(false),
                getTimeFormInput(false),
              ],
            ),
          if (use == 2)
            Column(children: [
              Row(
                children: [
                  getDateFormInput(true),
                  getTimeFormInput(true),
                ],
              ),
              const SizedBox(height: 5),
              Row(
                children: [
                  getDateFormInput(false),
                  getTimeFormInput(false),
                ],
              )
            ]),
        ],
      ),
    );
  }

  /// A placeholder widget to use for days that do not exist in the current month.
  SizedBox buildPlaceholder() => SizedBox(
        width: theme.tileSize,
        height: theme.tileSize,
      );

  /// Only supports YYYY/MM/DD format.
  Widget getDateFormInput(bool isStartDate) {
    String label = 'Start date';
    TextEditingController controller = TextEditingController(
        text: rangePickerController.startDate == null
            ? ""
            : dateFormat.format(rangePickerController.startDate!));

    if (!isStartDate) {
      label = 'End date';
      controller = TextEditingController(
          text: rangePickerController.endDate == null
              ? ""
              : dateFormat.format(rangePickerController.endDate!));
    }

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(2),
        child: TextFormField(
          controller: controller,
          key: key,
          decoration: InputDecoration(
              isDense: true,
              border: const OutlineInputBorder(
                borderSide: BorderSide(),
              ),
              errorBorder: const OutlineInputBorder(borderSide: BorderSide()),
              labelText: label,
              hintText: 'YYYY/MM/DD',
              hintStyle: const TextStyle(fontStyle: FontStyle.italic)),
          validator: (startDate) {
            if (startDate == null) {
              return "$label required.";
            }
            try {
              dateFormat.parseStrict(startDate);
            } catch (e) {
              return "Invalid date";
            }
            return null;
          },
          onChanged: (value) {},
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp("[0-9/]")),
            LengthLimitingTextInputFormatter(10),
            DateFormatter(maxYear: rangePickerController.maxDate?.year)
          ],
          onEditingComplete: () {
            _checkDateSelection(isStartDate, controller);
          },
          onTapOutside: (_) {
            //_checkDateSelection(isStartDate, controller);
          },
        ),
      ),
    );
  }

  void _checkDateSelection(bool isStartDate, TextEditingController controller,
      [bool utc = true]) {
    try {
      DateTime latestDt = dateFormat.parseStrict(controller.text, utc);
      final dateRange = rangePickerController.dateRange;
      if (isStartDate) {
        if (rangePickerController.minDate != null &&
            latestDt != rangePickerController.minDate) {
          assert(latestDt.isAfter(rangePickerController.minDate!));
        } else if (dateRange != null) {
          assert(dateRange.end.difference(latestDt) >
              Duration(hours: minHTimeDiff));
        }
        if (calendarWidgetController.controller.endDate != null) {
          assert(
              calendarWidgetController.controller.endDate!.isAfter(latestDt));
          calendarWidgetController.setDateRange(DateRange(
              latestDt, calendarWidgetController.controller.endDate!));
        } else {
          onDateChanged(latestDt);
        }
      } else {
        if (rangePickerController.maxDate != null &&
            latestDt != rangePickerController.maxDate) {
          assert(latestDt.isBefore(rangePickerController.maxDate!));
        } else if (dateRange != null) {
          assert(latestDt.difference(dateRange.start) >
              Duration(hours: minHTimeDiff));
        }
        if (calendarWidgetController.controller.startDate != null) {
          assert(calendarWidgetController.controller.startDate!
              .isBefore(latestDt));
          calendarWidgetController.setDateRange(DateRange(
              calendarWidgetController.controller.startDate!, latestDt));
        } else {
          onDateChanged(latestDt);
        }
      }
    } catch (e) {
      if (isStartDate) {
        controller.text = rangePickerController.prevStartDate == null
            ? ""
            : dateFormat.format(rangePickerController.prevStartDate!);
      } else {
        controller.text = rangePickerController.prevEndDate == null
            ? ""
            : dateFormat.format(rangePickerController.prevEndDate!);
      }
      return;
    }
  }

  void _checkTimeSelection(bool isStartTime, TextEditingController controller) {
    try {
      Duration duration = parseDuration(controller.text);
      final dateRange = rangePickerController.dateRange;
      if (isStartTime) {
        if (dateRange != null) {
          assert(dateRange.end
                  .difference(dateOnly(dateRange.start).add(duration)) >
              Duration(hours: minHTimeDiff));
        }
        rangePickerController.startTime = duration;
      } else {
        if (dateRange != null) {
          assert(dateRange.end
                  .add(duration)
                  .difference(dateOnly(dateRange.start)) >
              Duration(hours: minHTimeDiff));
        }
        rangePickerController.endTime = duration;
      }
    } catch (e) {
      if (isStartTime) {
        controller.text = durationToString(rangePickerController.startTime);
      } else {
        controller.text = durationToString(rangePickerController.endTime);
      }
      return;
    }
  }

  /// Only supports HH:MM:ss format.
  Widget getTimeFormInput(bool isStartTime) {
    String label = 'Start time';
    TextEditingController controller = TextEditingController(
        text: durationToString(rangePickerController.startTime));

    if (!isStartTime) {
      label = 'End time';
      controller = TextEditingController(
          text: rangePickerController.endDate == null
              ? ""
              : durationToString(rangePickerController.endTime));
    }

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(2),
        child: TextFormField(
          key: key,
          controller: controller,
          decoration: InputDecoration(
              isDense: true,
              border: const OutlineInputBorder(
                borderSide: BorderSide(),
              ),
              errorBorder: const OutlineInputBorder(borderSide: BorderSide()),
              labelText: label,
              hintText: '00:00:00',
              hintStyle: const TextStyle(fontStyle: FontStyle.italic)),
          validator: (dateTime) {
            if (dateTime == null) {
              return "$label required.";
            }
            try {
              timeFormat.parseStrict(dateTime);
            } catch (e) {
              return "Invalid time";
            }
            return null;
          },
          onChanged: (value) {},
          enabled: isStartTime
              ? calendarWidgetController.controller.startDate != null
              : calendarWidgetController.controller.endDate != null,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp("[0-9:]")),
            LengthLimitingTextInputFormatter(8),
            TimeFormatter()
          ],
          onEditingComplete: () {
            _checkTimeSelection(isStartTime, controller);
          },
          onTapOutside: (_) {
            _checkTimeSelection(isStartTime, controller);
          },
        ),
      ),
    );
  }
}
