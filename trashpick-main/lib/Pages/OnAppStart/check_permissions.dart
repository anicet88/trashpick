// ignore_for_file: unused_element

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../Pages/OnAppStart/welcome_page.dart';
import '../../Theme/theme_provider.dart';
import '../../Widgets/button_widgets.dart';

class CheckAppPermissions extends StatefulWidget {
  @override
  _CheckAppPermissionsState createState() => _CheckAppPermissionsState();
}

class _CheckAppPermissionsState extends State<CheckAppPermissions> {
  bool locationPermission = false;
  bool cameraPermission = false;
  bool storagePermission = false;

  _requestLocationPermission() async {
    print("----------------------- REQUEST LOCATION PERMISSION CALLED!");
    final serviceStatus = await Permission.locationWhenInUse.serviceStatus;
    final isGpsOn = serviceStatus == ServiceStatus.enabled;
    if (!isGpsOn) {
      print('TURN ON LOCATION SERVICE BEFORE REQUESTING PERMISSION.');
      return;
    }

    final status = await Permission.locationWhenInUse.request();
    if (status == PermissionStatus.granted) {
      print('LOCATION PERMISSION GRANTED!');
      setState(() {
        locationPermission = true;
      });
    } else if (status == PermissionStatus.denied) {
      print('LOCATION PERMISSION DENIED!');
      displayPermissionAlert(context, "Location");
      print(
          "----------------------- DISPLAY_PERMISSION_ALERT - LOCATION CALLED!");
    } else if (status == PermissionStatus.permanentlyDenied) {
      print('TAKE THE USER TO APP SETTINGS');
      await openAppSettings();
    }
  }

  _requestCameraPermission() async {
    print("----------------------- REQUEST CAMERA PERMISSION CALLED!");
    final status = await Permission.camera.request();
    if (status == PermissionStatus.granted) {
      print('CAMERA PERMISSION GRANTED!');
      setState(() {
        cameraPermission = true;
      });
    } else if (status == PermissionStatus.denied) {
      print('CAMERA PERMISSION DENIED!');
      displayPermissionAlert(context, "Camera");
      print(
          "----------------------- DISPLAY_PERMISSION_ALERT - CAMERA CALLED!");
    } else if (status == PermissionStatus.permanentlyDenied) {
      print('TAKE THE USER TO APP SETTINGS');
      await openAppSettings();
    }
  }

  _requestStoragePermission() async {
    print("----------------------- REQUEST STORAGE PERMISSION CALLED!");
    final status = await Permission.storage.request();
    if (status == PermissionStatus.granted) {
      print('Storage Permission granted.');
      setState(() {
        storagePermission = true;
      });
    } else if (status == PermissionStatus.denied) {
      print('Storage Permission denied.');
      displayPermissionAlert(context, "Storage");
      print(
          "----------------------- DISPLAY_PERMISSION_ALERT - STORAGE CALLED!");
    } else if (status == PermissionStatus.permanentlyDenied) {
      print('TAKE THE USER TO APP SETTINGS');
      await openAppSettings();
    }
  }

  _openAppSettings() async {
    await openAppSettings();
  }

  displayPermissionAlert(
      BuildContext contextDisplayPermissionAlert, String permissionName) {
    Widget cancelButton = TextButton(
      child: Text("Annuler"),
      onPressed: () {
        print('DISPLAY PERMISSION ALERT - CANCELED!');
        Navigator.pop(contextDisplayPermissionAlert);
        displayPermissionRequest(context);
      },
    );
    Widget continueButton = TextButton(
      child: Text("Donner la permission"),
      onPressed: () {
        print("DISPLAY PERMISSION ALERT - GIVE PERMISSION!");
        if (permissionName == "Location") {
          _requestLocationPermission();
        } else if (permissionName == "Camera") {
          _requestCameraPermission();
        } else if (permissionName == "Storage") {
          _requestStoragePermission();
        }

        Navigator.pop(contextDisplayPermissionAlert);
      },
    );

    AlertDialog alert = AlertDialog(
      title: Text("$permissionName Permission Requise"),
      content: Text("Vous devez accorder cette permission pour continuer."),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10.0))),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    showDialog(
      context: contextDisplayPermissionAlert,
      barrierDismissible: false,
      builder: (BuildContext contextDisplayPermissionAlert) {
        return WillPopScope(
            onWillPop: () {
              return Future.value(false);
            },
            child: alert);
      },
    );
  }

  displayPermissionRequest(BuildContext contextDisplayPermissionRequest) {
    Widget denyButton = TextButton(
      child: Text("Quitter l'application"),
      onPressed: () {
        print("----------------------- QUITE FROM APP!");
        SystemNavigator.pop();
      },
    );
    Widget allowButton = TextButton(
      child: Text("Autoriser"),
      onPressed: () async {
        print("----------------------- ALLOW PERMISSION PRESSED!");
        Navigator.pop(contextDisplayPermissionRequest);
        _requestLocationPermission();
      },
    );

    AlertDialog alert = AlertDialog(
      title: Text("Permission Requise"),
      content: Text(
          "Nous demandons l'accès à votre emplacement, à votre caméra et à votre espace de stockage. "
          "L'application enregistrera votre position afin de vous localiser et de vous donner accès à la carte. "
          " L'appareil photo sera utilisé pour capturer des photos qui seront utilisées dans les publications et les événements. "
          "L'accès au stockage recherche des photos à utiliser dans votre sélecteur."),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10.0))),
      actions: [
        denyButton,
        allowButton,
      ],
    );

    showDialog(
      context: contextDisplayPermissionRequest,
      barrierDismissible: false,
      builder: (BuildContext contextDisplayPermissionRequest) {
        return WillPopScope(
            onWillPop: () {
              return Future.value(false);
            },
            child: alert);
      },
    );
  }

  @override
  void initState() {
    print(
        "----------------------- CHECK PERMISSION PAGE INITIALIZED -----------------------");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => showDialog<bool>(
          context: context,
          builder: (c) => AlertDialog(
                title: Text('Quitter TrashPick'),
                content: Text('Voulez-vous vraiment quitter l\'application ?'),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10.0))),
                actions: [
                  TextButton(
                    child: Text('Oui'),
                    onPressed: () => Navigator.pop(c, true),
                  ),
                  TextButton(
                    child: Text('Non'),
                    onPressed: () => Navigator.pop(c, false),
                  ),
                ],
              )) as Future<bool>,
      child: Scaffold(
        backgroundColor: AppThemeData().whiteColor,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  SizedBox(height: 20),
                  Image.asset(
                    'assets/logos/trashpick_logo_banner.png',
                    height: 150,
                    width: 150,
                  ),
                  SizedBox(height: 30),
                  Text(
                    'Permission requise ',
                    style:
                        TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    height: 20.0,
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          Image.asset(
                            'assets/images/location.png',
                            scale: 3.0,
                          ),
                          SizedBox(
                            height: 10.0,
                          ),
                          Text(
                            "Localisation",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: Theme.of(context)
                                    .textTheme
                                    .titleMedium!
                                    .fontSize),
                          )
                        ],
                      ),
                      Column(
                        children: [
                          Image.asset(
                            'assets/images/camera.png',
                            scale: 3.0,
                          ),
                          SizedBox(
                            height: 10.0,
                          ),
                          Text(
                            "Camera",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: Theme.of(context)
                                    .textTheme
                                    .titleMedium!
                                    .fontSize),
                          )
                        ],
                      ),
                      Column(
                        children: [
                          Image.asset(
                            'assets/images/storage.png',
                            scale: 3.0,
                          ),
                          SizedBox(
                            height: 10.0,
                          ),
                          Text(
                            "Stockage",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: Theme.of(context)
                                    .textTheme
                                    .titleMedium!
                                    .fontSize),
                          )
                        ],
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Text(
                        "Nous demandons l'accès à votre emplacement, à votre caméra et à votre espace de stockage. "
                        "L'application enregistrera votre position afin de vous localiser et de vous donner accès à la carte. "
                        "L'appareil photo sera utilisé pour capturer des photos qui seront utilisées dans les publications et les événements. "
                        "L'accès au stockage recherche des photos à utiliser dans votre sélecteur.",
                        style: TextStyle(
                          fontSize:
                              Theme.of(context).textTheme.titleMedium!.fontSize,
                        ),
                        textAlign: TextAlign.justify),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            locationPermission
                                ? Image.asset(
                                    'assets/icons/icon_approval.png',
                                    scale: 4.0,
                                  )
                                : Image.asset(
                                    'assets/icons/icon_access_denied.png',
                                    scale: 4.0,
                                  ),
                            TextButton(
                              child: Text(
                                'Cliquez pour autoriser la localisation',
                                style: TextStyle(
                                    color: AppThemeData().secondaryColor),
                              ),
                              onPressed: _requestLocationPermission,
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            cameraPermission
                                ? Image.asset(
                                    'assets/icons/icon_approval.png',
                                    scale: 4.0,
                                  )
                                : Image.asset(
                                    'assets/icons/icon_access_denied.png',
                                    scale: 4.0,
                                  ),
                            TextButton(
                              child: Text(
                                'Cliquer pour autoriser la caméra',
                                style: TextStyle(
                                    color: AppThemeData().secondaryColor),
                              ),
                              onPressed: _requestCameraPermission,
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            storagePermission
                                ? Image.asset(
                                    'assets/icons/icon_approval.png',
                                    scale: 4.0,
                                  )
                                : Image.asset(
                                    'assets/icons/icon_access_denied.png',
                                    scale: 4.0,
                                  ),
                            TextButton(
                              child: Text(
                                'Cliquer pour autoriser le stockage',
                                style: TextStyle(
                                    color: AppThemeData().secondaryColor),
                              ),
                              onPressed: _requestStoragePermission,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 20.0,
                  ),
                  locationPermission && cameraPermission && storagePermission
                      ? ButtonWidget(
                          color: AppThemeData().secondaryColor,
                          onClicked: () {
                            print(
                                "----------------------- Continue to App -----------------------");
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (BuildContext context) =>
                                    WelcomePage(),
                              ),
                              (route) => false,
                            );
                          },
                          text: "Continuer",
                          textColor: AppThemeData().whiteColor,
                        )
                      : Container(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
