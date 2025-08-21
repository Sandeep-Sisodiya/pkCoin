import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:pkcoin/slider_widget.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:web3dart/web3dart.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late Client httpClient;
  late Web3Client ethClient;

  bool data = false;
  int myAmount = 0;
  final String myAddress = "0xC89320E08b883529b4FF691a4c7A9008197e9F31";
  String? txHash;
  dynamic myData;

  @override
  void initState() {
    super.initState();
    httpClient = Client();
    ethClient = Web3Client(
      "https://sepolia.infura.io/v3/5e55f3f1de594a4cbd880463482d60be",
      httpClient,
    );
    getBalance(myAddress);
  }

  Future<DeployedContract> loadContract() async {
    String abi = await rootBundle.loadString("assets/abi.json");
    String contractAddress = "0x95f51fdc85471bc0e377dF6a3C25087b866522Ca";

    return DeployedContract(
      ContractAbi.fromJson(abi, "PKCoin"),
      EthereumAddress.fromHex(contractAddress),
    );
  }

  Future<List<dynamic>> query(String functionName, List<dynamic> args) async {
    final contract = await loadContract();
    final ethFunction = contract.function(functionName);
    return ethClient.call(
      sender: EthereumAddress.fromHex(myAddress),
      contract: contract,
      function: ethFunction,
      params: args,
    );
  }

  Future<void> getBalance(String targetAddress) async {
    List<dynamic> result = await query("getBalance", []);
    print("Balance from contract: ${result[0]}");
    myData = result[0];
    data = true;
    setState(() {

    });
  }

  Future<String> submit(String functionName, List<dynamic> args) async {
    final credentials = EthPrivateKey.fromHex(
      "d9e6ab0832c1a5bc76269118f24112932ef0e33545308b19714f87270c68e97f",
    );
    final contract = await loadContract();
    final ethFunction = contract.function(functionName);

    final result = await ethClient.sendTransaction(
      credentials,
      Transaction.callContract(
        contract: contract,
        function: ethFunction,
        parameters: args,
      ),
      chainId: 11155111,
      fetchChainIdFromNetworkId: false,
    );

    return result;
  }

  Future<void> sendCoin() async {
    var bigAmount = BigInt.from(myAmount);
    txHash = await submit("depositBalance", [bigAmount]);
    print("Deposited");
    await getBalance(myAddress);
  }

  Future<void> withdrawCoin() async {
    var bigAmount = BigInt.from(myAmount);
    txHash = await submit("withdrawBalance", [bigAmount]);
    print("Withdrawn");
    await getBalance(myAddress);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Vx.gray300,
      body: ZStack([
        VxBox()
            .blue600
            .size(context.screenWidth, context.percentHeight * 37)
            .make(),
        VStack([
          (context.percentHeight * 10).heightBox,
          "\$PKCOIN".text.xl4.white.bold.center.makeCentered().py16(),
          (context.percentHeight * 10).heightBox,
          VxBox(
            child: VStack([
              "Balance".text.gray600.xl2.semiBold.makeCentered(),
              10.heightBox,
              data
                  ? "\$${myData}".text.bold.xl5.makeCentered().shimmer()
                  : const CircularProgressIndicator().centered(),
            ]),
          ).p16.white.rounded.size(context.screenWidth, context.percentHeight * 18).make().p16(),
          30.heightBox,
          SliderWidget(
            min: 0,
            max: 100,
            finalValue: (value) {
              myAmount = (value * 100).round();
              print("Slider amount: $myAmount");
            },
          ).centered(),
          HStack(
            [
              TextButton.icon(
                onPressed: () => getBalance(myAddress),
                style: TextButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                ),
                icon: const Icon(Icons.refresh, color: Colors.white),
                label: "Refresh".text.white.make(),
              ).h(50),
              TextButton.icon(
                onPressed: () => sendCoin(),
                style: TextButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                ),
                icon: const Icon(Icons.call_made_outlined, color: Colors.white),
                label: "Deposit".text.white.make(),
              ).h(50),
              TextButton.icon(
                onPressed: () => withdrawCoin(),
                style: TextButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                ),
                icon: const Icon(Icons.call_received_outlined, color: Colors.white),
                label: "Withdraw".text.white.make(),
              ).h(50),
            ],
            alignment: MainAxisAlignment.spaceAround,
            axisSize: MainAxisSize.max,
          ).p16(),
          if (txHash != null) txHash!.text.black.makeCentered().p16(),
        ])
      ]),
    );
  }
}
