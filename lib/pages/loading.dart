import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:lottie/lottie.dart';

import '../config/colors.dart';
import './../widgets/widgets.dart';

class Loading extends StatefulWidget {
  final bool isHeader;

  const Loading({Key? key, this.isHeader = false}) : super(key: key);

  @override
  _LoadingState createState() => _LoadingState();
}

class _LoadingState extends State<Loading> {
  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        color: Nord.darkMedium,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Lottie.asset(
              'assets/lotties/loading.json',
              width: MediaQuery.of(context).size.width * 0.9,
              height: MediaQuery.of(context).size.width * 0.9,
            ),
            Column(
              children: [
                Header(isHeader: widget.isHeader),
              ],
            ),
            Column(
              children: [
                Container(),
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: 50,
                  color: Nord.auroraYellow,
                ),
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: 50,
                  color: Nord.auroraGreen,
                ),
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: 50,
                  color: Nord.auroraRed,
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
