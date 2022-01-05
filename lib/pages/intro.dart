import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

import '../../blocs/home/home_bloc.dart';
import '../../config/colors.dart';
import '../../models/models.dart';
import '../../pages/pages.dart';
import '../../widgets/widgets.dart';

class Intro extends StatefulWidget {
  final Function() handlePage;
  final bool isInit;

  const Intro({
    Key? key,
    required this.handlePage,
    required this.isInit,
  }) : super(key: key);

  @override
  _IntroState createState() => _IntroState();
}

class _IntroState extends State<Intro> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final validator = Validator();

  int _step = 1;
  Sex? _sex;
  double _activityLevel = 3;
  List<String> headers = [
    'Sick / Mostly laying',
    'Low / Office work',
    'Medium / 2-3 trainings/week',
    'Above avarege / 3-4 trainings/week',
    'High / Physical worker / Proffesional'
  ];
  int stars = 0;
  int result = 0;

  late TextEditingController name;
  late TextEditingController age;
  late TextEditingController height;
  late TextEditingController weight;
  late TextEditingController targetWeight;

  @override
  void initState() {
    super.initState();
    name = TextEditingController(text: '');
    age = TextEditingController(text: '18');
    height = TextEditingController(text: '175.0');
    weight = TextEditingController(text: '95.0');
    targetWeight = TextEditingController(text: '85.0');
  }

  double ppmMale(double weight, double height, int age) {
    // Harris-Benedict
    return 66 + (13.7 * weight) + (5 * height) - (6.76 * age);
  }

  double ppmFemale(double weight, double height, int age) {
    // Harris-Benedict
    return 655 + (9.6 * weight) + (1.8 * height) - (4.7 * age);
  }

  int countStars() {
    int _age = int.parse(age.text);
    double _height = double.parse(height.text);
    double _weight = double.parse(weight.text);
    int _activity = _activityLevel.toInt();

    double ppm = _sex == Sex.male
        ? ppmMale(_weight, _height, _age)
        : ppmFemale(_weight, _height, _age);

    List pal = [null, 1.2, 1.25, 1.5, 1.75, 2.0];

    double cpm = ppm * pal[_activity];
    return (cpm / 100).ceil();
  }

  String parseEnum(dynamic en) {
    return en.toString().split('.').last;
  }

  Widget tileButton({
    required IconData icon,
    required Function() onTap,
    required bool isActive,
    required String text,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            width: 2,
            color: isActive ? Nord.auroraGreen : Nord.lightDark,
          ),
          // color: isActive ? Nord.dark : Nord.darkMedium,
          borderRadius: const BorderRadius.all(Radius.circular(8)),
        ),
        width: 150,
        height: 150,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Icon(
              icon,
              size: 72,
              color: isActive ? Nord.auroraGreen : Nord.lightDark,
            ),
            Text(
              text,
              style: const TextStyle(
                color: Nord.lightDark,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget step1() {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height * 0.7,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Gender:',
            style: Theme.of(context)
                .textTheme
                .headline1!
                .copyWith(fontWeight: FontWeight.w200),
            textAlign: TextAlign.center,
          ),
          Wrap(
            alignment: WrapAlignment.center,
            runSpacing: 15,
            spacing: 15,
            children: [
              tileButton(
                icon: Icons.female,
                onTap: () => setState(() => _sex = Sex.female),
                isActive: _sex == Sex.female,
                text: "Female",
              ),
              tileButton(
                icon: Icons.male,
                onTap: () => setState(() => _sex = Sex.male),
                isActive: _sex == Sex.male,
                text: "Male",
              ),
            ],
          ),
          CustomButton(
            isDisabled: _sex == null,
            onPressed: () {
              if (_sex != null) {
                setState(() => _step = 2);
              }
            },
          )
        ],
      ),
    );
  }

  Widget step2() {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height * 0.9,
      margin: const EdgeInsets.only(top: 54),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text(
              'Your data:',
              style: Theme.of(context)
                  .textTheme
                  .headline1!
                  .copyWith(fontWeight: FontWeight.w200),
              textAlign: TextAlign.center,
            ),
            Input(
              controller: name,
              validation: validator.nameValidation,
              labelText: 'Name',
            ),
            Input(
              controller: age,
              keyboardType: TextInputType.number,
              validation: validator.ageValidation,
              labelText: 'Age',
            ),
            Input(
              controller: height,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              validation: validator.heightValidation,
              labelText: 'Height (cm)',
              inputFormatters: [validator.digitFormatter],
            ),
            Input(
              controller: weight,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              validation: validator.weightValidation,
              labelText: 'Weight (kg)',
              inputFormatters: [validator.digitFormatter],
            ),
            Input(
              controller: targetWeight,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              validation: validator.weightValidation,
              labelText: 'Target (kg)',
              inputFormatters: [validator.digitFormatter],
            ),
            CustomButton(
              isDisabled: false,
              onPressed: () {
                final FormState? form = _formKey.currentState;
                if (form!.validate()) {
                  setState(() => _step = 3);
                }
              },
            )
          ],
        ),
      ),
    );
  }

  Widget step3() {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height * 0.7,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text(
            'Activity:',
            style: Theme.of(context)
                .textTheme
                .headline1!
                .copyWith(fontWeight: FontWeight.w200),
            textAlign: TextAlign.center,
          ),
          Lottie.asset(
            'assets/lotties/activity.json',
            width: 150,
            height: 150,
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: CustomSlider(
              value: _activityLevel,
              header: headers[_activityLevel.round() - 1],
              onChanged: (double value) {
                setState(() => _activityLevel = value);
              },
            ),
          ),
          CustomButton(
            text: 'Go to summary',
            isDisabled: false,
            onPressed: () {
              int _stars = countStars();
              setState(() {
                stars = _stars;
                result = _stars;
              });

              Future.delayed(
                const Duration(milliseconds: 500),
                () => setState(() => _step = 4),
              );
            },
          )
        ],
      ),
    );
  }

  Widget step4() {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height * 0.7,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text(
            'Your plan:',
            style: Theme.of(context)
                .textTheme
                .headline1!
                .copyWith(fontWeight: FontWeight.w200),
            textAlign: TextAlign.center,
          ),
          Column(
            children: [
              const Icon(
                Icons.star_border,
                size: 122,
                color: Nord.auroraGreen,
              ),
              Text(
                result.toString(),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Nord.light,
                  fontSize: 32,
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: CustomSlider(
              value: result.toDouble(),
              header: '${(result - stars) * 100}g/week',
              onChanged: (double value) {
                setState(() {
                  result = value.toInt();
                });
              },
              min: stars - 10,
              max: stars + 10,
              divisions: 20,
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(24.0),
            child: Text(
              'Reminder: Each star equals to 100 kcal. Remember about your healt! Do not rush - diet should not be a suffering!',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Nord.lightMedium,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          CustomButton(
              text: 'Proceed to App',
              isDisabled: false,
              onPressed: () {
                DateTime now = DateTime.now();
                DateParser dateParser = DateParser(date: now);

                User user = User(
                  name: name.text,
                  age: int.parse(age.text),
                  height: double.parse(height.text),
                  initWeight: double.parse(weight.text),
                  targetWeight: double.parse(targetWeight.text),
                  stars: result,
                  gender: parseEnum(_sex),
                  activityLevel: parseEnum(_activityLevel),
                  initDate: dateParser.getDateWithoutTime(),
                );

                widget.handlePage();
                BlocProvider.of<HomeBloc>(context)
                    .add(HomeLoadPage(user: user));
              })
        ],
      ),
    );
  }

  Widget _question(int step) {
    switch (step) {
      case 1:
        return step1();
      case 2:
        return step2();
      case 3:
        return step3();
      case 4:
        return step4();
      default:
        return const Loading();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PageBuilder(
      page: _question(_step),
      isAppBar: _step > 1 || !widget.isInit,
      isBack: true,
      onBack: () {
        if (widget.isInit) {
          setState(() => _step = _step - 1);
        } else {
          BlocProvider.of<HomeBloc>(context).add(
            HomeLoadInit(
              handlePage: widget.handlePage,
            ),
          );
        }
      },
    );
  }
}
