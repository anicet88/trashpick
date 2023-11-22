// ignore_for_file: unused_import, unused_field, unnecessary_null_comparison, deprecated_member_use

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:trashpick/Generators/uui_generator.dart';
import 'package:trashpick/Models/user_model.dart';
import 'package:trashpick/Pages/BottomNavBar/PickMyTrash/pick_trash_location.dart';
import 'package:trashpick/Theme/theme_provider.dart';
import 'package:trashpick/Widgets/button_widgets.dart';
import 'dart:io';
import 'package:trashpick/Widgets/primary_app_bar_widget.dart';
import 'package:trashpick/Widgets/secondary_app_bar_widget.dart';
import 'package:trashpick/Widgets/toast_messages.dart';

import '../bottom_nav_bar.dart';

class NewTrashPickUp extends StatefulWidget {
  final String accountType;

  NewTrashPickUp(this.accountType);

  @override
  _NewTrashPickUpState createState() => _NewTrashPickUpState();
}

class _NewTrashPickUpState extends State<NewTrashPickUp> {
  TextEditingController _trashNameController = new TextEditingController();
  TextEditingController _trashDescriptionController =
      new TextEditingController();
  TextEditingController _trashLocationController = new TextEditingController();
  int charLength = 0;
  File? _image;
  final String userProfileID =
      FirebaseAuth.instance.currentUser!.uid.toString();

  // Uploading Process
  bool isStartToUpload = false;
  bool isUploadComplete = false;
  bool isAnError = false;
  double? circularProgressVal;

  // Temp until delete
  late CollectionReference imgRef;
  late firebase_storage.Reference ref;
  late String imageURL;
  final firestoreInstance = FirebaseFirestore.instance;
  String formattedDate = DateFormat('dd-MM-yyyy').format(DateTime.now());
  String formattedTime = DateFormat('kk:mm:a').format(DateTime.now());

  String trashID = new UUIDGenerator().uuidV4();

  // ------------------------------ Trash Type Selector ------------------------------ \\

  Map<String, bool> trashTypeValues = {
    'Plastic & Polythene': false,
    'Glass': false,
    'Paper': false,
    'Metal & Coconut Shell': false,
    'Clinical Waste': false,
    'E-Waste': false,
  };

  List trashTypeArray = [];
  late List trashTypes;

  getCheckboxItems() {
    trashTypeArray.clear();
    trashTypeValues.forEach((key, value) {
      if (value == true) {
        trashTypeArray.add(key);
      }
    });
    trashTypes = trashTypeArray;
    //print(trashTypeArray);
    //print(trashTypes);
  }

  // ------------------------------ Location Picker ------------------------------ \\

  String locationName = "Ma Localisation";
  String userHomeLocation = "Mon domicile";
  late int locationTypeID = 1;

  final userReference = FirebaseFirestore.instance.collection('Users');
  final FirebaseAuth auth = FirebaseAuth.instance;
  late Position _currentPosition;

  late List _trashLocationDetails;
  String userCurrentAddress = "Aucun lieu n'est sélectionné !";
  String selectedFromMapAddress = "Aucun lieu n'est sélectionné !";
  String trashLocationAddress = "Aucun lieu n'est sélectionné !";
  late double trashLocationLatitude, trashLocationLongitude;

  // ------------------------------ Date Picker ------------------------------ \\

  String startDate = DateTime.now().day.toString() +
      "/" +
      DateTime.now().month.toString() +
      "/" +
      DateTime.now().year.toString();
  String returnDate = DateTime.now().day.toString() +
      "/" +
      DateTime.now().month.toString() +
      "/" +
      DateTime.now().year.toString();
  DateTime _dateS = DateTime(2021, 07, 17);
  DateTime _dateR = DateTime(2021, 07, 18);

  // ------------------------------ Time Picker ------------------------------ \\

  String startTime = "7:15 AM";
  String returnTime = "8:15 AM";
  TimeOfDay _timeS = TimeOfDay(hour: 7, minute: 15);
  TimeOfDay _timeR = TimeOfDay(hour: 8, minute: 15);
  var now = DateTime.now().hour;
  var nowt = DateTime.now().minute;
  TimeOfDay releaseTime = TimeOfDay(hour: 15, minute: 0);
  String nowTime = TimeOfDay(hour: 15, minute: 0).toString();

  void _startTime() async {
    final TimeOfDay? newTime = await showTimePicker(
      context: context,
      initialTime: _timeS,
    );
    if (newTime != null) {
      setState(() {
        _timeS = newTime;
        startTime = _timeS.format(context);
      });
    }
  }

  void _returnTime() async {
    final TimeOfDay? newTime = await showTimePicker(
      context: context,
      initialTime: _timeR,
    );
    if (newTime != null) {
      setState(() {
        _timeR = newTime;
        returnTime = _timeR.format(context);
      });
    }
  }

  _onChanged(String value) {
    setState(() {
      charLength = value.length;
    });
  }

  _imgFromCamera() async {
    XFile? image = await ImagePicker()
        .pickImage(source: ImageSource.camera, imageQuality: 50);

    setState(() {
      _image = File(image!.path);
    });
  }

  _imgFromGallery() async {
    XFile? image = await ImagePicker()
        .pickImage(source: ImageSource.gallery, imageQuality: 50);

    setState(() {
      _image = File(image!.path);
    });
  }

  void _showPicker(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return SafeArea(
            child: Container(
              child: new Wrap(
                children: <Widget>[
                  new ListTile(
                      leading: new Icon(Icons.photo_library),
                      title: new Text('Bibliothèque de photos'),
                      onTap: () {
                        _imgFromGallery();
                        Navigator.of(context).pop();
                      }),
                  new ListTile(
                    leading: new Icon(Icons.photo_camera),
                    title: new Text('Camera'),
                    onTap: () {
                      _imgFromCamera();
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
          );
        });
  }

  void ifAnError() {
    Navigator.pop(context);
    setState(() {
      isStartToUpload = false;
      //isUploadComplete = false;
      isUploadComplete = true;
      isAnError = true;
      //Navigator.pop(context);
      showAlertDialog(context);
    });
  }

  void sendErrorCode(String error) {
    ToastMessages().toastError(error, context);
    ifAnError();
  }

  void sendSuccessCode() {
    //print("Post Add Success!");
    Navigator.pop(context);
    setState(() {
      isStartToUpload = false;
      isUploadComplete = true;
    });
    showAlertDialog(context);
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
              title: !isUploadComplete
                  ? Center(child: Text("chargement du message"))
                  : Center(child: Text("Chargement réussi")),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!isUploadComplete)
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
                                    Colors.teal.shade700),
                              ),
                              SizedBox(
                                height: 30.0,
                              ),
                              Text(
                                  "Veuillez attendre que votre message soit téléchargé.",
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
                              Text("Erreur!",
                                  style: TextStyle(
                                    fontSize: 22,
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
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 5.0),
                        child: Column(
                          children: [
                            Image.asset(
                              'assets/icons/icon_recycle.png',
                              height: 50,
                              width: 50,
                            ),
                            SizedBox(height: 30),
                            Text("Le message a été chargé!",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                        fontFamily: 'Montserrat',
                                        fontSize: 22.0)
                                    .copyWith(
                                        color: Colors.grey.shade900,
                                        fontWeight: FontWeight.bold)),
                            SizedBox(height: 50),
                            new ButtonWidget(
                                text: "Continue",
                                textColor: AppThemeData().whiteColor,
                                color: AppThemeData().primaryColor,
                                onClicked: () {
                                  Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(
                                      builder: (BuildContext context) =>
                                          BottomNavBar(widget.accountType),
                                    ),
                                    (route) => false,
                                  );
                                }),
                          ],
                        ),
                      ),
                    )
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

  Future<void> uploadImagesToStorage() async {
    try {
      ref = firebase_storage.FirebaseStorage.instance
          .ref()
          //.child('Posts/$userProfileID/$postID/${Path.basename(_image.path)}');
          .child('Trash_Pick_Ups/$userProfileID/$trashID/$trashID');
      await ref.putFile(_image!);

      String downloadURL = await firebase_storage.FirebaseStorage.instance
          .ref()
          //.child('Posts/$userProfileID/$postID/${Path.basename(_image.path)}')
          .child('Trash_Pick_Ups/$userProfileID/$trashID/$trashID')
          .getDownloadURL();
      imageURL = downloadURL.toString();
      print("Image Uploaded to Firebase Storage!");
      print("Image URL: " + imageURL);
      addPostToFireStore(imageURL);
    } catch (e) {
      print("------->erreur: " + e.toString());
      ifAnError();
    }
  }

  Future<void> addPostToFireStore(String trashImage) async {
    firestoreInstance
        .collection('Users')
        .doc(userProfileID)
        .collection('Trash Pick Ups')
        .doc(trashID)
        .set({
          'trashID': trashID,
          'postedDate': formattedDate + ", " + formattedTime,
          'trashName': _trashNameController.text,
          'trashDescription': _trashDescriptionController.text,
          'trashImage': trashImage,
          'trashTypes': trashTypes,
          'trashLocationAddress': trashLocationAddress,
          'trashLocationLocation':
              new GeoPoint(trashLocationLatitude, trashLocationLongitude),
          'startDate': startDate,
          'returnDate': returnDate,
          'startTime': startTime,
          'returnTime': returnTime,
        })
        .then(
          (value) => sendSuccessCode(),
        )
        .catchError((error) => sendErrorCode(error.toString()));
  }

  /*void validatePost() {
    if (_newPostCaptionController.text.isEmpty ||
        _newPostCaptionController.text == null) {
      ToastMessages().toastError("Please enter trash caption", context);
    } else if (_image == null) {
      ToastMessages().toastError("Please select image", context);
    } else {
      showAlertDialog(context);
      uploadImagesToStorage();
    }
  }*/

  _getCurrentUserLocation() async {
    try {
      Geolocator.getCurrentPosition(
              desiredAccuracy: LocationAccuracy.high,
              forceAndroidLocationManager: true)
          .then((Position position) {
        setState(() {
          _currentPosition = position;
        });
        _getCurrentUserAddressFromLatLng(
            _currentPosition.latitude, _currentPosition.longitude);
      }).catchError((e) {
        print(e);
      });
    } catch (error) {
      ToastMessages().toastError(error.toString(), context);
    }
  }

  _getCurrentUserAddressFromLatLng(latitude, longitude) async {
    try {
      List<Placemark> p = await placemarkFromCoordinates(latitude, longitude);
      Placemark place = p[0];
      setState(() {
        if (place != null) {
          trashLocationLatitude = latitude;
          trashLocationLongitude = longitude;

          _trashLocationDetails = [
            latitude, // 00
            longitude, // 01
            "${place.name}", // 02
            "${place.street}", // 03
            "${place.postalCode}", // 04
            "${place.administrativeArea}", // 05
            "${place.subAdministrativeArea}", // 06
            "${place.thoroughfare}", // 07
            "${place.subThoroughfare}", // 08
            "${place.locality}", // 09
            "${place.subLocality}", // 10
            "${place.country}", // 11
            "${place.isoCountryCode}", // 12
          ];

          userCurrentAddress = ""
              "${_trashLocationDetails[0].toString()}, "
              "${_trashLocationDetails[1].toString()}, "
              "${_trashLocationDetails[2].toString()}, "
              "${_trashLocationDetails[3].toString()}, "
              "${_trashLocationDetails[4].toString()}, "
              "${_trashLocationDetails[5].toString()}, "
              "${_trashLocationDetails[6].toString()}, "
              "${_trashLocationDetails[7].toString()}, "
              "${_trashLocationDetails[8].toString()}, "
              "${_trashLocationDetails[9].toString()}, "
              "${_trashLocationDetails[10].toString()}, "
              "${_trashLocationDetails[11].toString()}, "
              "${_trashLocationDetails[12].toString()}";

          /*ToastMessages().toastSuccess("Location Selected: \n"
              "$_trashLocationAddress", context);*/
        } else {
          ToastMessages().toastSuccess("Pas d'addresse", context);
        }
      });
    } catch (error) {
      ToastMessages().toastError(error.toString(), context);
      print("ERROR=> _getTrashLocationAddressFromLatLng: $error");
    }
  }

  void _startDate() async {
    final DateTime? newDate = await showDatePicker(
      context: context,
      initialDate: _dateS,
      firstDate: DateTime(2021, 1),
      lastDate: DateTime(2031, 1),
      helpText: 'Choisir une date',
    );
    if (newDate != null) {
      setState(() {
        _dateS = newDate;
        startDate = _dateS.day.toString() +
            "/" +
            _dateS.month.toString() +
            "/" +
            _dateS.year.toString();
      });
    }
  }

  void _returnDate() async {
    final DateTime? newDate = await showDatePicker(
      context: context,
      initialDate: _dateR,
      firstDate: DateTime(2017, 1),
      lastDate: DateTime(2022, 7),
      helpText: 'Choisir une date',
    );
    if (newDate != null) {
      setState(() {
        _dateR = newDate;
        returnDate = _dateR.day.toString() +
            "/" +
            _dateR.month.toString() +
            "/" +
            _dateR.year.toString();
      });
    }
  }

  printTrashPickUpDetails() {
    String info =
        "------------------------- Détails sur le ramassage des poubelles-------------------------\n"
                "Nom de la poubelle: " +
            _trashNameController.text +
            "\n" +
            "Description de la poubelle: " +
            _trashDescriptionController.text +
            "\n" +
            "Image de la poubelle: " +
            _image.toString() +
            "\n" +
            "Types de déchets: " +
            trashTypes.toString() +
            "\n" +
            "Adresse de l'emplacement de la corbeille: " +
            trashLocationAddress.toString() +
            "\n" +
            "Latitude: " +
            trashLocationLatitude.toString() +
            "\n" +
            "Longitude: " +
            trashLocationLongitude.toString() +
            "\n" +
            "Start Date: $startDate\n" +
            "Return Date: $returnDate\n" +
            "Start Time: $startTime\n" +
            "Return Time: $returnTime\n";
    print(info);
  }

  void validatePickUp() {
    if (_trashNameController.text.isEmpty) {
      new ToastMessages()
          .toastError("Impossible de laisser le nom de la poubelle", context);
    } else if (_trashDescriptionController.text.isEmpty) {
      new ToastMessages().toastError(
          "Impossible de laisser une description de la poubelle", context);
    } else if (_image == null) {
      new ToastMessages()
          .toastError("Veuillez selectionner une image", context);
    } else if (trashTypes.isEmpty) {
      new ToastMessages()
          .toastError("Veuillez sélectionner au moins un type", context);
    } else if (trashLocationAddress == "Pas d'emplacement selectionné") {
      new ToastMessages()
          .toastError("Veuillez sélectionner un emplacement", context);
    } else if (startDate.isEmpty) {
      new ToastMessages()
          .toastError("Veuillez sélectionner une date de début", context);
    } else if (returnDate.isEmpty) {
      new ToastMessages()
          .toastError("Veuillez selectionner une date de retour", context);
    } else if (_dateS.day + _dateS.month + _dateS.year >
        _dateR.day + _dateR.month + _dateR.year) {
      new ToastMessages().toastError(
          "La date de retour ne peut être antérieure à la date de début",
          context);
    } else if (startTime.isEmpty) {
      new ToastMessages()
          .toastError("Veuillez choisir l'heure de début", context);
    } else if (returnTime.isEmpty) {
      new ToastMessages()
          .toastError("Veuillez choisir l'heure du retour", context);
    } else if (startDate == returnDate && _timeS.hour > _timeR.hour) {
      new ToastMessages().toastError(
          "L'heure de retour ne peut être antérieure à l'heure de départ le même jour.",
          context);
    } else {
      printTrashPickUpDetails();
      showAlertDialog(context);
      uploadImagesToStorage();
    }
    //printTrashPickUpDetails();
  }

  @override
  void initState() {
    _getCurrentUserLocation();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    void navigateAndDisplaySelection(BuildContext context) async {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => PickTrashLocation(_currentPosition)),
      );
      setState(() {
        if (result == null) {
          selectedFromMapAddress = "Pas d'emplacement sélectionné!";
        } else {
          _trashLocationDetails = result;
          selectedFromMapAddress = ""
              "${_trashLocationDetails[0].toString()}, "
              "${_trashLocationDetails[1].toString()}, "
              "${_trashLocationDetails[2].toString()}, "
              "${_trashLocationDetails[3].toString()}, "
              "${_trashLocationDetails[4].toString()}, "
              "${_trashLocationDetails[5].toString()}, "
              "${_trashLocationDetails[6].toString()}, "
              "${_trashLocationDetails[7].toString()}, "
              "${_trashLocationDetails[8].toString()}, "
              "${_trashLocationDetails[9].toString()}, "
              "${_trashLocationDetails[10].toString()}, "
              "${_trashLocationDetails[11].toString()}, "
              "${_trashLocationDetails[12].toString()}";
          trashLocationAddress = selectedFromMapAddress;
        }
      });
    }

    showInfoAlert(BuildContext context) {
      String infoTitle = "Guide de sélection de l'emplacement";
      String infoMessage =
          "Pour sélectionner un lieu, il suffit de cliquer sur la carte et le lieu sélectionné sera marqué par un marqueur.";
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(infoTitle),
            content: Container(
              height: 160.0,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    infoMessage,
                    style: TextStyle(fontWeight: FontWeight.normal),
                  ),
                  Image.asset(
                    'assets/icons/icon_bin.png',
                    scale: 1.0,
                  )
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: Text(
                  "Ok et Sélectionner l'emplacement",
                  style: TextStyle(color: AppThemeData().primaryColor),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  navigateAndDisplaySelection(context);
/*                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            PickTrashLocation(_currentPosition)),
                  );*/
                },
              ),
            ],
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(10.0))),
          );
        },
      );
    }

    garbageTypes() {
      return Container(
        height: 430.0,
        child: ListView(
          physics: NeverScrollableScrollPhysics(),
          children: trashTypeValues.keys.map((String key) {
            Color color;
            String description;

            switch (key) {
              case "Plastic & Polythene":
                color = Colors.orange.shade700;
                description = "Plastique et polyéthylène";
                break;
              case "Glass":
                color = Colors.red;
                description = "Verre";
                break;
              case "Paper":
                color = Colors.blue;
                description = "Papier";
                break;
              case "Metal & Coconut Shell":
                color = Colors.black;
                description = "Métal et coquille de noix de coco";
                break;
              case "Clinical Waste":
                color = Colors.yellow;
                description = "Déchets médicaux";
                break;
              case "E-Waste":
                color = Colors.grey.shade200;
                description = "Déchets électroniques";
                break;
              default:
                color = Colors.grey.shade100;
                description = "Autres déchets";
            }

            return new CheckboxListTile(
              secondary: Container(
                color: color,
                height: 30.0,
                width: 30.0,
              ),
              title: new Text(key),
              subtitle: Text(description),
              value: trashTypeValues[key],
              onChanged: (value) {
                setState(() {
                  trashTypeValues[key] = value!;
                });
              },
            );
          }).toList(),
        ),
      );
    }

    /*Widget getMyHomeAddress(){
      return FutureBuilder(
        future: userReference.doc(auth.currentUser.uid).get(),
        builder: (context, dataSnapshot) {
          if (!dataSnapshot.hasData) {
            _trashLocationController =
            new TextEditingController(text: "No Location Selected!");
            return TextFormField(
              controller: _trashLocationController,
              style: TextStyle(fontWeight: FontWeight.normal),
              decoration: InputDecoration(
                prefixIcon: Icon(
                  Icons.home_rounded,
                  color: Theme.of(context).iconTheme.color,
                  size: 35.0,
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: const BorderSide(color: Colors.black),
                ),
              ),
              keyboardType: TextInputType.text,
            );
          } else {
            UserModelClass userModelClass =
            UserModelClass.fromDocument(dataSnapshot.data);
            _trashLocationController =
            new TextEditingController(text: userModelClass.homeAddress);
            return TextFormField(
              controller: _trashLocationController,
              style: TextStyle(fontWeight: FontWeight.normal),
              decoration: InputDecoration(
                prefixIcon: Icon(
                  Icons.home_rounded,
                  color: Theme.of(context).iconTheme.color,
                  size: 35.0,
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: const BorderSide(color: Colors.black),
                ),
              ),
              keyboardType: TextInputType.text,
            );
          }
        },
      );
    }*/

    Widget trashLocation() {
      Widget widget;

      switch (locationName) {
        case "Position actuelle":
          widget = Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.location_on_rounded,
                color: Theme.of(context).iconTheme.color,
                size: 35.0,
              ),
              Text(
                "Position actuelle",
                style: TextStyle(
                    fontSize: Theme.of(context).textTheme.headline6?.fontSize,
                    fontWeight: FontWeight.bold),
              ),
            ],
          );
          break;
        case "Sélection sur la carte":
          widget = Center(
            //use an elevated button
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: Theme.of(context).primaryColor,
                onPrimary: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              onPressed: () {
                showInfoAlert(context);
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.location_on_rounded,
                    color: AppThemeData().whiteColor,
                    size: 35.0,
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  Text(
                    "Sélection sur la carte",
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppThemeData().whiteColor),
                  ),
                ],
              ),
            ),
          );
          break;
        default:
          widget = Container();
      }
      return widget;
    }

    radioButtonList() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Radio(
                value: 1,
                groupValue: locationTypeID,
                onChanged: (val) {
                  setState(() {
                    locationName = 'Position actuelle';
                    locationTypeID = 1;
                    trashLocationAddress = userCurrentAddress;
                  });
                },
              ),
              Text(
                'Position actuelle',
                style: new TextStyle(fontSize: 13),
              ),
              Radio(
                value: 2,
                groupValue: locationTypeID,
                onChanged: (val) {
                  setState(() {
                    locationName = 'Selection sur la carte';
                    locationTypeID = 2;
                    trashLocationAddress = selectedFromMapAddress;
                  });
                },
              ),
              Text(
                'Selection sur la carte',
                style: new TextStyle(
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ],
      );
    }

    dateSelectCard(String title, VoidCallback onCardTap, String dateType) {
      return Container(
        alignment: Alignment.topLeft,
        width: 140,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade600),
            ),
            SizedBox(
              height: 5,
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(10.0),
              child: Container(
                  color: Colors.grey.shade200,
                  child: new GestureDetector(
                      onTap: onCardTap,
                      child: new Container(
                        height: 50.0,
                        width: 150.0,
                        color: Colors.white,
                        child: Center(
                            child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.calendar_today_rounded,
                              size: 20.0,
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            Text(
                              dateType,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        )),
                      ))),
            ),
          ],
        ),
      );
    }

    timeSelectCard(String title, VoidCallback onCardTap, String timeType) {
      return Container(
        alignment: Alignment.topLeft,
        width: 140,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade600),
            ),
            SizedBox(
              height: 10.0,
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(10.0),
              child: Container(
                  color: Colors.grey.shade200,
                  child: new GestureDetector(
                      onTap: onCardTap,
                      child: new Container(
                        height: 50.0,
                        width: 150.0,
                        color: Colors.white,
                        child: Center(
                            child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.access_time_rounded,
                              size: 20.0,
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            Text(
                              timeType,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        )),
                      ))),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: SecondaryAppBar(
        title: "Planifier un ramassage de déchets",
        appBar: AppBar(),
        widgets: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(0.0, 0.0, 10.0, 0.0),
            child: Icon(
              Icons.cancel_rounded,
              size: 30.0,
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _trashNameController,
                  style: TextStyle(fontWeight: FontWeight.normal),
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 10.0),
                    hintText: "Donner un nom à la poubelle",
                    labelText: 'Nom de la poubelle',
                    focusedBorder: UnderlineInputBorder(
                      borderSide: const BorderSide(color: Colors.black),
                    ),
                    labelStyle: TextStyle(
                        color: Colors.grey.shade900,
                        fontWeight: FontWeight.bold),
                  ),
                  keyboardType: TextInputType.text,
                ),
                SizedBox(
                  height: 20.0,
                ),
                TextFormField(
                  controller: _trashDescriptionController,
                  style: TextStyle(fontWeight: FontWeight.normal),
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 10.0),
                    helperText: "$charLength",
                    hintText: "Dites quelque chose à propos des ordures",
                    labelText: 'Description de la poubelle',
                    focusedBorder: UnderlineInputBorder(
                      borderSide: const BorderSide(color: Colors.black),
                    ),
                    labelStyle: TextStyle(
                        color: Colors.grey.shade900,
                        fontWeight: FontWeight.bold),
                  ),
                  onChanged: _onChanged,
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                ),
                SizedBox(
                  height: 20.0,
                ),
                Text(
                  "Image de la poubelle",
                  style: TextStyle(
                      fontSize: Theme.of(context).textTheme.subtitle1?.fontSize,
                      fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: 20.0,
                ),
                Center(
                  child: GestureDetector(
                    onTap: () {
                      _showPicker(context);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      alignment: Alignment.center,
                      child: _image != null
                          ? Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Colors.white,
                              ),
                              child: Image.file(
                                _image!,
                                width: MediaQuery.of(context).size.width,
                                height: 300,
                                fit: BoxFit.cover,
                              ),
                            )
                          : Container(
                              decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(10)),
                              width: MediaQuery.of(context).size.width,
                              height: 300,
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Text(
                                    "Appuyer pour sélectionner l'image",
                                    style: TextStyle(
                                      fontSize: Theme.of(context)
                                          .textTheme
                                          .headline6
                                          ?.fontSize,
                                      fontWeight: FontWeight.normal,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  Icon(
                                    Icons.camera_alt_rounded,
                                    size: 80.0,
                                    color: Colors.grey.shade700,
                                  ),
                                ],
                              ),
                            ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 20.0,
                ),
                Text(
                  "Sélectionner les types de corbeilles",
                  style: TextStyle(
                      fontSize: Theme.of(context).textTheme.subtitle1?.fontSize,
                      fontWeight: FontWeight.bold),
                ),
                garbageTypes(),
                SizedBox(
                  height: 20.0,
                ),
                Text(
                  "Selectionner l'emplacement",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                radioButtonList(),
                trashLocation(),
                SizedBox(
                  height: 20.0,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Emplacement de la poubelle",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                    Text(
                      "$trashLocationAddress",
                      style: TextStyle(
                          fontSize:
                              Theme.of(context).textTheme.subtitle1?.fontSize,
                          fontWeight: FontWeight.normal),
                    ),
                  ],
                ),
                SizedBox(
                  height: 20.0,
                ),
                Text(
                  "Sélectionner la période de disponibilité",
                  style: TextStyle(
                      fontSize: Theme.of(context).textTheme.subtitle1?.fontSize,
                      fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: 20.0,
                ),
                Container(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        dateSelectCard("Date de debut", _startDate, startDate),
                        dateSelectCard("Date max", _returnDate, returnDate),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 20.0,
                ),
                Text(
                  "Selectionner l'heure de disponibilité",
                  style: TextStyle(
                      fontSize: Theme.of(context).textTheme.subtitle1?.fontSize,
                      fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: 20.0,
                ),
                Container(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        timeSelectCard("Heure de debut", _startTime,
                            _timeS.format(context)),
                        timeSelectCard(
                            "Heure max", _returnTime, _timeR.format(context)),
                      ],
                    ),
                  ),
                ),
                MinButtonWidget(
                  onClicked: () {
                    getCheckboxItems();
                    //printTrashPickUpDetails();
                    validatePickUp();
                  },
                  color: AppThemeData().secondaryColor,
                  text: "OK",
                ),
                SizedBox(
                  height: 40.0,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
