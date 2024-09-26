import 'package:app_rl/models/exhibit.dart';
import 'package:app_rl/models/exhibit_list.dart';
import 'package:app_rl/providers/exhibit_provider.dart';
import 'package:app_rl/res/my_colors.dart';
import 'package:app_rl/res/my_widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../providers/energy_provider.dart';
import '../res/my_button.dart';
import '../res/my_int.dart';

class AlreadyVisitedPage extends StatefulWidget {
  const AlreadyVisitedPage({super.key});

  @override
  State<AlreadyVisitedPage> createState() => _AlreadyVisitedPageState();
}

class _AlreadyVisitedPageState extends State<AlreadyVisitedPage> {
  List<String> headers = ["N°", "Nome", "Ambiente", "Alimentazione"];
  late int nPartitaAttuale = 0;

  late List<List<String>> listOfMatch = [];
  late List<int> listOfEnergy = [];
  late List<String> match = [];
  String? selectedMatch; // Variabile per tenere traccia dell'elemento selezionato

  late List<Exhibit> l = [];
  late List<Exhibit> actualList = [];
  late int energyToDisplay = EnergyProvider.maxEnergy;

  void loadData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      late int nPartite = prefs.getInt("nMatch") ?? 0;  //Recupero il numero di partite
      for(int i = 1; i <= nPartite; i++){ //La prima partita viene salvata come Game-1
        match = prefs.getStringList("Game-$i-match") ?? []; //se è null non prendo niente
        listOfEnergy.add(prefs.getInt("Game-$i-energy") ?? EnergyProvider.maxEnergy - match.length);
        listOfMatch.add(match);
      }
      nPartitaAttuale = listOfMatch.length ;
      selectedMatch = nPartitaAttuale.toString();
      actualList = context.read<ExhibitProvider>().visited;
      l = actualList;
    });
  }

  @override
  void initState() {
    super.initState();
    loadData();
  }

  List<Exhibit> getRelativeListOfExhibit(List<String> l){
    List<Exhibit> retList = [];
    for(String exName in l){ retList.add(ExhibitList.getExhibitByName(exName)); }
    return retList;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.backgroundYellow,
      appBar: AppBar(title: const Text("Cosa hai già visitato")),
      body: Padding(
        padding: const EdgeInsets.all(2.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 8.0, bottom: 18.0, left: 8.0, right: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 5,
                              child: DropdownButton<String>(
                                hint: const Text("Seleziona una partita"),
                                value: selectedMatch,
                                items: List.generate(
                                    listOfMatch.length + 1,
                                        (index)
                                        {
                                          final gameLabel = index == listOfMatch.length ? "Partita attuale" : "Partita ${index + 1}";
                                          return DropdownMenuItem<String>(
                                            value: index.toString(),
                                            child: Text(gameLabel),
                                          );
                                        }),
                                onChanged: (String? newValue){
                                  setState(() {
                                    selectedMatch = newValue;
                                    if(newValue == null || int.parse(newValue) == listOfMatch.length){
                                      l = actualList;
                                      energyToDisplay = context.read<EnergyProvider>().energy;
                                    }
                                    else{
                                      l = getRelativeListOfExhibit(listOfMatch[int.parse(newValue)]);
                                      energyToDisplay = listOfEnergy[int.parse(newValue)];
                                    }
                                  });

                                },
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: MyWidgets.getBattery(
                                  charge: energyToDisplay,
                                  batterySize: const Size(100, 45)
                              ),
                            )
                          ],
                        )
                    ),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          MyWidgets.getAlreadyVisitedField("N°", 0, true),
                          MyWidgets.getAlreadyVisitedField("Nome", 1, true),
                          MyWidgets.getAlreadyVisitedField("Ambiente", 2, true),
                          MyWidgets.getAlreadyVisitedField("Alimentazione", 3, true),
                        ]),

                    //Animali visti
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: Column(
                          children: List.generate(
                              l.length,
                              (index) => Row(
                                    children: [
                                      MyWidgets.getAlreadyVisitedField(index.toString(), 0, false),
                                      MyWidgets.getAlreadyVisitedField(l[index].normalName, 1, false),
                                      MyWidgets.getAlreadyVisitedField(l[index].loc, 2, false),
                                      MyWidgets.getAlreadyVisitedField(l[index].alim, 3, false),
                                    ],
                                  )),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            context.watch<ExhibitProvider>().nextIsWinnerExhibit() || context.watch<EnergyProvider>().energy == 0
                ? MyButton.restartButton(context, true)
                : MyButton.notVisitedButton(context),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
          color: MyColors.backgroundYellow,
          height: MyInt.bottomBarHeight.toDouble(),
          child: MyWidgets.getBattery(
              charge: context.watch<EnergyProvider>().energy,
              batterySize: MyInt.batterySize
          )
      ),
    );
  }
}
