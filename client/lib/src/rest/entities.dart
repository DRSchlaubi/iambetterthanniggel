import 'package:json_annotation/json_annotation.dart';

part 'entities.g.dart';

/// Representation of a channel.
@JsonSerializable()
class Channel {
  /// The name of the channel
  final String name;

  /// The id of the channel
  final String id;

  /// For internal use only ///

  const Channel(this.name, this.id);

  factory Channel.fromJson(Map<String, dynamic> json) =>
      _$ChannelFromJson(json);

  Map<String, dynamic> toJson() => _$ChannelToJson(this);
}
