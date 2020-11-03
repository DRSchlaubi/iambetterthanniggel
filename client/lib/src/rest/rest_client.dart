import 'package:retrofit/http.dart';
import 'package:dio/dio.dart';

import 'entities.dart';
import '../gateway/packets.dart';

part 'rest_client.g.dart';

/// Wrapper for API Rest endpoints
@RestApi()
abstract class RestClient {
  /// For internal use only
  /// See [APIClient]
  factory RestClient(Dio dio, {String baseUrl}) = _RestClient;

  /// Retrieves a [List] of available [Channels].
  @GET('/channels')
  Future<List<Channel>> getChannels();

  /// Sends a new message into the channel.
  @POST('/channels/{channelId}/messages')
  Future<void> sendMessage(

      /// The id of the channel to send the message to
      @Path('channelId') String channelId,

      /// The auth key of the user sending the message (Must start with Bearer)
      @Header('Authorization') String authKey,

      /// The content of the message
      @Body() String content);

  /// Retrieves a [List] of [MessageCreateData] storing all messages known for this channel
  @GET('/channels/{channelId}/messages')
  Future<List<MessageCreateData>> retrieveMessages(

      /// The id of the channel
      @Path('channelId') String channelId,

      /// The auth key of the user requesting the messages
      @Header('Authorization') String authKey);
}
