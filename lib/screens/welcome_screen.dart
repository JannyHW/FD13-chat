import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'registration_screen.dart';
import 'package:fd13/components/rounded_button.dart';


class WelcomeScreen extends StatefulWidget {
  //using "id" for minimize error for typing string""
  //"id" here/top for globle access
  //adding "Static" as Modifier for this varble (id), so it's now associated with the class varble.]
  //instead of writing "WelcomeScreen().id", with Static, turning to "WelcomeScreen.id" directly (no longer creating a new object)
  static const String id = 'welcome_screen';

  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  //1. creating animation controller for a custom animation
  AnimationController controllerV;
  Animation animationV;

  //2. then, override initState with controller
  @override
  void initState() {
    super.initState();
    controllerV = AnimationController(
        duration: Duration(seconds: 2),
        //tickerProvider : state() With Mixin
        vsync: this);

    animationV = ColorTween(begin: Colors.grey[300], end: Colors.white).animate(controllerV);
    controllerV.forward();
    controllerV.addListener(() {
      setState(() {});
      //value change is useful for animation
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: animationV.value,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(left: 35.0),
              child: Row(
                children: <Widget>[
                  //Beginning: Hero animation with height = 60
                  Hero(
                    tag: "logo",
                    child: Container(
                      child: Image.asset('images/logo.png'),
                      height: 60.0,
                    ),
                  ),
                  Text("Let's Chat",
                      style: TextStyle(
                      fontSize: 45.0,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF28527a),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 48.0,
            ),
            RoundedButton(
              title: 'Log In',
              colour: Color(0xFF8ac4d0),
              onPressed: () {
                Navigator.pushNamed(context, LoginScreen.id);
              },
            ),
            RoundedButton(
              title: 'Register',
              colour: Color(0xFF28527a),
              onPressed: () {
                Navigator.pushNamed(context, RegistrationScreen.id);
              },
            ),
          ],
        ),
      ),
    );
  }
}
