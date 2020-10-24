class WebsocketPacket<T> {
  final OPCode code;
  final WebSocketData data;

  WebsocketPacket(this.code, {this.data});

  Map<String, dynamic> toJson() =>
      <String, dynamic>{'op': code.toString().substring(7), 'd': data?.toMap() ?? <String, dynamic>{}};

  factory WebsocketPacket.fromJson(dynamic map) {
    var opCode = map['op'];

    if(opCode == 'messageReceive') {
      var data = map['d'];
      var author = data['author'];
      var content = data['content'];
      return WebsocketPacket(OPCode.messageReceive, data: MessageReceive(content, author));
    } else throw 'Invalid packet';

  }
}

enum OPCode { close, messageCreate, messageReceive }

abstract class WebSocketData {
  Map<String, dynamic> toMap();
}

class MessageCreateData extends WebSocketData {
  final String content;

  MessageCreateData(this.content);

  @override
  Map<String, dynamic> toMap() => <String, dynamic>{'content': content};

}

class MessageReceive extends WebSocketData {
  final String content;
  final String author;

  MessageReceive(this.content, this.author);

  @override
  Map<String, dynamic> toMap() => <String, dynamic>{'content': content, 'author': author};

}
