import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Widgets/change_theme_button_widget.dart';
import '../Theme/theme_provider.dart';

class TestTheme extends StatefulWidget {
  TestTheme({required Key key, required this.title}) : super(key: key);
  final String title;

  @override
  _TestThemeState createState() => _TestThemeState();
}

class _TestThemeState extends State<TestTheme> {
  @override
  Widget build(BuildContext context) {
    final themeText =
        Provider.of<ThemeProvider>(context).themeMode == ThemeMode.light
            ? 'Light Theme'
            : 'Dark Theme';

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              Container(
                color: Theme.of(context).colorScheme.secondary,
                child: Text(
                  'Text with a background color',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              ChangeThemeButtonWidget(),
              Text(
                "App Theme $themeText",
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              Text(
                "headline1",
                style: Theme.of(context).textTheme.displayLarge,
              ),
              Text(
                "headline2",
                style: Theme.of(context).textTheme.displayMedium,
              ),
              Text(
                "headline3",
                style: Theme.of(context).textTheme.displaySmall,
              ),
              Text(
                "headline4",
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              Text(
                "headline5",
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              Text(
                "headline6",
                style: Theme.of(context).textTheme.titleLarge,
              ),
              Text(
                "bodyText1",
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              Text(
                "bodyText2",
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              SizedBox(
                height: 50.0,
              ),
              Image.asset(
                'assets/logos/trashpick_logo_curved.png',
                scale: 5.0,
              ),
              SizedBox(
                height: 20.0,
              ),
              Image.asset(
                'assets/logos/trashpick_logo_round.png',
                scale: 5.0,
              ),
              SizedBox(
                height: 20.0,
              ),
              Image.asset(
                'assets/logos/trashpick_logo_square.png',
                scale: 5.0,
              ),
              SizedBox(
                height: 50.0,
              ),
              Text(
                "PrimaryColor - Green",
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              Container(
                height: 50.0,
                width: MediaQuery.of(context).size.width,
                color: Theme.of(context).primaryColor,
              ),
              Text(
                "SecondaryColor",
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              Container(
                height: 50.0,
                width: MediaQuery.of(context).size.width,
                color: Theme.of(context).colorScheme.background,
              ),
              Text(
                "AccentColor",
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              Container(
                height: 50.0,
                width: MediaQuery.of(context).size.width,
                color: Theme.of(context).colorScheme.secondary,
              ),
              Text(
                "RedColor",
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              Container(
                height: 50.0,
                width: MediaQuery.of(context).size.width,
                color: AppThemeData().redColor,
              ),
              Text(
                "BlueColor",
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              Container(
                height: 50.0,
                width: MediaQuery.of(context).size.width,
                color: AppThemeData().blueColor,
              ),
              Text(
                "YellowColor",
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              Container(
                height: 50.0,
                width: MediaQuery.of(context).size.width,
                color: AppThemeData().yellowColor,
              ),
              Text(
                "WhiteColor",
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              Container(
                height: 50.0,
                width: MediaQuery.of(context).size.width,
                color: AppThemeData().whiteColor,
              ),
              Text(
                "GreyColor",
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              Container(
                height: 50.0,
                width: MediaQuery.of(context).size.width,
                color: AppThemeData().greyColor,
              )
            ],
          ),
        ),
      ),
    );
  }
}
