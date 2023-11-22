import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:trashpick/Pages/OnAppStart/welcome_page.dart';
import 'package:trashpick/Widgets/toast_messages.dart';

class SignOutAlertDialog {
  void showAlert(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmer votre déconnexion'),
          content: Text("Etes vous sûre de vouloir vous déconnecter?"),
          actions: <Widget>[
            TextButton(
              child: Text(
                "NON",
                style: Theme.of(context).textTheme.labelLarge,
              ),
              onPressed: () {
                Navigator.of(context).pop();
                //print("Cancel Sign Out");
              },
            ),
            TextButton(
              child: Text(
                "OUI",
                style: Theme.of(context).textTheme.labelLarge,
              ),
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                ToastMessages().toastSuccess("Déconnexion réussie", context);
                //print("Sign Out Success");
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (BuildContext context) => WelcomePage(),
                  ),
                  (route) => false,
                );
              },
            ),
          ],
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20.0))),
        );
      },
    );
  }
}
