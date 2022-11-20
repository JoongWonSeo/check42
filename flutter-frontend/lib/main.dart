import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';

class Pair<T1, T2> {
  final T1 a;
  final T2 b;

  Pair(this.a, this.b);
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent, // transparent status bar
  ));
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Check42',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Check42'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  //query variables
  List<String?> airports = [];
  DateTime? departureDate, returnDate;
  int? numAdults, numChildren;
  bool? sortByPrice;

  String server = "http://131.159.216.190:5000";
  List? results;

  List<MultiSelectItem<String?>> _cities = [
    MultiSelectItem<String?>('"MUC"', 'Munich'),
    MultiSelectItem<String?>('"FRA"', 'Frankfurt'),
    MultiSelectItem<String?>('"HAM"', 'Hamburg'),
    MultiSelectItem<String?>('"DUS"', 'Düsseldorf'),
    MultiSelectItem<String?>('"BER"', 'Berlin'),
    MultiSelectItem<String?>('"CGN"', 'Cologne'),
  ];

  void query() async {
    //check args validity
    if (airports.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Please specify one or more airports!"),
        ),
      );
      return;
    }
    if (departureDate != null &&
        returnDate != null &&
        departureDate!.isAfter(returnDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("The departure date must be before the return date!"),
        ),
      );
      return;
    }

    List args = [
      Pair(airports, (List<String?> a) => 'airports=[' + a!.join(',') + ']'),
      Pair(departureDate, (DateTime d) => 'departure_after=' + d.toString()),
      Pair(returnDate, (DateTime d) => 'return_before=' + d.toString()),
      Pair(numAdults, (int n) => 'adults=' + n.toString()),
      Pair(sortByPrice, (bool b) => 'sort_by=' + (b ? 'price' : 'rating'))
    ];

    for (int i = 0; i < args.length; i++) {
      if (args[i].a == null) {
        args.removeAt(i);
        i--;
      }
    }

    String q = server + '/search?' + args.map((p) => p.b(p.a)).join('&');
    print(q);

    try {
      var response = await http.get(Uri.parse(q));
      if (response.statusCode == 200) {
        setState(() {
          print(response.body);
          results = jsonDecode(response.body)['results'];
        });
      }
    } catch (e) {
      //show toast
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching results: " + e.toString())),
      );
    }
  }

  List<Widget> buildResults() {
    List<Widget> widgets = [];
    for (var offer in results!) {
      widgets.add(Card(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              leading: Icon(Icons.hotel),
              title: Text(offer['hotel']),
              subtitle: Text('From ' +
                  offer['airport'] +
                  ' - ' +
                  offer['price'].toString() +
                  '€'),
            ),
            ButtonBar(
              children: <Widget>[
                TextButton(
                  child: const Text('SEE OFFERS'),
                  onPressed: () {/* ... */},
                ),
              ],
            ),
          ],
        ),
      ));
    }
    print(widgets);
    return widgets;
  }

  Widget searchWidget() {
    return Center(
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: MultiSelectBottomSheetField<String?>(
                  items: _cities,
                  onConfirm: (List<String?> values) {
                    airports = values;
                  },
                  searchable: true,
                  buttonIcon: Icon(
                    Icons.location_on,
                    color: Colors.grey,
                  ),
                  buttonText: Text(
                    "Select Departure Airports...",
                    style: TextStyle(color: Colors.grey),
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  chipDisplay: MultiSelectChipDisplay(
                    scroll: true,
                    height: 45,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () async {
                    DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: /*DateTime.now()*/ DateTime
                            .parse('2021-01-01'),
                        lastDate: DateTime.now().add(Duration(days: 365)));
                    if (picked != null) {
                      setState(() {
                        departureDate = picked;
                      });
                    }
                  },
                  icon: Icon(Icons.flight_takeoff),
                  label: Text(departureDate == null
                      ? 'Depart after'
                      : departureDate.toString()),
                  style: ButtonStyle(
                    minimumSize:
                        MaterialStateProperty.all(Size(double.infinity, 50)),
                    backgroundColor: MaterialStateProperty.all(Colors.white),
                    foregroundColor: MaterialStateProperty.all(
                        departureDate == null ? Colors.grey : Colors.black),
                    alignment: Alignment.centerLeft,
                    shape: MaterialStateProperty.all(RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30))),
                  ),
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () async {
                    DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: /*DateTime.now()*/ DateTime
                            .parse('2021-01-01'),
                        lastDate: DateTime.now().add(Duration(days: 365)));
                    if (picked != null) {
                      setState(() {
                        returnDate = picked;
                      });
                    }
                  },
                  icon: Icon(Icons.flight_land),
                  label: Text(returnDate == null
                      ? 'Return before'
                      : returnDate.toString()),
                  style: ButtonStyle(
                    minimumSize:
                        MaterialStateProperty.all(Size(double.infinity, 50)),
                    backgroundColor: MaterialStateProperty.all(Colors.white),
                    foregroundColor: MaterialStateProperty.all(
                        returnDate == null ? Colors.grey : Colors.black),
                    alignment: Alignment.centerLeft,
                    shape: MaterialStateProperty.all(RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30))),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextField(
                  onSubmitted: (q) {
                    numAdults = int.parse(q);
                  },
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly
                  ],
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.group),
                    labelText: 'Adults',
                    floatingLabelBehavior: FloatingLabelBehavior.never,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none),
                    isDense: true,
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: TextField(
                  onSubmitted: (q) {
                    numChildren = int.parse(q);
                  },
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly
                  ],
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.child_care),
                    labelText: 'Children',
                    floatingLabelBehavior: FloatingLabelBehavior.never,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none),
                    isDense: true,
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
              ),
              SizedBox(width: 10),
              Container(
                // background color for the ToggleButtons
                padding: EdgeInsets.zero,
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.all(Radius.circular(30)),
                ),
                child: ToggleButtons(
                  direction: Axis.horizontal,
                  onPressed: (int index) {
                    setState(() {
                      if (sortByPrice == null) {
                        sortByPrice = index == 0;
                      } else {
                        sortByPrice =
                            sortByPrice! == (index == 0) ? null : index == 0;
                      }
                    });
                  },
                  borderRadius: const BorderRadius.all(Radius.circular(30)),
                  // borderColor: Colors.white,
                  selectedColor: Colors.white,
                  fillColor: Colors.blue,
                  selectedBorderColor: Colors.blue,
                  color: Colors.white,
                  constraints: BoxConstraints(minWidth: 60, minHeight: 50),
                  isSelected: [
                    sortByPrice != null && sortByPrice!,
                    sortByPrice != null && !sortByPrice!
                  ],
                  children: [Text('Price'), Text('Rating')],
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          ElevatedButton.icon(
            onPressed: query,
            icon: Icon(Icons.search),
            label: Text('Search Offers'),
            style: ButtonStyle(
              minimumSize: MaterialStateProperty.all(Size(double.infinity, 50)),
              backgroundColor: MaterialStateProperty.all(Colors.blue),
              shape: MaterialStateProperty.all(RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30))),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: RefreshIndicator(
          onRefresh: () {
            //TODO: send API request to get new data
            return Future.delayed(Duration(seconds: 1));
          },
          // edgeOffset: Scaffold.of(context).appBarMaxHeight!,
          child: Stack(children: [
            Center(
              //background
              child: Expanded(child: Container(color: Colors.black)),
            ),
            CustomScrollView(
              slivers: [
                SliverAppBar(
                  pinned: true,
                  // expandedHeight: MediaQuery.of(context).size.height * 1 / 3,
                  expandedHeight: 550,
                  backgroundColor: Color.fromARGB(119, 22, 93, 180),
                  flexibleSpace: FlexibleSpaceBar(
                    background: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        children: [
                          SizedBox(height: 50),
                          Expanded(
                            child: Column(
                              children: [
                                const Text('CHECK42',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 56,
                                        fontStyle: FontStyle.italic,
                                        fontWeight: FontWeight.w900)),
                                const Text(
                                    'Check the answer to life,\nthe universe, \nand everything.',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontStyle: FontStyle.italic,
                                        fontWeight: FontWeight.w300)),
                              ],
                            ),
                          ),
                          searchWidget(),
                          SizedBox(
                              height:
                                  60), //buffer for the title below the search bar
                        ],
                      ),
                    ),
                    collapseMode: CollapseMode.pin,
                    titlePadding: EdgeInsets.all(10),
                    title: Text('Your Trip to Mallorca'),
                  ),
                ),
                SliverList(
                    delegate: results == null
                        ? (SliverChildBuilderDelegate(
                            (context, index) {
                              var col = HSLColor.fromAHSL(
                                      1,
                                      (((index / 50.0) * 360 + 200) % 360),
                                      0.5,
                                      0.5)
                                  .toColor();
                              return SizedBox(
                                height: 100,
                                child: Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(color: col, width: 0),
                                    color: col,
                                  ),
                                ),
                              );
                            },
                          ))
                        : (SliverChildListDelegate(buildResults()))),
              ],
            )
          ]),
        ),
      ),
    );
  }
}
