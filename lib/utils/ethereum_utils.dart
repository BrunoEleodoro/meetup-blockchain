import 'dart:async';
import 'dart:collection';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart' as http;
import 'package:hex/hex.dart';

class EthereumUtils {
  static String abiPath = "assets/contracts/abi.json";

  // static Web3Client client = Web3Client(apiUrl, http.Client());
  static Web3Client client = Web3Client(
      "https://rinkeby.infura.io/v3/e00ada770e65428c99cb74546c904353",
      http.Client());

  static Future<DeployedContract> generateContract() {
    Completer<DeployedContract> completer = Completer();

    rootBundle.loadString(abiPath).then((abi) async {
      DeployedContract contract = DeployedContract(
          ContractAbi.fromJson(abi, "Storage"),
          EthereumAddress.fromHex(
              "0x48Ff74D774c04b9E6bB00835D72BE3dE35a24Dda"));
      completer.complete(contract);
    });

    return completer.future;
  }

  static Future<String> sendInformationToContract(
      String privateKey, String action, List parameters) async {
    Completer<String> completer = new Completer();
    DeployedContract contract = await generateContract();
    Credentials credentials = getCredentials(privateKey);
    credentials.extractAddress();
//    print(contract.functions);
    ContractFunction function = contract.function(action);
    await client
        .sendTransaction(
            credentials,
            Transaction.callContract(
                contract: contract,
                function: function,
                maxGas: 500000,
                parameters: parameters),
            chainId: 4)
        .then((hash) {
      completer.complete(hash);
    });
    return completer.future;
  }

  static Future<List> getInformationFromContract(
      privateKey, action, arguments) async {
    DeployedContract contract = await generateContract();
    ContractFunction function = contract.function(action);
    Credentials credentials = getCredentials(privateKey);
    List information = await client.call(
        sender: await credentials.extractAddress(),
        contract: contract,
        function: function,
        params: arguments);
    return information;
  }

  static Future<EthereumAddress> getPublicKey(pvteKey) async {
    EthereumAddress pubKey =
        await EthereumUtils.getCredentials(pvteKey).extractAddress();

    return pubKey;
  }

  //// You can create Credentials from private keys
//Credentials fromHex = EthPrivateKey.fromHex(pvteKeyHematologist);

  static Credentials getCredentials(privKey) {
    Credentials credentials = EthPrivateKey.fromHex(privKey);
    return credentials;
  }

  //// In either way, the library can derive the public key and the address
//// from a private key:
//  var address = await credentials.extractAddress();
//  print(address.hex);
//

  static Future<HashMap> createWallet() async {
    var rng = Random.secure();
    Credentials creds = EthPrivateKey.createRandom(rng);
    Wallet wallet = Wallet.createNew(creds, "senhasupersecreta", rng);
    var address = await creds.extractAddress();
    var add = EthereumAddress.fromHex(address.toString());
    String ppk = HEX.encode(wallet.privateKey.privateKey);
    HashMap obj = HashMap();
    obj['privKey'] = ppk;
    obj['pubKey'] = add;
    return obj;
  }
}
