import 'dart:io';

import 'package:band_names/models/models.dart';
import 'package:band_names/services/socket_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Band> Bands = [
    // Band(id: '1', name: 'Hillsong', votes: 5),
    // Band(id: '2', name: 'New Wine', votes: 1),
    // Band(id: '3', name: 'Barak', votes: 2),
    // Band(id: '4', name: 'En espiritu y en verdad', votes: 4),
  ];

  @override
  void initState() {
    // TODO: implement initState

    final socketService = Provider.of<SocketService>(context, listen: false);

    socketService.socket.on('active-bands', _handleActiveBands);

    super.initState();
  }

  _handleActiveBands(dynamic payload) {
    setState(() {
      Bands = (payload as List).map((band) => Band.fromMap(band)).toList();
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    final socketService = Provider.of<SocketService>(context, listen: false);
    socketService.socket.off('active-bands');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final socketService = Provider.of<SocketService>(context);

    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Band Names',
          style: TextStyle(color: Colors.black87),
        ),
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(
              socketService.serverStatus == ServerStatus.Online
                  ? Icons.check_circle
                  : Icons.offline_bolt,
              color: socketService.serverStatus == ServerStatus.Online
                  ? Colors.blue[300]
                  : Colors.red[300],
            ),
            onPressed: () {},
          )
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          ShowGraph(bands: Bands),
          Expanded(
            child: ListView.builder(
              itemCount: Bands.length,
              itemBuilder: (BuildContext context, int index) {
                return _bandTile(Bands[index]);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add_outlined),
        onPressed: () {
          addNewBand();
        },
      ),
    );
  }

  // Widget _ShowGraph() {}

  Widget _bandTile(Band band) {
    final socketService = Provider.of<SocketService>(context, listen: false);

    return Dismissible(
      key: Key(band.id),
      direction: DismissDirection.startToEnd,
      onDismissed: (direction) {
        final socketService =
            Provider.of<SocketService>(context, listen: false);
        // TODO: borrar la banda en el server:
        print('Direction: $direction');
        print('Id Band: ${band.id}');

        socketService.socket.emit('delete-band', {'id': band.id});
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
          socketService.socket.emit('vote-band', {'id': band.id});

          print('${band.name}: ${band.id}');
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
    final socketService = Provider.of<SocketService>(context, listen: false);

    // print(name);
    if (name.length > 1) {
      // Podemos agregar
      // Bands.add(Band(id: '${DateTime.now()}', name: name, votes: 0));
      socketService.emit('add-band', {'name': name});
    }
    Navigator.pop(context);
  }
}

class ShowGraph extends StatelessWidget {
  final List<Band> bands;
  const ShowGraph({Key? key, required this.bands}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Map<String, double>? dataMap = new Map<String, double>();

    final List<Color> colorList = [
      Colors.blue.shade50,
      Colors.blue.shade200,
      Colors.pink.shade50,
      Colors.pink.shade200,
      Colors.yellow.shade50,
      Colors.yellow.shade200,
    ];

    //
    // {
    //   "Flutter": 5,
    //   "React": 3,
    //   "Xamarin": 2,
    //   "Ionic": 2,
    // };

    // Mapeando la lista bands para agregarla al mapa o colección dataMap:
    bands.forEach((band) {
      dataMap.putIfAbsent(band.name, () => band.votes.toDouble());
    });

    if (dataMap.isEmpty) {
      return Container(
          width: double.infinity,
          height: 200,
          child: Center(child: CircularProgressIndicator()));
    } else {
      return Container(
        padding: EdgeInsets.only(left: 35, top: 10),
        width: double.infinity,
        height: 200,
        child: PieChart(
          dataMap: dataMap,
          animationDuration: Duration(milliseconds: 800),
          chartLegendSpacing: 32, // espacio entre la leyenda y el Chart
          chartRadius: MediaQuery.of(context).size.width * 0.33,
          // colorList: colorList,
          initialAngleInDegree: 0, // Grados inicial del angulo
          chartType: ChartType.disc,
          ringStrokeWidth: 15, // Gruesor del Chart osea Gráfica.
          centerText: "Popularidad",
          legendOptions: LegendOptions(
            showLegendsInRow: false,
            legendPosition: LegendPosition.right,
            showLegends: true,
            // legendShape: _BoxShape.circle,
            legendTextStyle: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          chartValuesOptions: ChartValuesOptions(
            showChartValueBackground: true,
            chartValueBackgroundColor: Colors.white70,
            showChartValues: true,
            showChartValuesInPercentage: true,
            showChartValuesOutside: true,
            decimalPlaces: 2,
            chartValueStyle: TextStyle(
              color: Colors.black87,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          // gradientList: ---To add gradient colors---
          // emptyColorGradient: ---Empty Color gradient---
        ),
      );
    }
  }
}
