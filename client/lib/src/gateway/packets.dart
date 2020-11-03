import 'package:json_annotation/json_annotation.dart';

part 'packets.g.dart';

/// Representation of Websocket packet
class WebsocketPacket<T> {
  /// The OPCode of the packet
  final OPCode code;

  /// The data payload
  final WebSocketData data;

  // For internal use only //

  WebsocketPacket(this.code, {this.data});

  Map<String, dynamic> toJson() => <String, dynamic>{
        'op': code.toString().substring(7),
        'd': data?.toJson() ?? <String, dynamic>{}
      };

  factory WebsocketPacket.fromJson(dynamic map) {
    var opCode = map['op'];
    var data = map['d'];

    if (opCode == 'messageCreate') {
      return WebsocketPacket(OPCode.messageCreate,
          data: MessageCreateData.fromJson(data));
    } else if (opCode == 'userJoined') {
      return WebsocketPacket(OPCode.userJoined,
          data: UserJoinedPacketData.fromMap(data));
    } else if (opCode == 'userLeft') {
      return WebsocketPacket(OPCode.userLeft,
          data: UserLeftPacketData.fromMap(data));
    } else if (opCode == 'hello') {
      return WebsocketPacket(OPCode.hello,
          data: HelloPacketData.fromJson(data));
    }
    throw 'Invalid packet $opCode';
  }
}

/// OPCodes for gateway
enum OPCode {
  // Command indicating request to gracefully close connection
  close,
  // Event indicating creation of a new message
  messageCreate,
  // Event indicating that a new user has joined
  userJoined,
  // Event indicating that a user has left
  userLeft,
  // Welcome packent containing channel data
  hello
}

/// Abstract data payload
abstract class WebSocketData {
  const WebSocketData();

  Map<String, dynamic> toJson();
}

/// Payload for new message
@JsonSerializable()
class MessageCreateData extends WebSocketData {
  /// The content of the message
  final String content;

  /// The name of the user creating the message
  final String author;

  /// Internal methods ///

  MessageCreateData(this.content, this.author);

  factory MessageCreateData.fromJson(Map<String, dynamic> map) =>
      _$MessageCreateDataFromJson(map);

  @override
  Map<String, dynamic> toJson() => _$MessageCreateDataToJson(this);
}

/// user join payload
@JsonSerializable()
class UserJoinedPacketData extends WebSocketData {
  /// The user which joined the channel
  final WebsocketUser user;

  /// Internal methods ///
  ///
  const UserJoinedPacketData(this.user);

  factory UserJoinedPacketData.fromMap(Map<String, dynamic> map) =>
      _$UserJoinedPacketDataFromJson(map);

  @override
  Map<String, dynamic> toJson() => _$UserJoinedPacketDataToJson(this);
}

/// user left payload
@JsonSerializable()
class UserLeftPacketData extends WebSocketData {
  /// The user which left the channel
  final WebsocketUser user;

  /// Internal methods ///
  const UserLeftPacketData(this.user);

  factory UserLeftPacketData.fromMap(Map<String, dynamic> map) =>
      _$UserLeftPacketDataFromJson(map);

  @override
  Map<String, dynamic> toJson() => _$UserLeftPacketDataToJson(this);
}

/// Representation of a client connected to a channel
@JsonSerializable()
class WebsocketUser {
  /// The name  of the client
  final String name;

  /// An unique identifier of the client
  final String nonce;

  /// Whether the client is an admin or not
  final bool isAdmin;

  /// Internal methods ///
  ///
  const WebsocketUser(this.name, this.nonce, this.isAdmin);

  factory WebsocketUser.fromJson(Map<String, dynamic> map) =>
      _$WebsocketUserFromJson(map);

  Map<String, dynamic> toJson() => _$WebsocketUserToJson(this);
}

/// Welcome packet to update client data
@JsonSerializable()
class HelloPacketData extends WebSocketData {
  /// The user of this client
  final WebsocketUser user;

  /// The key for this client
  final String key;

  /// The channelId the client connected to
  final String channelId;

  /// The name of the channel the client connected to
  final String channelName;

  /// A list of clients connected to the channel (including this client)
  final List<WebsocketUser> users;

  /// Internal methods ///

  const HelloPacketData(
      this.user, this.key, this.channelId, this.channelName, this.users);

  factory HelloPacketData.fromJson(Map<String, dynamic> map) =>
      _$HelloPacketDataFromJson(map);

  @override
  Map<String, dynamic> toJson() => _$HelloPacketDataToJson(this);
}
