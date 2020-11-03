// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rest_client.dart';

// **************************************************************************
// RetrofitGenerator
// **************************************************************************

class _RestClient implements RestClient {
  _RestClient(this._dio, {this.baseUrl}) {
    ArgumentError.checkNotNull(_dio, '_dio');
  }

  final Dio _dio;

  String baseUrl;

  @override
  Future<List<Channel>> getChannels() async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _data = <String, dynamic>{};
    final _result = await _dio.request<List<dynamic>>('/channels',
        queryParameters: queryParameters,
        options: RequestOptions(
            method: 'GET',
            headers: <String, dynamic>{},
            extra: _extra,
            baseUrl: baseUrl),
        data: _data);
    var value = _result.data
        .map((dynamic i) => Channel.fromJson(i as Map<String, dynamic>))
        .toList();
    return value;
  }

  @override
  Future<void> sendMessage(channelId, authKey, content) async {
    ArgumentError.checkNotNull(channelId, 'channelId');
    ArgumentError.checkNotNull(authKey, 'authKey');
    ArgumentError.checkNotNull(content, 'content');
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _data = content;
    await _dio.request<void>('/channels/$channelId/messages',
        queryParameters: queryParameters,
        options: RequestOptions(
            method: 'POST',
            headers: <String, dynamic>{r'Authorization': authKey},
            extra: _extra,
            baseUrl: baseUrl),
        data: _data);
    return null;
  }

  @override
  Future<List<MessageCreateData>> retrieveMessages(channelId, authKey) async {
    ArgumentError.checkNotNull(channelId, 'channelId');
    ArgumentError.checkNotNull(authKey, 'authKey');
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _data = <String, dynamic>{};
    final _result = await _dio.request<List<dynamic>>(
        '/channels/$channelId/messages',
        queryParameters: queryParameters,
        options: RequestOptions(
            method: 'GET',
            headers: <String, dynamic>{r'Authorization': authKey},
            extra: _extra,
            baseUrl: baseUrl),
        data: _data);
    var value = _result.data
        .map((dynamic i) =>
            MessageCreateData.fromJson(i as Map<String, dynamic>))
        .toList();
    return value;
  }
}
