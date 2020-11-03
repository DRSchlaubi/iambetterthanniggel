import 'package:flutter/material.dart';
import 'package:iambetterthanniggel/channel_list.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  final TextEditingController _usernameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Please enter a name'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Enter name here thanks'),
            TextField(
              controller: _usernameController,
            )
          ],
        ),
      ),
      floatingActionButton: Builder(
        builder: (context) => FloatingActionButton(
          onPressed: () {
            if (_usernameController.text.isEmpty) {
              Scaffold.of(context).showSnackBar(
                  SnackBar(content: Text('Name cannot be empty!')));
              return;
            }
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        ChannelList(_usernameController.text)));
          },
          tooltip: 'Login',
          child: Icon(Icons.login),
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
