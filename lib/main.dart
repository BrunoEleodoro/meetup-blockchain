import 'package:flutter/material.dart';
import 'package:meetup_ethereum/utils/ethereum_utils.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ethereum Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController controller = TextEditingController();
  var resultado = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Ethereum teste',
        ),
      ),
      body: SingleChildScrollView(
          child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextFormField(
              controller: controller,
              decoration: InputDecoration(
                  border: OutlineInputBorder(), labelText: 'Insira o numero'),
            ),
            SizedBox(
              height: 20,
            ),
            MaterialButton(
                color: Colors.amber,
                onPressed: () async {
                  var number = controller.text;
                  var numberBig = BigInt.from(int.parse(number));

                  var privateKey =
                      "81BD767C9FAC9E62C9E3B62CE10C99A7416FA233224572754CCA9373B78CA2CF";

                  var res = await EthereumUtils.sendInformationToContract(
                      privateKey, "store", [numberBig]);

                  print(res);
                },
                child: Text('ENVIAR DADOS PARA BLOCKCHAIN')),
            SizedBox(
              height: 20,
            ),
            MaterialButton(
                color: Colors.amber,
                onPressed: () async {
                  var privateKey =
                      "81BD767C9FAC9E62C9E3B62CE10C99A7416FA233224572754CCA9373B78CA2CF";
                  var res = await EthereumUtils.getInformationFromContract(
                      privateKey, "retreive", []);

                  setState(() {
                    resultado = res[0].toString();
                  });
                },
                child: Text('RECEBER DADOS PARA BLOCKCHAIN')),
            Text(
              'Resultado=' + resultado,
              style: TextStyle(fontSize: 25),
            )
          ],
        ),
      )),
    );
  }
}
