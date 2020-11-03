import 'dart:async';
import 'dart:convert';

import 'package:meta/meta.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'packets.dart';
import '../client_base.dart';

/// Wrapper for Chat gateway.
class Gateway {
  final WebSocketChannel _webSocket;
  final StreamController<WebsocketPacket> _eventStreamController =
      StreamController.broadcast();

  /// [Stream] of received [WebsocketPacket]s.
  Stream<WebsocketPacket> get events => _eventStreamController.stream;

  /// For internal use only
  /// See [APIClient.connectToExistingChannel]
  factory Gateway.existingChannel(
          {@required String baseUrl,
          @required String name,
          @required String id}) =>
      Gateway._internal(
          name: name,
          uri: '$baseUrl/channels/$id/ws/?name=${Uri.encodeComponent(name)}');

  /// For internal use only
  /// See [APIClient.createAndConnectToNewChannel]
  factory Gateway.newChannel(
          {@required String baseUrl,
          @required String name,
          @required String channelName}) =>
      Gateway._internal(
          name: name,
          uri:
              '$baseUrl/channels/new/?name=${Uri.encodeComponent(name)}&channel_name=${Uri.encodeComponent(channelName)}');

  Gateway._internal({@required String name, @required String uri})
      : _webSocket = WebSocketChannel.connect(Uri.parse(uri)) {
    _webSocket.stream.listen(_onEvent);
  }

  /// Sends a new [WebsocketPacket] to the gateway.
  Future<void> send(

      /// The [WebsocketPacket] to send
      WebsocketPacket packet) async {
    var packetJson = jsonEncode(packet.toJson());
    print('[WS] Send: $packetJson');
    _webSocket.sink.add(packetJson);
  }

  void _onEvent(dynamic event) {
    print('[WS] Receive: $event');
    var json = jsonDecode(event);
    var packet = WebsocketPacket.fromJson(json);
    _eventStreamController.add(packet);
  }

  /// Closes the resources
  void close() {
    _eventStreamController.close();
  }
}
