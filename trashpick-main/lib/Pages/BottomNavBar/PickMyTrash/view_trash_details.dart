// ignore_for_file: unused_local_variable

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:trashpick/Models/trash_pick_ups_model.dart';
import 'package:trashpick/Widgets/button_widgets.dart';
import 'package:trashpick/Widgets/secondary_app_bar_widget.dart';

class ViewTrashDetails extends StatefulWidget {
  final String userID, trashID, accountType;

  ViewTrashDetails(this.userID, this.trashID, this.accountType);

  @override
  _ViewTrashDetailsState createState() => _ViewTrashDetailsState();
}

class _ViewTrashDetailsState extends State<ViewTrashDetails> {
  final userReference = FirebaseFirestore.instance.collection('Users');
  final FirebaseAuth auth = FirebaseAuth.instance;
  late List trashTypesList;

  Widget trashTypesFilter(TrashPickUpsModel trashPickUpsModel) {
    return Container(
      height: (trashPickUpsModel.trashTypes.length.toDouble() * 45),
      child: ListView.builder(
          scrollDirection: Axis.vertical,
          physics: BouncingScrollPhysics(),
          itemCount: trashPickUpsModel.trashTypes.length,
          itemBuilder: (BuildContext context, int index) {
            Color trashTypeColor;
            String trashTypeDescription;

            switch (trashPickUpsModel.trashTypes[index]) {
              case "Plastic & Polythene":
                trashTypeColor = Colors.orange.shade700;
                trashTypeDescription = "Plastique et polyéthylène";
                break;
              case "Glass":
                trashTypeColor = Colors.red;
                trashTypeDescription = "Verre";
                break;
              case "Paper":
                trashTypeColor = Colors.blue;
                trashTypeDescription = "Papier";
                break;
              case "Metal & Coconut Shell":
                trashTypeColor = Colors.black;
                trashTypeDescription = "Métal et coquille de noix de coco";
                break;
              case "Clinical Waste":
                trashTypeColor = Colors.yellow;
                trashTypeDescription = "Déchets médicaux";
                break;
              case "E-Waste":
                trashTypeColor = Colors.grey.shade200;
                trashTypeDescription = "Déchets électroniques";
                break;
              default:
                trashTypeColor = Colors.grey.shade100;
                trashTypeDescription = "Autres déchets";
            }

            return Padding(
              padding: const EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 10.0),
              child: Row(
                children: [
                  Container(
                    height: 20.0,
                    width: 20.0,
                    color: trashTypeColor,
                  ),
                  SizedBox(
                    width: 10.0,
                  ),
                  Text(trashPickUpsModel.trashTypes[index]),
                ],
              ),
            );
          }),
    );
  }

  trashTitle(String title) {
    return Text(
      title,
      style: TextStyle(
          fontSize: Theme.of(context).textTheme.titleMedium?.fontSize,
          fontWeight: FontWeight.bold),
    );
  }

  trashDetailsData(String detailsData) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 0.0),
      child: Text(
        detailsData,
        style: TextStyle(
            fontSize: Theme.of(context).textTheme.titleMedium?.fontSize,
            fontWeight: FontWeight.normal),
      ),
    );
  }

  trashAvailableDatesTimes(
      bool isDate, String titleS, String dataS, String titleR, String dataR) {
    IconData typeIcon;

    if (isDate) {
      typeIcon = Icons.date_range_rounded;
    } else {
      typeIcon = Icons.access_time_rounded;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              typeIcon,
              size: 35.0,
            ),
            SizedBox(
              width: 10.0,
            ),
            Column(
              children: [
                trashTitle(titleS),
                trashDetailsData(dataS),
              ],
            ),
          ],
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              typeIcon,
              size: 35.0,
            ),
            SizedBox(
              width: 10.0,
            ),
            Column(
              children: [
                trashTitle(titleR),
                trashDetailsData(dataR),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget trashDetails() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection("Users")
          .doc(widget.userID)
          .collection('Trash Pick Ups')
          .where('trashID', isEqualTo: widget.trashID)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          //return profileHeaderShimmer();
          return Text(
            "Données non disponibles",
            style: TextStyle(
                fontSize: Theme.of(context).textTheme.titleLarge?.fontSize,
                fontWeight: FontWeight.bold),
          );
        } else {
          TrashPickUpsModel trashPickUpsModel =
              TrashPickUpsModel.fromDocument(snapshot.data!.docs[0]);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "${trashPickUpsModel.trashName}",
                style: TextStyle(
                    fontSize:
                        Theme.of(context).textTheme.headlineSmall?.fontSize,
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 20.0,
              ),
              ClipRRect(
                borderRadius: BorderRadius.circular(10.0),
                child: Image.network(
                  trashPickUpsModel.trashImage,
                  height: 200.0,
                  width: MediaQuery.of(context).size.width,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(
                height: 20.0,
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  trashTitle("Emplacement de la poubelle"),
                  trashDetailsData(trashPickUpsModel.trashLocationAddress),
                  SizedBox(
                    height: 20.0,
                  ),
                  trashTitle("Description de la poubelle"),
                  trashDetailsData(trashPickUpsModel.trashDescription),
                  SizedBox(
                    height: 20.0,
                  ),
                  trashTitle("Types de dechets"),
                  trashDetailsData(trashPickUpsModel.trashTypes.toString()),
                  trashTypesFilter(trashPickUpsModel),
                  trashAvailableDatesTimes(
                      true,
                      "Date de debut",
                      trashPickUpsModel.startDate,
                      "Date max",
                      trashPickUpsModel.returnDate),
                  SizedBox(
                    height: 20.0,
                  ),
                  trashAvailableDatesTimes(
                      false,
                      "Heure de debut",
                      trashPickUpsModel.startTime,
                      "Heure max",
                      trashPickUpsModel.returnTime),
                  SizedBox(
                    height: 20.0,
                  ),
                  trashTitle("Date de la publication"),
                  trashDetailsData(trashPickUpsModel.postedDate),
                  SizedBox(
                    height: 20.0,
                  ),
                  Center(
                    child: widget.accountType == "Trash Picker"
                        ? MinButtonWidget(
                            text: "Modifier la collecte des déchets",
                            color: Theme.of(context).colorScheme.background,
                            onClicked: () =>
                                {print("Edit Trash Pick Ups Pressed!")},
                          )
                        : Container(),
                  ),
                ],
              ),
            ],
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SecondaryAppBar(
        title: "À propos des déchets",
        appBar: AppBar(),
        widgets: <Widget>[
          Padding(
              padding: const EdgeInsets.fromLTRB(0.0, 0.0, 10.0, 0.0),
              child: Image.asset(
                "assets/icons/icon_trash_sort.png",
                height: 35.0,
                width: 35.0,
              ))
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: trashDetails(),
        ),
      ),
    );
  }
}
