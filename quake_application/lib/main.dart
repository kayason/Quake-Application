import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quake App',
      theme: ThemeData(
        primarySwatch: Colors.orange,
      ),
      home: QuakeListScreen(),
    );
  }
}

class QuakeListScreen extends StatefulWidget {
  @override
  _QuakeListScreenState createState() => _QuakeListScreenState();
}

class _QuakeListScreenState extends State<QuakeListScreen> {
  late Future<Map<String, dynamic>> _quakesData;

  @override
  void initState() {
    super.initState();
    _quakesData = getQuakesData();
  }

  Future<Map<String, dynamic>> getQuakesData() async {
    String apiUrl =
        "https://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/all_day.geojson";
    http.Response response = await http.get(Uri.parse(apiUrl));
    return json.decode(response.body);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Quake App"),
        centerTitle: true,
      ),
      body: FutureBuilder(
        future: _quakesData,
        builder: (context, AsyncSnapshot<Map<String, dynamic>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            List<dynamic> quakes = snapshot.data!['features'];
            return ListView.builder(
              itemCount: quakes.length,
              padding: const EdgeInsets.all(14.2),
              itemBuilder: (BuildContext context, int index) {
                var quake = quakes[index]['properties'];
                var date = DateFormat.yMMMd().add_jm().format(
                    DateTime.fromMillisecondsSinceEpoch(quake['time']));
                return Column(
                  children: <Widget>[
                    Divider(height: 10.5),
                    ListTile(
                      title: Text(
                        date.toString(),
                        style: TextStyle(
                          color: Colors.amberAccent,
                          fontSize: 24.5,
                          fontWeight: FontWeight.w200,
                        ),
                      ),
                      subtitle: Text(quake['place'].toString()),
                      leading: CircleAvatar(
                        child: Text(quake['mag'].toString()),
                        backgroundColor: Colors.orange,
                      ),
                      onTap: () => _showQuakeDetails(context, quake['title']),
                    ),
                  ],
                );
              },
            );
          }
        },
      ),
    );
  }

  void _showQuakeDetails(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Quake', style: TextStyle(fontSize: 14.0)),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Done"),
            ),
          ],
        );
      },
    );
  }
}
