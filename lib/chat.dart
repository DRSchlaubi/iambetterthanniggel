import 'dart:async';

import 'package:flutter/material.dart';
import 'package:client/client.dart';
import 'package:dio/dio.dart';

class Chat extends StatefulWidget {
  final Gateway _gateway;
  final APIClient _api;

  Chat(String name, String channelId, this._api)
      : _gateway = _api.connectToExistingChannel(name: name, id: channelId);

  Chat.newChannel(String name, String channelName, this._api)
      : _gateway = _api.createAndConnectToNewChannel(
            name: name, channelName: channelName);

  @override
  State<Chat> createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  final TextEditingController _messageController = TextEditingController();
  final List<MessageCreateData> _messages = <MessageCreateData>[];

  List<WebsocketUser> _users = <WebsocketUser>[];
  StreamSubscription _listener;
  HelloPacketData _helloPacket;
  BuildContext _scaffoldContext;

  @override
  void initState() {
    super.initState();
    _listener = widget._gateway.events.listen(_onEvent);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onExit,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Chat: ${_helloPacket?.channelName ?? ''}'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                height: 150,
                child: ListView(
                  children: _messages
                      .map((msg) => Text('${msg.author}: ${msg.content}'))
                      .toList(),
                ),
              ),
              Text('Enter message here:'),
              TextField(
                controller: _messageController,
              ),
              Text('Users in channel: ${_users.map((e) => e.toJson())}')
            ],
          ),
        ),
        floatingActionButton: Builder(builder: (context) {
          _scaffoldContext = context;
          return FloatingActionButton(
            onPressed: () async {
              if (_helloPacket == null) {
                Scaffold.of(context).showSnackBar(SnackBar(
                    content:
                        Text('Login information has not been received yet!')));
                return;
              }
              if (_messageController.text.isEmpty) {
                Scaffold.of(context).showSnackBar(
                    SnackBar(content: Text('Messsage cannot be empty!')));
                return;
              }
              try {
                widget._api.restClient.sendMessage(_helloPacket.channelId,
                    'Bearer ${_helloPacket.key}', _messageController.text);
              } on DioError catch (e) {
                Scaffold.of(context).showSnackBar(
                    SnackBar(content: Text('Error whilst sending message $e')));
                return;
              }
              _messageController.text = "";
            },
            tooltip: 'Send',
            child: Icon(Icons.send),
          );
        }), // This trailing comma makes auto-formatting nicer for build methods.
      ),
    );
  }

  void _onEvent(WebsocketPacket event) {
    setState(() {
      if (event.code == OPCode.messageCreate) {
        _messages.add(event.data);
      } else if (event.code == OPCode.userJoined) {
        var join = (event.data as UserJoinedPacketData);
        _users.add(join.user);

        if (_helloPacket != null &&
            join.user.nonce != _helloPacket.user.nonce) {
          Scaffold.of(_scaffoldContext).showSnackBar(
              SnackBar(content: Text('${join.user.name} joined the channel!')));
        }
      } else if (event.code == OPCode.userLeft) {
        var leave = (event.data as UserLeftPacketData);
        _users.removeWhere((e) => e.nonce == leave.user.nonce);

        Scaffold.of(_scaffoldContext).showSnackBar(
            SnackBar(content: Text('${leave.user.name} left the channel!')));
      } else if (event.code == OPCode.hello) {
        print(
            '[CHAT] Received HELLO packet finishing inizialization of chat system now');
        var hello = (event.data as HelloPacketData);
        _helloPacket = hello;
        _users = hello.users;
        widget._api.restClient
            .retrieveMessages(_helloPacket.channelId, 'Bearer ${hello.key}')
            .then(
                (messages) => setState(() => _messages.insertAll(0, messages)));
      }
    });
  }

  Future<bool> _onExit() async {
    widget._gateway.send(WebsocketPacket(OPCode.close));
    _listener.cancel();
    return true;
  }
}
