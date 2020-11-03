import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter/material.dart';
import 'package:client/client.dart';
import 'chat.dart';

class ChannelList extends StatefulWidget {
  final String _name;

  ChannelList(this._name);

  @override
  State<ChannelList> createState() => _ChannelListState();
}

class _ChannelListState extends State<ChannelList> {
  final _api = APIClient('http://localhost:8080');
  List<Channel> _channels;

  @override
  void initState() {
    super.initState();
    _api.restClient.getChannels().then((value) => setState(() {
          _channels = value;
        }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Channel list'),
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          tooltip: 'Add a new channel',
          onPressed: () async {
            var channelName = await showTextInputDialog(
              title: 'Please enter a channel name',
              context: context,
              textFields: const [
                DialogTextField(),
              ],
            );

            if (channelName.isEmpty) {
              return;
            }

            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => Chat.newChannel(
                        widget._name, channelName.first, _api)));
          },
        ),
        body: Builder(builder: (context) {
          if (_channels == null) {
            return Center(
                child: Column(
              children: <Widget>[
                CircularProgressIndicator(),
                Text('Loading channels')
              ],
            ));
          }

          return RefreshIndicator(
              onRefresh: () async {
                var channels = await _api.restClient.getChannels();
                setState(() {
                  _channels = channels;
                });
              },
              child: ListView.separated(
                itemCount: _channels.length,
                separatorBuilder: (BuildContext context, int index) =>
                    Divider(),
                itemBuilder: (BuildContext context, int index) {
                  var channel = _channels[index];
                  return ListTile(
                    title: Text(channel.name),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) =>
                                  Chat(widget._name, channel.id, _api)));
                    },
                  );
                },
              ));
        }));
  }
}
