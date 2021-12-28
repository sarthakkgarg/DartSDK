import 'package:web3dart/web3dart.dart';

import '../../common/common.dart';

const String rpcUrl = 'https://rpc.apothem.network/';
const String wsUrl = 'wss://ws.apothem.network/';

const String privateKey =
    '946d6a647742629263f69f18c52ddb1b6b5c19af63e5e9f0c49c19369f6bbef6';

final EthereumAddress contractAddr =
    EthereumAddress.fromHex('0xa2E2acdb050471d3CccC3acF0385EECdEaa6bc6f');
final EthereumAddress receiver =
    EthereumAddress.fromHex('0xd270b44ccf6276dd223b842df9a1c6e5d66d3e1b');

final File abiFile = File(join(dirname(Platform.script.path), 'abi.json'));
final client = Web3Client(rpcUrl, Client(), socketConnector: () {
  return IOWebSocketChannel.connect(wsUrl).cast<String>();
});

// class XRC20 {
void main() async {
  final credentials = await client.credentialsFromPrivateKey(privateKey);
  final ownAddress = await credentials.extractAddress();
  final abiCode = await abiFile.readAsString();
  final contract = DeployedContract(
      ContractAbi.fromJson(abiCode, 'ERC20Interface'), contractAddr);

  final tokenName = contract.function('name');
  final tokenSymbol = contract.function('symbol');
  final tokenDecimals = contract.function('decimals');
  final tokenTotalSupply = contract.function('totalSupply');
  final tokenBalanceOf = contract.function('balanceOf');
  final tokenAllowance = contract.function('allowance');
  final tokenTransaction = contract.function('transfer');
  // final tokenTransferForm = contract.function('transferForm');
  // print(await credentials.extractAddress());

  // name() async {
  final name =
      await client.call(contract: contract, function: tokenName, params: []);
  print('Name : ${name.first}');
  // }

  // void symbol() async {
  final symbol =
      await client.call(contract: contract, function: tokenSymbol, params: []);
  print('Symbol : ${symbol.first}');
  // }

  // void decimals() async {
  final decimals = await client
      .call(contract: contract, function: tokenDecimals, params: []);
  print('Decimals : ${decimals.first}');
  // }

  // void totalSupply() async {
  final totalSupply = await client
      .call(contract: contract, function: tokenTotalSupply, params: []);
  print('totalSupply :  ${totalSupply.first}');
  // }

  // void balanceOf() async {
  final balanceOf = await client
      .call(contract: contract, function: tokenBalanceOf, params: [receiver]);
  print('balanceOf : ${balanceOf.first}');
  // }

  // void allowance() async {
  final allowance = await client.call(
      contract: contract,
      function: tokenAllowance,
      params: [ownAddress, receiver]);
  print('allowance : ${allowance.first}');
  // }

  final transaction = await Transaction.callContract(
      contract: contract,
      function: tokenTransaction,
      parameters: [receiver, BigInt.one]);

  final detail = await client.sendTransaction(credentials, transaction,
      chainId: null, fetchChainIdFromNetworkId: true);

  print(detail);

  // final transferFrom = await Transaction.callContract(
  //     contract: contract,
  //     function: tokenTransferForm,
  //     parameters: [ownAddress, receiver, BigInt.one]);
  // print("Transfer Success");
}
