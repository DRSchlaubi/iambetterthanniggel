import 'package:dio/dio.dart';
import 'package:meta/meta.dart';

import 'rest/rest_client.dart';
import 'gateway/gateway.dart';

/// Base class of api wrapper
class APIClient {
  final String _baseUrl;
  final RestClient restClient;

  /// Default constructor
  APIClient(

      /// The base url of the backend server including http(s)
      this._baseUrl)
      : restClient = RestClient(Dio(), baseUrl: _baseUrl);

  /// Creates a new Gateway client for an exisitng channel
  Gateway connectToExistingChannel(
          {

          /// The name of ther user that wants to connect
          @required String name,

          /// The id of the channel you want to connect to
          @required String id}) =>
      Gateway.existingChannel(
          baseUrl: _sanitizeGatewayUrl(_baseUrl), name: name, id: id);

  /// Creates a Gateway client that connects to a new channel
  Gateway createAndConnectToNewChannel(
          {

          /// The name of ther user that wants to connect
          @required String name,

          /// The name of the channel to create
          @required String channelName}) =>
      Gateway.newChannel(
          baseUrl: _sanitizeGatewayUrl(_baseUrl),
          name: name,
          channelName: channelName);

  String _sanitizeGatewayUrl(String string) {
    var uri = Uri.parse(string);
    if (uri.scheme == 'https') {
      return Uri(scheme: 'wss', host: uri.host, port: uri.port, path: uri.path)
          .toString();
    } else {
      return Uri(scheme: 'ws', host: uri.host, port: uri.port, path: uri.path)
          .toString();
    }
  }
}
