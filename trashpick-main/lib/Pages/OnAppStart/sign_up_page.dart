// ignore_for_file: unnecessary_null_comparison, unused_import

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:trashpick/Pages/OnAppStart/sign_in_page.dart';
import 'package:trashpick/Pages/OnAppStart/user_guide.dart';
import 'package:trashpick/Pages/OnAppStart/welcome_guide_page.dart';
import 'package:trashpick/Pages/OnAppStart/welcome_page.dart';
import '../../Widgets/toast_messages.dart';
import '../../Theme/theme_provider.dart';
import '../../Widgets/button_widgets.dart';

class SignUpPage extends StatefulWidget {
  SignUpPage({Key? key}) : super(key: key);
  //final String title;
  //SignUpPage({required this.app});

  //final FirebaseApp app;

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  ToastMessages _toastMessages = new ToastMessages();
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();
  TextEditingController homeAddressController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  String defaultUserAvatar =
      "https://firebasestorage.googleapis.com/v0/b/trashpick-db.appspot.com/o/Default%20User%20Avatar%2Ftrashpick_user_avatar.png?alt=media&token=734f7e74-2c98-4c27-b982-3ecd072ced79";

  bool _isHidden = true;
  bool _isHiddenC = true;

  double? circularProgressVal;
  bool isUserCreated = false;
  bool isAnError = false;

  String formattedDate = DateFormat('dd-MM-yyyy').format(DateTime.now());
  String formattedTime = DateFormat('kk:mm:a').format(DateTime.now());

  String accountTypeName = "Trash Picker";
  int accountTypeID = 1;

  void _togglePasswordView() {
    setState(() {
      _isHidden = !_isHidden;
    });
  }

  void _toggleConfirmPasswordView() {
    setState(() {
      _isHiddenC = !_isHiddenC;
    });
  }

  bool validateUser() {
    const pattern = r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$';
    final regExp = RegExp(pattern);

    if (nameController.text.isEmpty &&
        emailController.text.isEmpty &&
        phoneNumberController.text.isEmpty &&
        homeAddressController.text.isEmpty &&
        passwordController.text.isEmpty &&
        confirmPasswordController.text.isEmpty) {
      _toastMessages.toastInfo('Veuillez remplir vos informations', context);
    } else if (nameController.text.isEmpty) {
      _toastMessages.toastInfo('Le nom est vide', context);
    } else if (emailController.text.isEmpty) {
      _toastMessages.toastInfo('L\'email est vide', context);
    } else if (!regExp.hasMatch(emailController.text)) {
      _toastMessages.toastInfo('Le forma de l\'email est incorrect', context);
    } else if (phoneNumberController.text.isEmpty) {
      _toastMessages.toastInfo('Le numéro de téléphone est vide', context);
    } else if (homeAddressController.text.isEmpty) {
      _toastMessages.toastInfo('Votre adreesse est vide', context);
    } else if (passwordController.text.length < 6) {
      _toastMessages.toastInfo(
          'Le mot de passe doit avoir au moins 6 caractères!', context);
    } else if (passwordController.text.isEmpty) {
      _toastMessages.toastInfo('Mot de passe vide', context);
    } else if (confirmPasswordController.text != passwordController.text) {
      _toastMessages.toastInfo('Mots de passe non identiques', context);
    } else {
      print('Validation Réuissie!');
      return true;
    }

    return false;
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
              title: !isUserCreated
                  ? Center(child: Text("Creation du compte"))
                  : Center(child: Text("Compte créé avec succès!")),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!isUserCreated)
                    !isAnError
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
                              Text(
                                  "Salut " +
                                      nameController.text +
                                      ", Veuillez patienter...",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                          fontFamily: 'Montserrat',
                                          fontSize: 16.0)
                                      .copyWith(color: Colors.grey.shade900)),
                            ],
                          )
                        : Container(
                            child: Column(
                            children: [
                              Text("Error!",
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  )),
                              SizedBox(
                                height: 50.0,
                              ),
                              new ButtonWidget(
                                  text: "Réessayer",
                                  textColor: AppThemeData().whiteColor,
                                  color: AppThemeData().redColor,
                                  onClicked: () {
                                    Navigator.pop(context);
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
                              Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => WelcomeGuidePage(
                                          nameController.text.toString(),
                                          accountTypeName)),
                                  ModalRoute.withName("/WelcomeScreen"));
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
      isUserCreated = false;
      isAnError = true;
      //Navigator.pop(context);
      showAlertDialog(context);
    });
  }

  void printSignUpData() {
    print("ACCOUNT TYPE: " + "$accountTypeName");
    print("NAME: " + nameController.text.toString());
    print("EMAIL: " + emailController.text.toString());
    print("CONTACT NUMBER: " + phoneNumberController.text.toString());
    print("HOME ADDRESS: " + homeAddressController.text.toString());
    print("PASSWORD: " + passwordController.text.toString());
    print("CONFIRM PASSWORD: " + confirmPasswordController.text.toString());
  }

  void authenticateUser() async {
    showAlertDialog(context);

    setState(() {
      isUserCreated = false;
      isAnError = false;
    });

    try {
      await firebaseAuth.createUserWithEmailAndPassword(
          email: emailController.text, password: passwordController.text);

      if (FirebaseAuth.instance.currentUser!.uid != null) {
        print('User Account Authenticated!');

        User? user = FirebaseAuth.instance.currentUser;

        if (!user!.emailVerified) {
          await user.sendEmailVerification();
          print('Verification Email Send!');
        }
        try {
          FirebaseFirestore.instance
              .collection("Users")
              .doc(FirebaseAuth.instance.currentUser!.uid.toString())
              .set({
            "uuid": FirebaseAuth.instance.currentUser!.uid.toString(),
            "accountType": "$accountTypeName",
            "name": nameController.text,
            "email": emailController.text,
            "contactNumber": phoneNumberController.text,
            "homeAddress": homeAddressController.text,
            'password': passwordController.text,
            'appearedLocation': new GeoPoint(7.8731, 80.7718),
            'lastAppeared': "Not Set",
            'accountCreated': "$formattedDate, $formattedTime",
            'profileImage': "$defaultUserAvatar",
          }).then((value) {
            print("User Added to Firestore success");
            Navigator.pop(context);
            setState(() {
              isUserCreated = true;
              isAnError = false;
              showAlertDialog(context);
            });
          });
        } catch (e) {
          print("Failed to Add User to Firestore!: $e");
          ifAnError();
        }
      } else {
        print('Failed to User Account Authenticated!');
        ifAnError();
      }
    } catch (e) {
      print(e.toString());
      if (e.toString() ==
          "[firebase_auth/email-already-in-use] Cet e-mail est déjà utilisé par un autre compte.") {
        ifAnError();
        new ToastMessages().toastError(
            "L\'adresse email est dejà utilisé par un autre compte", context);
      } else {
        ifAnError();
        print(e.toString());
      }
    }
  }

  radioButtonList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          "Selectionner un type de compte",
          style: TextStyle(
              fontSize: Theme.of(context).textTheme.titleLarge?.fontSize,
              fontWeight: FontWeight.bold),
        ),
        SizedBox(
          height: 10.0,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Radio(
              value: 1,
              groupValue: accountTypeID,
              onChanged: (val) {
                setState(() {
                  accountTypeName = 'Trash Picker';
                  accountTypeID = 1;
                });
              },
            ),
            Text(
              'Client',
              style: new TextStyle(fontSize: 12),
            ),
            Radio(
              value: 2,
              groupValue: accountTypeID,
              onChanged: (val) {
                setState(() {
                  accountTypeName = 'Trash Collector';
                  accountTypeID = 2;
                });
              },
            ),
            Text(
              'Agent de Salubrité',
              style: new TextStyle(
                fontSize: 12,
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        print("test");
        return Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => UserGuidePage()),
          (Route<dynamic> route) => false,
        ) as Future<bool>;
      },
      child: Scaffold(
        backgroundColor: AppThemeData().whiteColor,
        body: SafeArea(
          child: SingleChildScrollView(
              child: Padding(
                  padding: EdgeInsets.all(10),
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
                                      builder: (context) => UserGuidePage()),
                                  (Route<dynamic> route) => false,
                                );
                              })),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/logos/trashpick_logo_banner.png',
                            height: 120,
                            width: 120,
                          ),
                          SizedBox(width: 10),
                          Text("Créer un Compte \nen s\'inscrivant",
                              style: TextStyle(
                                fontSize: Theme.of(context)
                                    .textTheme
                                    .headlineSmall!
                                    .fontSize,
                                fontWeight: FontWeight.bold,
                              )),
                        ],
                      ),
                      SizedBox(height: 20),
                      radioButtonList(),
                      SizedBox(height: 10),
                      Padding(
                        padding: EdgeInsets.all(10),
                        child: Column(
                          children: [
                            TextFormField(
                              controller: nameController,
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.zero,
                                prefixIcon: Icon(Icons.account_circle_outlined),
                                border: OutlineInputBorder(),
                                labelText: 'Nom',
                              ),
                            ),
                            SizedBox(
                              height: 20.0,
                            ),
                            TextFormField(
                              controller: emailController,
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.zero,
                                prefixIcon: Icon(Icons.email_outlined),
                                border: OutlineInputBorder(),
                                labelText: 'Email',
                              ),
                            ),
                            SizedBox(
                              height: 20.0,
                            ),
                            TextFormField(
                              controller: phoneNumberController,
                              keyboardType: TextInputType.phone,
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.zero,
                                prefixIcon: Icon(Icons.phone_android_rounded),
                                border: OutlineInputBorder(),
                                labelText: 'Numéro de téléphone',
                              ),
                            ),
                            SizedBox(
                              height: 20.0,
                            ),
                            TextFormField(
                              controller: homeAddressController,
                              keyboardType: TextInputType.multiline,
                              maxLines: null,
                              decoration: InputDecoration(
                                prefixIcon: Icon(Icons.home_rounded),
                                border: OutlineInputBorder(),
                                labelText: 'Adresse',
                              ),
                            ),
                            SizedBox(
                              height: 20.0,
                            ),
                            TextFormField(
                              obscureText: _isHidden,
                              controller: passwordController,
                              keyboardType: TextInputType.visiblePassword,
                              decoration: InputDecoration(
                                contentPadding:
                                    EdgeInsets.fromLTRB(0.0, 0.0, 10.0, 0.0),
                                prefixIcon: Icon(Icons.lock_outline_rounded),
                                border: OutlineInputBorder(),
                                labelText: 'Mot de passe',
                                suffix: InkWell(
                                  onTap: _togglePasswordView,
                                  child: Icon(
                                    _isHidden
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                    color: Colors.grey.shade800,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 20.0,
                            ),
                            TextFormField(
                              obscureText: _isHiddenC,
                              controller: confirmPasswordController,
                              keyboardType: TextInputType.visiblePassword,
                              decoration: InputDecoration(
                                contentPadding:
                                    EdgeInsets.fromLTRB(0.0, 0.0, 10.0, 0.0),
                                prefixIcon: Icon(Icons.lock_outline_rounded),
                                border: OutlineInputBorder(),
                                labelText: 'Confirmer le mot de passe',
                                suffix: InkWell(
                                  onTap: _toggleConfirmPasswordView,
                                  child: Icon(
                                    _isHiddenC
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                    color: Colors.grey.shade800,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 20),
                      new ButtonWidget(
                        textColor: AppThemeData().whiteColor,
                        color: AppThemeData().secondaryColor,
                        text: "S'inscrire",
                        onClicked: () {
                          if (validateUser()) {
                            printSignUpData();
                            authenticateUser();
                          } else {
                            /*_toastMessages.toastInfo(
                                'Try again with correct details!');*/
                          }
                        },
                      ),
                      SizedBox(height: 20),
                      Container(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text("Déjà inscrit?",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                )),
                            SizedBox(width: 10),
                            GestureDetector(
                              onTap: () {
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => SignInPage()),
                                  (Route<dynamic> route) => false,
                                );
                                print("Switch to Sign In");
                              },
                              child: Text("Se connecter",
                                  style: TextStyle(
                                      //souligné le text et le colorier en vert
                                      fontSize: Theme.of(context)
                                          .textTheme
                                          .labelLarge!
                                          .fontSize,
                                      fontWeight: FontWeight.bold,
                                      decoration: TextDecoration.underline,
                                      color: Colors.green)),
                            ),
                          ],
                        ),
                      )
                    ],
                  ))),
        ),
      ),
    );
  }
}
