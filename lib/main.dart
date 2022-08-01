import 'dart:async';

import 'package:crypto_challenge/models/models.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final List<Crypto> items = [];
  StreamSubscription listenChanges() {
    var dio = Dio();
    return Timer.periodic(const Duration(seconds: 20), (timer) {
      dio
          .get('https://api.coingecko.com/api/v3/coins/markets?vs_currency=eur')
          .then((response) {
        final List<Crypto> newItems = List<Crypto>.from(response.data);
        if (newItems.isNotEmpty) {
          setState(() {
            items.clear();
            items.addAll(newItems);
          });
        }
      });
    })
  }

  Future _getcryptos() async {
    var dio = Dio();
    var response = dio
        .get('https://api.coingecko.com/api/v3/coins/markets?vs_currency=eur')
        .asStream();
    var data = response.listen((event) {
      List<Crypto>.from(event.data);
    });
    return data;
  }

  @override
  void initState() {
    super.initState();
    listenChanges().listen((event) {
      print(event.data);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) {
          return Card(
            child: ListTile(
              title: Text(items[index].name),
              subtitle: Text(items[index].symbol),
              leading: Image.network(
                items[index].image,
                width: 40,
                height: 40,
                scale: 0.8,
              ),
              trailing: Text(items[index].currentPrice.toString(),
                  style: TextStyle(
                      color: items[index].priceChange24H > 0
                          ? Colors.green
                          : Colors.red)),
            ),
          );
        },
      ),
    );
  }
}
