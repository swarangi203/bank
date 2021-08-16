// ignore: avoid_web_libraries_in_flutter
import 'dart:html';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:web3dart/credentials.dart';
import 'package:web3dart/web3dart.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ether Bank',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Your Bank!'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Client httpclient;
  Web3Client ethclient;
  final myAddress = '0xcb365565F45fF6607d122Ef9e3C6ce9b53b1D378';
  var myData;
  int amount = 10;
  bool data = false;

  @override
  void initState() {
    super.initState();
    httpclient = Client();
    ethclient = Web3Client(
        'https://rinkeby.infura.io/v3/fe41bbf6a1394d72afa28df653eedcd1',
        httpclient);
    getBalance(myAddress);
  }

  Future<DeployedContract> loadContract() async {
    String abi = await rootBundle.loadString('abi.json');
    String contactAddress = '0x730b11cFA88dDFaeEab598b8eE59844fD62F6C9b';
    final contract = DeployedContract(
        ContractAbi.fromJson(abi, 'FirstContract'),
        EthereumAddress.fromHex(contactAddress));
    return contract;
  }

  Future<List<dynamic>> query(String functionname, List<dynamic> args) async {
    final contract = await loadContract();
    final ethfunction = contract.function(functionname);
    final result = await ethclient.call(
        contract: contract, function: ethfunction, params: args);
    return result;
  }

  Future<void> getBalance(String targetAddress) async {
    EthereumAddress address = EthereumAddress.fromHex(targetAddress);
    List<dynamic> result = await query('getBalance', []);
    myData = result[0];
    data = true;
    setState(() {});
  }

  Future<String> submit(String functionname, List<dynamic> args) async {
    EthPrivateKey privateKey = EthPrivateKey.fromHex(
        '76555029ede81103055bfaf86ef8fb5776e7a37f8e7f329a229e9d1f05943806');
    DeployedContract contract = await loadContract();
    final ethfunction = contract.function(functionname);
    final result = await ethclient.sendTransaction(
        privateKey,
        Transaction.callContract(
          contract: contract,
          function: ethfunction,
          parameters: args,
          from: EthereumAddress.fromHex(myAddress),
        ),
        chainId: 4);
    return result;
  }

  Future<String> depositCoin() async {
    var response = await submit('depositBalance', [BigInt.from(amount)]);
    return response;
  }

  Future<String> withdrawCoin() async {
    var response = await submit('creditBalance', [BigInt.from(amount)]);
    return response;
  }

  final myController = TextEditingController();
  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    myController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Column(
          children: [
            Expanded(
              flex: 1,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.blue,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(50.0),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    child: Center(
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: Text(
                              'Your Balance',
                              style: TextStyle(
                                  fontSize: 30,
                                  color: Colors.grey.shade700,
                                  fontFamily: 'Montserrat'),
                            ),
                          ),
                          Text(
                            '$myData \$',
                            style: TextStyle(
                              fontSize: 70,
                              color: Colors.grey.shade700,
                            ),
                          )
                        ],
                      ),
                    ),
                    height: 200,
                    width: 500,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Container(
                child: Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(35.0),
                        child: Container(
                          height: 100,
                          width: 200,
                          color: Colors.deepPurple,
                          child: Center(
                            child: FlatButton.icon(
                              icon: Icon(CupertinoIcons.refresh),
                              label: Text('Refresh',style: TextStyle(
                                fontSize: 20,
                                  fontFamily: 'Montserrat'
                              ),),
                              onPressed: () {
                                getBalance(myAddress);
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(35.0),
                        child: Container(
                          height: 100,
                          width: 200,
                          color: Colors.green,
                          child: Center(
                            child: FlatButton.icon(
                              icon: Icon(CupertinoIcons.add),
                              label: Text('Deposit 10', style: TextStyle(
                                fontSize: 20,
                                  fontFamily: 'Montserrat'
                              ),),
                              onPressed: () {
                                depositCoin();
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(35.0),
                        child: Container(
                          height: 100,
                          width: 200,
                          color: Colors.red,
                          child: Center(
                            child: FlatButton.icon(
                              icon: Icon(CupertinoIcons.delete_left),
                              label: Text('Withdraw 10', style: TextStyle(
                                fontSize: 20,
                                  fontFamily: 'Montserrat'
                              ),),
                              onPressed: () {
                                withdrawCoin();
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                decoration: BoxDecoration(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
