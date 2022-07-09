import 'package:flutter/material.dart';

import 'package:socket_io_client/socket_io_client.dart' as IO;

enum ServerStatus {
  Online,
  Offline,
  Connecting,
}

class SocketService with ChangeNotifier {
  ServerStatus _serverStatus = ServerStatus.Connecting;
  late IO.Socket _socket;

  ServerStatus get serverStatus => this._serverStatus;

  IO.Socket get socket => this._socket;
  Function get emit => this._socket.emit;

  SocketService() {
    this._initConfig();
  }

  void _initConfig() {
    // Dart client Codigo para socket_io_client: ^1.0.2 para Dart -> sdk: ">=2.12.0 <3.0.0"
    this._socket = IO.io(
        'http://192.168.2.203:3000',
        IO.OptionBuilder()
            .setTransports(['websocket']) // for Flutter or Dart VM
            .enableAutoConnect() // .disableAutoConnect() // disable auto-connection
            .setExtraHeaders({'foo': 'bar'}) // optional
            .build());
    // socket.connect();

    // socket.onConnect((_) {
    //   print('connect');
    //   socket.emit('msg', 'test');
    // });
    // socket.on('event', (data) => print(data));
    // socket.onDisconnect((_) => print('disconnect'));
    // socket.on('fromServer', (_) => print(_));

    this._socket.on('connect', (_) {
      // print('connect');
      this._serverStatus = ServerStatus.Online;
      notifyListeners();
    });

    this._socket.on('disconnect', (_) {
      // print('disconnect');
      this._serverStatus = ServerStatus.Offline;
      notifyListeners();
    });

    // this._socket.on('nuevo-mensaje', (payload) {
    //   print('nuevo-mensaje:');
    //   print('nombre: ${payload['nombre']}');
    //   print('mensaje: ${payload['mensaje']}');
    //   print(payload.containsKey('mensaje2')
    //       ? payload['mensaje2']
    //       : 'La clave mensaje2 no se envió');
    //
    //   this._serverStatus = ServerStatus.Offline;
    //   notifyListeners();
    // });

    // // Dart client: Codigo para socket_io_client: ^0.9.10 para Dart -> sdk: ">=2.7.0 <3.0.0"
    // this._socket = IO.io('http://192.168.2.203:3000', {
    //   'transports': ['websocket'],
    //   'autoConnect': true
    // });
    //
    // this._socket.on('connect', (_) {
    //   print('connect');
    //   this._serverStatus = ServerStatus.Online;
    //   notifyListeners();
    // });
    //
    // this._socket.on('disconnect', (_) {
    //   print('disconnect');
    //   this._serverStatus = ServerStatus.Offline;
    //   notifyListeners();
    // });
  }
}
