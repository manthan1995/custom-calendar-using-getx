import 'dart:async';

import 'package:calender_demo/app/constant/LocalColors.dart';
import 'package:calender_demo/app/modules/home/model/WeekData.dart';
import 'package:calender_demo/app/widget/scroll/src/scrollable_positioned_list.dart';
import 'package:calender_demo/app/widget/segment/src/widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class HomeView extends StatefulWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  RxInt initialValue = 1.obs;
  RxList allDates = [].obs;
  RxList weekDates = [].obs;
  RxList monthDates = [].obs;
  ItemScrollController itemScrollController = ItemScrollController();
  ItemScrollController itemWeekScrollController = ItemScrollController();
  ItemScrollController itemMonthScrollController = ItemScrollController();
  var curIndex = 0;
  RxInt selIndex = (-1).obs;
  var curWeekIndex = 0;
  RxInt selWeekIndex = (-1).obs;
  var curMonthIndex = 0;
  RxInt selMonthIndex = (-1).obs;
  var isFirst = false;

  @override
  void initState() {
    super.initState();
    DateTime startDate = DateTime(DateTime.now().year - 100, 1, 1, 0, 0, 0, 0);
    DateTime endDate = DateTime(DateTime.now().year + 100, 12, 31, 0, 0, 0, 0);
    getAllDatesBetween(startDate, endDate);
    getWeeksBetween(startDate, endDate);
    getMonthsBetween(startDate, endDate);
  }

  void getAllDatesBetween(DateTime startDate, DateTime endDate) {
    List<DateTime> dates = [];
    DateTime currentDate = startDate;
    while (currentDate.isBefore(endDate) ||
        currentDate.isAtSameMomentAs(endDate)) {
      dates.add(currentDate);
      if (DateFormat("d MM yyyy", "en_US").format(currentDate).toUpperCase() ==
          DateFormat("d MM yyyy", "en_US")
              .format(DateTime.now())
              .toUpperCase()) {
        curIndex = dates.indexOf(currentDate);
      }
      currentDate = currentDate.add(const Duration(days: 1));
    }
    allDates.value = dates;
    Timer(const Duration(milliseconds: 20), () {
      _animateToIndex(curIndex);
      setState(() {});
    });
  }

  void getWeeksBetween(DateTime startDate, DateTime endDate) {
    List<WeekData> weeks = [];
    var week = 1;
    int weekday = startDate.weekday;
    int daysSinceMonday = (weekday + 6) % 7;
    startDate = startDate.subtract(Duration(days: daysSinceMonday + 1));
    DateTime currentDay = startDate;
    DateTime lastDayOfWeek =
        DateTime(startDate.year, startDate.month, startDate.day + 6);
    while (
        currentDay.isBefore(endDate) || currentDay.isAtSameMomentAs(endDate)) {
      var list = getWeekDates(currentDay, lastDayOfWeek, weeks);
      var firstDates = list
          .where((element) =>
              DateFormat("d", "en_US").format(element).toUpperCase() == "1")
          .toList();
      if (firstDates.isNotEmpty) {
        if (DateFormat("d MM", "en_US").format(firstDates[0]) == "1 01") {
          week = 1;
        }
      }
      var weekData = WeekData(
          "W$week",
          list,
          "${DateFormat("d", "en_US").format(list.first).toUpperCase()}-${DateFormat("d", "en_US").format(list.last).toUpperCase()}",
          firstDates.isNotEmpty
              ? DateFormat("MMM, yyyy", "en_US").format(firstDates[0])
              : "");
      weeks.add(weekData);
      currentDay = lastDayOfWeek.add(const Duration(days: 1));
      week++;
      lastDayOfWeek =
          DateTime(currentDay.year, currentDay.month, currentDay.day + 6);
    }
    weekDates.value = weeks;
  }

  List<DateTime> getWeekDates(
      DateTime startDate, DateTime endDate, List<WeekData> weeks) {
    List<DateTime> weekDates = [];
    DateTime currentDay = startDate;
    while (
        currentDay.isBefore(endDate) || currentDay.isAtSameMomentAs(endDate)) {
      weekDates.add(currentDay);
      if (DateFormat("d MM yyyy", "en_US").format(currentDay).toUpperCase() ==
          DateFormat("d MM yyyy", "en_US")
              .format(DateTime.now())
              .toUpperCase()) {
        var count = weeks.length;
        curWeekIndex = count;
      }
      currentDay = currentDay.add(const Duration(days: 1));
    }
    return weekDates;
  }

  void getMonthsBetween(DateTime startDate, DateTime endDate) {
    List<DateTime> months = [];
    DateTime currentMonth = DateTime(startDate.year, startDate.month);

    while (currentMonth.isBefore(endDate) ||
        currentMonth.isAtSameMomentAs(endDate)) {
      months.add(currentMonth);
      if (DateFormat("MM yyyy", "en_US").format(currentMonth).toUpperCase() ==
          DateFormat("MM yyyy", "en_US").format(DateTime.now()).toUpperCase()) {
        curMonthIndex = months.indexOf(currentMonth);
      }
      currentMonth = DateTime(
          currentMonth.year + (currentMonth.month == 12 ? 1 : 0),
          (currentMonth.month % 12) + 1);
    }
    monthDates.value = months;
  }

  void _animateToIndex(int index) {
    itemScrollController.jumpTo(index: index, alignment: 0.41);
  }

  void _animateWeekToIndex(int index) {
    itemWeekScrollController.jumpTo(index: index, alignment: 0.41);
  }

  void _animateMonthToIndex(int index) {
    itemMonthScrollController.jumpTo(index: index, alignment: 0.41);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: whiteColor,
      child: SafeArea(
        child: Column(
          children: [
            Obx(
              () => Container(
                width: Get.width,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Icon(
                      Icons.arrow_back_ios,
                      color: blackColor,
                    ),
                    Flexible(
                      flex: 1,
                      child: Container(
                        alignment: Alignment.center,
                        child: CustomSlidingSegmentedControl<int>(
                          initialValue: initialValue.value,
                          height: 30,
                          children: {
                            1: Text(
                              'Daily',
                              style: TextStyle(
                                fontSize: 12,
                                color: blackColor,
                                decoration: TextDecoration.none,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            2: Text(
                              'Weekly',
                              style: TextStyle(
                                fontSize: 12,
                                color: blackColor,
                                decoration: TextDecoration.none,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            3: Text(
                              'Monthly',
                              style: TextStyle(
                                fontSize: 12,
                                color: blackColor,
                                decoration: TextDecoration.none,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          },
                          decoration: BoxDecoration(
                            color: CupertinoColors.lightBackgroundGray,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          thumbDecoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInToLinear,
                          onValueChanged: (v) {
                            initialValue.value = v;
                            Timer(const Duration(milliseconds: 20), () {
                              if (initialValue.value == 1) {
                                _animateToIndex(selIndex.value == -1
                                    ? curIndex
                                    : selIndex.value);
                              } else if (initialValue.value == 2) {
                                _animateWeekToIndex(selWeekIndex.value == -1
                                    ? curWeekIndex
                                    : selWeekIndex.value);
                              } else if (initialValue.value == 3) {
                                _animateMonthToIndex(selMonthIndex.value == -1
                                    ? curMonthIndex
                                    : selMonthIndex.value);
                              }
                            });
                          },
                        ),
                      ),
                    ),
                    Icon(
                      Icons.calendar_today,
                      color: blackColor,
                    ),
                  ],
                ),
              ),
            ),
            Obx(
              () => Visibility(
                visible: initialValue.value == 1,
                child: Obx(
                  () => SizedBox(
                    height: 70,
                    child: ScrollablePositionedList.builder(
                      itemCount: allDates.length,
                      shrinkWrap: true,
                      scrollDirection: Axis.horizontal,
                      itemScrollController: itemScrollController,
                      itemBuilder: (context, index) {
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            GestureDetector(
                              onTap: () {
                                selIndex.value = index;
                                setState(() {});
                              },
                              child: Container(
                                width: 50,
                                height: 50,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: selIndex.value == index
                                      ? Colors.green
                                      : curIndex > index
                                          ? CupertinoColors.lightBackgroundGray
                                          : curIndex == index
                                              ? themeColor
                                              : Colors.transparent,
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(10),
                                  ),
                                ),
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 5),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      DateFormat("d", "en_US")
                                          .format(allDates[index])
                                          .toUpperCase(),
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: selIndex.value == index
                                            ? Colors.white
                                            : curIndex > index
                                                ? blackColor
                                                : curIndex == index
                                                    ? whiteColor
                                                    : CupertinoColors
                                                        .lightBackgroundGray,
                                        decoration: TextDecoration.none,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 4,
                                    ),
                                    Text(
                                      DateFormat("EEE", "en_US")
                                          .format(allDates[index])
                                          .toUpperCase(),
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: selIndex.value == index
                                            ? Colors.white
                                            : curIndex > index
                                                ? blackColor
                                                : curIndex == index
                                                    ? whiteColor
                                                    : CupertinoColors
                                                        .lightBackgroundGray,
                                        decoration: TextDecoration.none,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 6,
                            ),
                            DateFormat("d", "en_US")
                                        .format(allDates[index])
                                        .toUpperCase() ==
                                    "1"
                                ? Container(
                                    height: 10,
                                    width: 50,
                                    alignment: Alignment.center,
                                    color: Colors.red,
                                    child: Text(
                                      DateFormat("MMM, yyyy", "en_US")
                                          .format(allDates[index])
                                          .toUpperCase(),
                                      style: TextStyle(
                                        fontSize: 8,
                                        color: whiteColor,
                                        decoration: TextDecoration.none,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  )
                                : const SizedBox(
                                    height: 10,
                                  ),
                            Container(
                              height: 1,
                              width: 60,
                              color: Colors.red,
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
            Obx(
              () => Visibility(
                visible: initialValue.value == 2,
                child: Obx(
                  () => SizedBox(
                    height: 70,
                    child: ScrollablePositionedList.builder(
                      itemCount: weekDates.length,
                      shrinkWrap: true,
                      scrollDirection: Axis.horizontal,
                      itemScrollController: itemWeekScrollController,
                      itemBuilder: (context, index) {
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            GestureDetector(
                              onTap: () {
                                selWeekIndex.value = index;
                                setState(() {});
                              },
                              child: Container(
                                width: 50,
                                height: 50,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: selWeekIndex.value == index
                                      ? Colors.green
                                      : curWeekIndex > index
                                          ? CupertinoColors.lightBackgroundGray
                                          : curWeekIndex == index
                                              ? themeColor
                                              : Colors.transparent,
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(10),
                                  ),
                                ),
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 5),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      weekDates[index].name,
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: selWeekIndex.value == index
                                            ? Colors.white
                                            : curWeekIndex > index
                                                ? blackColor
                                                : curWeekIndex == index
                                                    ? whiteColor
                                                    : CupertinoColors
                                                        .lightBackgroundGray,
                                        decoration: TextDecoration.none,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 4,
                                    ),
                                    Text(
                                      weekDates[index].daysDiff,
                                      style: TextStyle(
                                          fontSize: 10,
                                          color: selWeekIndex.value == index
                                              ? Colors.white
                                              : curWeekIndex > index
                                                  ? blackColor
                                                  : curWeekIndex == index
                                                      ? whiteColor
                                                      : CupertinoColors
                                                          .lightBackgroundGray,
                                          decoration: TextDecoration.none,
                                          fontWeight: FontWeight.w400,
                                          letterSpacing: -1),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 6,
                            ),
                            weekDates[index].month.isNotEmpty
                                ? Container(
                                    height: 10,
                                    width: 50,
                                    alignment: Alignment.center,
                                    color: Colors.red,
                                    child: Text(
                                      weekDates[index].month,
                                      style: TextStyle(
                                        fontSize: 8,
                                        color: whiteColor,
                                        decoration: TextDecoration.none,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  )
                                : const SizedBox(
                                    height: 10,
                                  ),
                            Container(
                              height: 1,
                              width: 60,
                              color: Colors.red,
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
            Obx(
              () => Visibility(
                visible: initialValue.value == 3,
                child: Obx(
                  () => SizedBox(
                    height: 70,
                    child: ScrollablePositionedList.builder(
                      itemCount: monthDates.length,
                      shrinkWrap: true,
                      scrollDirection: Axis.horizontal,
                      itemScrollController: itemMonthScrollController,
                      itemBuilder: (context, index) {
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            GestureDetector(
                              onTap: () {
                                selMonthIndex.value = index;
                                setState(() {});
                              },
                              child: Container(
                                width: 50,
                                height: 50,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: selMonthIndex.value == index
                                      ? Colors.green
                                      : curMonthIndex > index
                                          ? CupertinoColors.lightBackgroundGray
                                          : curMonthIndex == index
                                              ? themeColor
                                              : Colors.transparent,
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(10),
                                  ),
                                ),
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 5),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      DateFormat("MMM", "en_US")
                                          .format(monthDates[index])
                                          .toUpperCase(),
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: selMonthIndex.value == index
                                            ? Colors.white
                                            : curMonthIndex > index
                                                ? blackColor
                                                : curMonthIndex == index
                                                    ? whiteColor
                                                    : CupertinoColors
                                                        .lightBackgroundGray,
                                        decoration: TextDecoration.none,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 4,
                                    ),
                                    Text(
                                      "${DateFormat("d", "en_US").format(DateTime(monthDates[index].year, monthDates[index].month, 1)).toUpperCase()}-${DateFormat("d", "en_US").format(DateTime(monthDates[index].year, monthDates[index].month + 1, 1).subtract(const Duration(days: 1))).toUpperCase()}",
                                      style: TextStyle(
                                          fontSize: 10,
                                          color: selMonthIndex.value == index
                                              ? Colors.white
                                              : curMonthIndex > index
                                                  ? blackColor
                                                  : curMonthIndex == index
                                                      ? whiteColor
                                                      : CupertinoColors
                                                          .lightBackgroundGray,
                                          decoration: TextDecoration.none,
                                          fontWeight: FontWeight.w400,
                                          letterSpacing: -1),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 6,
                            ),
                            DateFormat("M", "en_US")
                                        .format(monthDates[index])
                                        .toUpperCase() ==
                                    "1"
                                ? Container(
                                    height: 10,
                                    width: 50,
                                    alignment: Alignment.center,
                                    color: Colors.red,
                                    child: Text(
                                      DateFormat("yyyy", "en_US")
                                          .format(monthDates[index])
                                          .toUpperCase(),
                                      style: TextStyle(
                                        fontSize: 8,
                                        color: whiteColor,
                                        decoration: TextDecoration.none,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  )
                                : const SizedBox(
                                    height: 10,
                                  ),
                            Container(
                              height: 1,
                              width: 60,
                              color: Colors.red,
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
