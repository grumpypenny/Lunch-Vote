import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lunch Picker',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Lunch Picker'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController newPlaceController = TextEditingController();
  // default dropdown value
  String dropDownValue = "Select Known Restaurants";
  // fetch these two from backend to get list of places and current votes
  List<String> restaurants = ["Select Known Restaurants", "A", "B", "C", "D"];
  // create dict that maps place name to # votes + color
  Map<String, Color> colourMap = {};

  // this map shows the votes (Get from DB) default to only cafe
  Map<String, double> dataMap = {
    "Cafe": 0,
  };

  String myVote = "";

  Color selectedColor = Colors.teal;

  void _setVote(String name, Color colour) {
    setState(() {
      selectedColor = colour;

      if (myVote != "") {
        // this is a changed vote
        // decrease vote by 1
        dataMap.update(myVote, (value) => --value);
      }
      myVote = name;
      // add input to the piechart
      dataMap.update(
        name,
        (value) => ++value,
        ifAbsent: () => 1,
      );
    });
  }

  void _addNewOption(String name, Color colour) {
    setState(() {
      // add option as button
      Map<String, Color> newEntry = {name: colour};
      colourMap.addEntries(newEntry.entries);
      // add input to the piechart
      if (myVote != "") {
        // this is a changed vote
        // decrease vote by 1
        dataMap.update(myVote, (value) => --value, ifAbsent: () => 0);
      }
      myVote = name;
      dataMap.update(
        name,
        (value) => ++value,
        ifAbsent: () => 1,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: selectedColor,
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
          child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            PieChart(
              dataMap: dataMap,
              chartRadius: 300,
            ),
            for (var entry in colourMap.entries)
              Container(
                  margin: const EdgeInsets.all(10),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: entry.value,
                        minimumSize: const Size(300, 60)),
                    child: Text(
                      entry.key,
                      style: const TextStyle(color: Colors.white),
                    ),
                    onPressed: () => _setVote(entry.key, entry.value),
                  )),
            Container(
                margin: const EdgeInsets.all(10),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      minimumSize: const Size(300, 60)),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.add),
                    DropdownButton<String>(
                      value: dropDownValue,
                      items: restaurants.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (_) {
                        setState(() {
                          dropDownValue = _.toString();
                        });
                      },
                    )
                  ]),
                  onPressed: () =>
                      {_addNewOption(dropDownValue, Colors.greenAccent)},
                )),
            // Add New Place button
            Container(
                margin: const EdgeInsets.all(10),
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        minimumSize: const Size(300, 60)),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      const Icon(Icons.add),
                      Flexible(
                        child: SizedBox(
                            width: 240,
                            child: TextField(
                              controller: newPlaceController,
                              decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  hintText: "Add new place"),
                            )),
                      )
                    ]),
                    onPressed: () => {
                          if (newPlaceController.text != "")
                            {
                              _addNewOption(
                                  newPlaceController.text, Colors.tealAccent),
                            }
                        }))
          ],
        ),
      )),
    );
  }
}
