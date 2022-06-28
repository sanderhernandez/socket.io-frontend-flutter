import 'dart:io';

import 'package:band_names/models/models.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Band> Bands = [
    Band(id: '1', name: 'Hillsong', votes: 5),
    Band(id: '2', name: 'New Wine', votes: 1),
    Band(id: '3', name: 'Barak', votes: 2),
    Band(id: '4', name: 'En espiritu y en verdad', votes: 4),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Band Names',
          style: TextStyle(color: Colors.black87),
        ),
        backgroundColor: Colors.white,
      ),
      body: ListView.builder(
        itemCount: Bands.length,
        itemBuilder: (BuildContext context, int index) {
          return _bandTile(Bands[index]);
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add_outlined),
        onPressed: () {
          addNewBand();
        },
      ),
    );
  }

  Widget _bandTile(Band band) {
    return Dismissible(
      key: Key(band.id),
      direction: DismissDirection.startToEnd,
      onDismissed: (direction) {
        // TODO: borrar la banda en el server:
        print('Direction: $direction');
        print('Id Band: ${band.id}');
      },
      background: Container(
        padding: EdgeInsets.all(8),
        // alignment: Alignment.centerLeft,
        color: Colors.red[300],
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Deleting band...',
            style: TextStyle(
                color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ),
      child: ListTile(
        leading: CircleAvatar(
          child: Text(band.name.substring(0, 2)),
          backgroundColor: Colors.blue[100],
        ),
        title: Text(band.name),
        trailing: Text(
          '${band.votes}',
          style: TextStyle(fontSize: 20),
        ),
        onTap: () {
          print('${band.name}: ${band.votes}');
        },
      ),
    );
  }

  addNewBand() {
    final TextEditingController textController = TextEditingController();

    // print('ADDDDDDDDDD');

    /// ANDROID:
    if (!Platform.isAndroid) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('New Band name:'),
            content: TextField(
              controller: textController,
            ),
            actions: [
              MaterialButton(
                child: Text('Add'),
                textColor: Colors.blue,
                elevation: 5,
                onPressed: () {
                  addBandToList(textController.text);
                },
              )
            ],
          );
        },
      );
    }

    /// IOS:
    showCupertinoDialog(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: Text('New Band name:'),
          content: CupertinoTextField(
            controller: textController,
          ),
          actions: [
            CupertinoDialogAction(
              isDefaultAction: true,
              child: Text('Add'),
              // textColor: Colors.blue,
              // elevation: 5,
              onPressed: () {
                addBandToList(textController.text);
              },
            ),
            CupertinoDialogAction(
              isDestructiveAction: true,
              child: Text('Dismiss'),
              // textColor: Colors.blue,
              // elevation: 5,
              onPressed: () => Navigator.pop(context),
            ),
          ],
        );
      },
    );
  }

  addBandToList(String name) {
    print(name);
    if (name.length > 1) {
      // Podemos agregar
      Bands.add(
        Band(id: '${DateTime.now()}', name: name, votes: 0),
      );
    }
    Navigator.pop(context);
  }
}
