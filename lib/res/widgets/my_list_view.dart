import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/exhibit_provider.dart';
import '../my_colors.dart';
import '../my_int.dart';
import 'my_padding.dart';

class MyListView {
  static ListView getListOfNotVisitedExhibit(BuildContext context, bool tutorial) {
    var exProvW = context.watch<ExhibitProvider>();
    var exProvR = context.read<ExhibitProvider>();
    var nextExhW = exProvW.nextExhibit;
    var nextExhR = exProvR.nextExhibit;
    double pTop = tutorial ? 8.0 : 20;

    return ListView(
      children: [
        ...List.generate(
            nextExhW.neighbors.length,
            (index) => InkWell(
                  onTap: () {
                    if (tutorial) {
                      exProvR.setProssimoForTutorial(nextExhR.neighbors[index]);
                    } else {
                      exProvR.setExhibit(nextExhR.neighbors[index]);
                      exProvR.setDaScansionare();
                      Navigator.pop(context); // Torno a ExhibitPage
                    }
                  },
                  child: Padding(
                    padding: EdgeInsets.only(top: pTop, left: 8.0, right: 8.0, bottom: 8.0),
                    child: SizedBox(
                      height: MyInt.cardHeight,
                      child: Card(
                        color: MyColors.otherRowTable,
                        child: MyPadding.getNotVisitedField(nextExhW.neighbors[index].normalName),
                      ),
                    ),
                  ),
                )),
      ],
    );
  }
}
