import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

enum ServerStatus { Offline, Online, Conectando }

class SocketService with ChangeNotifier {
  ServerStatus _serverStatus = ServerStatus.Conectando;
  IO.Socket _socket;

  IO.Socket get socket => this._socket;
  Function get emit => this._socket.emit;

  ServerStatus get serverStatus => this._serverStatus;

  SocketService() {
    _initConfig();
  }

  void _initConfig() {
    // Dart client
    this._socket = IO.io('http://192.168.10.2:8082', {
      'transports': ['websocket'],
      'autoconnect': true
    });

    this._socket.on('connect', (_) {
      //print('conectado');
      this._serverStatus = ServerStatus.Online;
      notifyListeners();
    });

    this._socket.on('disconnect', (_) {
      //print('desconectado');
      this._serverStatus = ServerStatus.Offline;
      notifyListeners();
    });

    // this._socket.on('mensagem', (payload) {
    //   print('mensagem: $payload');
    //   print(payload['nome']);
    //   print(payload.containsKey('sexo') ? payload['sexo'] : 'V');
    // });
  }
}
