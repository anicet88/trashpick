// ignore_for_file: unused_import

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:trashpick/Pages/BottomNavBar/bottom_nav_bar.dart';
import 'package:trashpick/Pages/OnAppStart/sign_up_page.dart';
import 'package:trashpick/Pages/OnAppStart/welcome_page.dart';
import '../../Theme/theme_provider.dart';
import '../../Widgets/button_widgets.dart';
import '../../Widgets/toast_messages.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'user_guide.dart';

class SignInPage extends StatefulWidget {
  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  ToastMessages _toastMessages = new ToastMessages();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool _isHidden = true;
  bool isUserSigned = false;
  bool isInValidaAccount = false;
  double? circularProgressVal;
  FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  late String accountType;

  void _togglePasswordView() {
    setState(() {
      _isHidden = !_isHidden;
    });
  }

  showAlertDialog(BuildContext context) {
    // show the dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: !isUserSigned
                  ? Center(child: Text("Se connecter"))
                  : Center(child: Text("Bienvenue à nouveau!")),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!isUserSigned)
                    !isInValidaAccount
                        ? Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                height: 30.0,
                              ),
                              CircularProgressIndicator(
                                value: circularProgressVal,
                                strokeWidth: 6,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    AppThemeData().primaryColor),
                              ),
                              SizedBox(
                                height: 30.0,
                              ),
                              Text("Connexion à votre compte...",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 16.0)
                                      .copyWith(color: Colors.grey.shade900)),
                            ],
                          )
                        : Container(
                            child: Column(
                            children: [
                              Text("Erreur!",
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  )),
                              SizedBox(
                                height: 50.0,
                              ),
                              new ButtonWidget(
                                  text: "Réessayez",
                                  color: AppThemeData().redColor,
                                  textColor: AppThemeData().whiteColor,
                                  onClicked: () {
                                    setState(() {
                                      isUserSigned = false;
                                      isInValidaAccount = false;
                                      Navigator.pop(context);
                                    });
                                  }),
                            ],
                          ))
                  else
                    Container(
                        child: Column(
                      children: [
                        Text("Bienvenue!",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            )),
                        SizedBox(
                          height: 50.0,
                        ),
                        Image.asset(
                          'assets/images/welcome.png',
                          height: 100,
                          width: 100,
                        ),
                        SizedBox(
                          height: 50.0,
                        ),
                        new ButtonWidget(
                            text: "Continuer",
                            textColor: AppThemeData().whiteColor,
                            color: AppThemeData().primaryColor,
                            onClicked: () {
                              Navigator.pop(context);
                            }),
                      ],
                    )),
                ],
              ),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20.0))),
            );
          },
        );
      },
    );
  }

  void ifAnError() {
    Navigator.pop(context);
    setState(() {
      isUserSigned = false;
      isInValidaAccount = true;
      //Navigator.pop(context);
      showAlertDialog(context);
    });
  }

  bool validateUser() {
    const pattern = r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$';
    final regExp = RegExp(pattern);

    if (emailController.text.isEmpty && passwordController.text.isEmpty) {
      _toastMessages.toastInfo('Veuillez remplir les informations', context);
    } else if (emailController.text.isEmpty) {
      _toastMessages.toastInfo('L\'email est vide', context);
    } else if (!regExp.hasMatch(emailController.text)) {
      _toastMessages.toastInfo('Format de l\'email non respecté', context);
    } else if (passwordController.text.isEmpty) {
      _toastMessages.toastInfo('Mot de passe vide', context);
    } else {
      print('Validation Success!');
      return true;
    }

    return false;
  }

  geAccountType(String userID) async {
    print("----------------------- CHECK ACCOUNT TYPE -----------------------");
    await FirebaseFirestore.instance
        .collection('Users')
        .doc(userID)
        .get()
        .then((value) {
      accountType = value.data()?["accountType"];
    });
  }

  void _signInWithEmailAndPassword() async {
    showAlertDialog(context);

    setState(() {
      isUserSigned = false;
      isInValidaAccount = false;
    });

    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
              email: emailController.text, password: passwordController.text);
      print(userCredential.user!.uid.toString());
      await geAccountType(userCredential.user!.uid.toString());
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) => BottomNavBar(accountType),
        ),
        (route) => false,
      );
      //Navigator.pop(context);
      print('User is signed in!');
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        ifAnError();
        print('No user found for that email.');
        _toastMessages.toastError("Pas d\'utilisateur trouvé", context);
      } else if (e.code == 'wrong-password') {
        ifAnError();
        print('Wrong password provided for that user.');
        _toastMessages.toastError("Mot de passe incorrect!", context);
      } else {
        _toastMessages.toastError("Une erreur est survenue.", context);
        _toastMessages.toastError(e.toString(), context);
        print(e.toString());
      }
    }
  }

  Future<void> firebaseSignIn() async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
          email: emailController.text, password: passwordController.text);
      _toastMessages.toastSuccess("Connecté", context);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        _toastMessages.toastError(
            "Aucun utilisateur trouvé avec cet email.", context);
      } else if (e.code == 'wrong-password') {
        _toastMessages.toastError(
            "Mot de passe de l'utilisateur incorrect.", context);
      } else {
        _toastMessages.toastError("Une erreur est survenue.", context);
        _toastMessages.toastError(e.toString(), context);
        print(e.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          print("test");
          return Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) {
              return WelcomePage();
            }),
            (Route<dynamic> route) => false,
          ) as Future<bool>;
        },
        child: Scaffold(
            backgroundColor: AppThemeData().whiteColor,
            body: SafeArea(
                child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  children: [
                    Container(
                        alignment: Alignment.topLeft,
                        child: IconButton(
                            icon: Icon(Icons.arrow_back_ios_rounded),
                            onPressed: () {
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => WelcomePage()),
                                (Route<dynamic> route) => false,
                              );
                            })),
                    SizedBox(height: 20),
                    Image.asset(
                      'assets/logos/trashpick_logo_banner.png',
                      height: 200,
                      width: 200,
                    ),
                    SizedBox(height: 20),
                    Container(
                      padding: EdgeInsets.all(10),
                      height: 70.0,
                      child: TextFormField(
                        controller: emailController,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.zero,
                          prefixIcon: Icon(Icons.email_outlined),
                          border: OutlineInputBorder(),
                          labelText: 'Email',
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(10),
                      height: 70.0,
                      child: TextFormField(
                        obscureText: _isHidden,
                        controller: passwordController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Mot de passe',
                          prefixIcon: Icon(Icons.lock_outline_rounded),
                          suffix: InkWell(
                            onTap: _togglePasswordView,
                            child: Icon(
                              _isHidden
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: Colors.grey.shade800,
                            ),
                          ),
                        ).copyWith(isDense: true),
                      ),
                    ),
                    SizedBox(height: 20),
                    new ButtonWidget(
                      textColor: AppThemeData().whiteColor,
                      color: AppThemeData().secondaryColor,
                      text: "Se connecter",
                      onClicked: () {
                        if (validateUser()) {
                          _signInWithEmailAndPassword();
                          print("Sign In");
                        } else {
                          _toastMessages.toastInfo(
                              'Réessayer avec des informations correctes',
                              context);
                        }
                      },
                    ),
                    SizedBox(height: 20),
/*                    new TextButtonWidget(
                        onClicked: () {
*/ /*                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ForgotPassword()),
                                  (Route<dynamic> route) => false,
                            );*/ /*
                          print("Switch to Forgot Password!");
                        },
                        text: "Forgot Password?"),*/
                    Container(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text("Nouveau sur TrashPick?",
                              style: TextStyle(
                                fontSize: Theme.of(context)
                                    .textTheme
                                    .labelLarge!
                                    .fontSize,
                                fontWeight: FontWeight.bold,
                              )),
                          SizedBox(width: 10), //new
                          GestureDetector(
                            onTap: () {
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => SignInPage()),
                                (Route<dynamic> route) => false,
                              );
                              print("Switch to Sign Up");
                            },
                            child: Text(
                              "Créer un compte",
                              style: TextStyle(
                                  //souligné le text et le colorier en vert
                                  fontSize: Theme.of(context)
                                      .textTheme
                                      .labelLarge!
                                      .fontSize,
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.underline,
                                  color: Colors.green),
                            ),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ))));
  }
}
