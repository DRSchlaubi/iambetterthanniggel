// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'packets.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MessageCreateData _$MessageCreateDataFromJson(Map<String, dynamic> json) {
  return MessageCreateData(
    json['content'] as String,
    json['author'] as String,
  );
}

Map<String, dynamic> _$MessageCreateDataToJson(MessageCreateData instance) =>
    <String, dynamic>{
      'content': instance.content,
      'author': instance.author,
    };

UserJoinedPacketData _$UserJoinedPacketDataFromJson(Map<String, dynamic> json) {
  return UserJoinedPacketData(
    json['user'] == null
        ? null
        : WebsocketUser.fromJson(json['user'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$UserJoinedPacketDataToJson(
        UserJoinedPacketData instance) =>
    <String, dynamic>{
      'user': instance.user,
    };

UserLeftPacketData _$UserLeftPacketDataFromJson(Map<String, dynamic> json) {
  return UserLeftPacketData(
    json['user'] == null
        ? null
        : WebsocketUser.fromJson(json['user'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$UserLeftPacketDataToJson(UserLeftPacketData instance) =>
    <String, dynamic>{
      'user': instance.user,
    };

WebsocketUser _$WebsocketUserFromJson(Map<String, dynamic> json) {
  return WebsocketUser(
    json['name'] as String,
    json['nonce'] as String,
    json['isAdmin'] as bool,
  );
}

Map<String, dynamic> _$WebsocketUserToJson(WebsocketUser instance) =>
    <String, dynamic>{
      'name': instance.name,
      'nonce': instance.nonce,
      'isAdmin': instance.isAdmin,
    };

HelloPacketData _$HelloPacketDataFromJson(Map<String, dynamic> json) {
  return HelloPacketData(
    json['user'] == null
        ? null
        : WebsocketUser.fromJson(json['user'] as Map<String, dynamic>),
    json['key'] as String,
    json['channelId'] as String,
    json['channelName'] as String,
    (json['users'] as List)
        ?.map((e) => e == null
            ? null
            : WebsocketUser.fromJson(e as Map<String, dynamic>))
        ?.toList(),
  );
}

Map<String, dynamic> _$HelloPacketDataToJson(HelloPacketData instance) =>
    <String, dynamic>{
      'user': instance.user,
      'key': instance.key,
      'channelId': instance.channelId,
      'channelName': instance.channelName,
      'users': instance.users,
    };
