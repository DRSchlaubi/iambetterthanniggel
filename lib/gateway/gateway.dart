import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:iambetterthanniggel/gateway/packets.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class Gateway {
  final WebSocketChannel _webSocket;
  final StreamController<MessageReceive> _messageStreamController =
      StreamController.broadcast();

  Stream<MessageReceive> get messages => _messageStreamController.stream;

  Gateway({@required String name})
      : _webSocket = IOWebSocketChannel.connect(
            'ws://${throw "Please enter a host"}:8080/ws?name=${Uri.encodeComponent(name)}') {
    _webSocket.stream.listen(_onEvent);
  }

  Future<void> send(WebsocketPacket packet) async =>
      _webSocket.sink.add(jsonEncode(packet.toJson()));

  void _onEvent(dynamic event) {
    print('Recv: $event');
    var json = jsonDecode(event);
    var packet = WebsocketPacket.fromJson(json);
    if (packet.code == OPCode.messageReceive) {
      _messageStreamController.add(packet.data);
    }
  }

  void close() {
    _messageStreamController.close();
  }
}
