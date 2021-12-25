import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:star_metter/config/colors.dart';
import 'package:star_metter/models/progress.dart';
import 'package:star_metter/models/star.dart';
import 'package:star_metter/models/user.dart';
import 'package:star_metter/models/weight.dart';
import 'package:star_metter/services/stars.dart';
import 'package:star_metter/services/weight.dart';
import 'package:star_metter/widgets/chart.dart';
import 'package:star_metter/widgets/counter_button.dart';
import 'package:star_metter/widgets/custom_button.dart';
import 'package:star_metter/widgets/custom_dialog.dart';
import 'package:star_metter/widgets/weight_card.dart';

import '../widgets/page_builder.dart';

class Home extends StatefulWidget {
  final User user;
  final Progress progress;
  final Function? showMenu;

  const Home({
    Key? key,
    required this.showMenu,
    required this.user,
    required this.progress,
  }) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  StarsService starsService = StarsService();
  late User user;
  late Progress progress;

  @override
  void initState() {
    super.initState();
    user = widget.user;
    progress = widget.progress;
  }

  Widget starCounter() {
    Star stars = progress.star;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 42),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CounterButton(
            onClick: () async {
              if (stars.stars > 0) {
                bool update = await starsService.updateStars(
                    recordId: stars.id!, stars: stars.stars - 1);
                if (update) {
                  setState(() {
                    if (progress.starProgress.isNotEmpty) {
                      progress.starProgress.last.stars = stars.stars - 1;
                    }
                    stars.stars = stars.stars - 1;
                  });
                }
              }
            },
            icon: Icons.remove,
            isDisabled: stars.stars == 0,
          ),
          Column(
            children: [
              Icon(
                Icons.star_border,
                size: 64,
                color: stars.stars < stars.progressLimit - 2
                    ? Nord.light
                    : stars.stars > stars.progressLimit + 2
                        ? Nord.auroraRed
                        : Nord.auroraGreen,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 60,
                    width: 60,
                    child: Text(
                      '${stars.stars < 10 ? "0" : ""}${stars.stars}',
                      style: TextStyle(
                        fontSize: 42,
                        fontWeight: FontWeight.bold,
                        color: stars.stars < stars.progressLimit - 2
                            ? Nord.light
                            : stars.stars > stars.progressLimit + 2
                                ? Nord.auroraRed
                                : Nord.auroraGreen,
                      ),
                      textAlign: TextAlign.end,
                    ),
                  ),
                  SizedBox(
                      height: 40,
                      width: 40,
                      child: Text(
                        '/${stars.progressLimit}',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.normal,
                          color: Nord.light,
                        ),
                      ))
                ],
              )
            ],
          ),
          CounterButton(
            onClick: () async {
              if (stars.stars < 99) {
                bool update = await starsService.updateStars(
                    recordId: stars.id!, stars: stars.stars + 1);
                if (update) {
                  setState(() {
                    if (progress.starProgress.isNotEmpty) {
                      progress.starProgress.last.stars = stars.stars + 1;
                    }
                    stars.stars = stars.stars + 1;
                  });
                }
              }
            },
            icon: Icons.add,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PageBuilder(
      isAppBar: true,
      onBack: widget.showMenu,
      page: Padding(
        padding: const EdgeInsets.only(top: 82.0, bottom: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(bottom: 14.0),
              child: Text(
                'Today:',
                style: TextStyle(
                  fontSize: 64,
                  fontWeight: FontWeight.bold,
                  color: Nord.light,
                ),
                textAlign: TextAlign.start,
              ),
            ),
            starCounter(),
            Chart(
              stars: progress.starProgress,
              initialLimit: progress.starProgress.isNotEmpty
                  ? progress.starProgress.last.progressLimit
                  : progress.star.progressLimit,
            ),
            const Padding(
              padding: EdgeInsets.only(top: 42.0),
              child: Text(
                'Weight:',
                style: TextStyle(
                  fontSize: 44,
                  fontWeight: FontWeight.bold,
                  color: Nord.light,
                ),
                textAlign: TextAlign.start,
              ),
            ),
            WeightCard(
              padding: const EdgeInsets.only(top: 24, bottom: 32),
              currentWeight: progress.weight.weight,
              date: progress.weight.date,
              previousWeight: progress.prevWeight?.weight,
              previousDate: progress.prevWeight?.date,
              bmi: (progress.weight.weight /
                  ((user.height / 100) * (user.height / 100))),
            ),
            Center(
              child: SizedBox(
                width: 240,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                    primary: Nord.auroraGreen,
                    padding: const EdgeInsets.symmetric(
                      vertical: 15,
                    ),
                  ),
                  onPressed: () async {
                    String initValue = progress.weight.weight.toString();

                    String? result = await CustomDialog().showTextDialog(
                      context: context,
                      header: "New weight",
                      confirmText: "Confirm",
                      declineText: "Cancel",
                      dialogBody: "test",
                      initValue: initValue,
                    );

                    if (result != null && result != initValue) {
                      double value = double.parse(result);
                      int? id = progress.weight.id;

                      if (id != null) {
                        setState(
                          () => progress.weight.weight = value,
                        );

                        WeightService()
                            .updateWeight(recordId: id, weight: value);
                      }
                    }
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: const [
                      Text('Update weight'),
                      Icon(
                        Icons.add,
                        size: 32,
                        color: Nord.light,
                      ),
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
