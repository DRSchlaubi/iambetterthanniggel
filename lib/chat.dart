import 'package:flutter/material.dart';
import 'package:iambetterthanniggel/gateway/gateway.dart';
import 'package:iambetterthanniggel/gateway/packets.dart';

class Chat extends StatelessWidget {
  final TextEditingController _messageController = TextEditingController();
  final Gateway _gateway;
  final List<MessageReceive> _messages = <MessageReceive>[];

  Chat(String name) : _gateway = Gateway(name: name);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onExit,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Chat'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              StreamBuilder(
                  stream: _gateway.messages,
                  builder: (BuildContext context,
                      AsyncSnapshot<MessageReceive> message) {
                    if (!message.hasData) {
                      return Container();
                    }
                    _messages.add(message.data);
                    return Container(
                      height: 150,
                      child: ListView(
                        children: _messages
                            .map((msg) => Text('${msg.author}: ${msg.content}'))
                            .toList(),
                      ),
                    );
                  }),
              Text('Enter message here:'),
              TextField(
                controller: _messageController,
              )
            ],
          ),
        ),
        floatingActionButton: Builder(builder: (context) {
          return FloatingActionButton(
            onPressed: () {
              if (_messageController.text.isEmpty) {
                Scaffold.of(context).showSnackBar(
                    SnackBar(content: Text('Messsage cannot be empty!')));
                return;
              }
              _gateway.send(WebsocketPacket(OPCode.messageCreate,
                  data: MessageCreateData(_messageController.text)));
              _messageController.text = "";
            },
            tooltip: 'Send',
            child: Icon(Icons.send),
          );
        }), // This trailing comma makes auto-formatting nicer for build methods.
      ),
    );
  }

  Future<bool> _onExit() async {
    print("exit");
    _gateway.send(WebsocketPacket(OPCode.close));
    return true;
  }
}
