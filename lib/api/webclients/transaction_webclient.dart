import 'dart:convert';
import 'package:bytebank/api/webclient.dart';
import 'package:bytebank/models/contact.dart';
import 'package:bytebank/models/transaction.dart';
import 'package:http/http.dart';

class TransactioWebClient {
  final String baseUrl = 'http://192.168.0.114:8080';

  Future<List<Transaction>> findAll() async {
    final Response resp =
        await client.get('$baseUrl/transactions').timeout(Duration(seconds: 5));

    final List<dynamic> decodedJson = jsonDecode(resp.body);
    final List<Transaction> transactions = List();

    for (Map<String, dynamic> element in decodedJson) {
      final transaction = Transaction(
        element['value'],
        Contact(
          0,
          element['contact']['name'],
          element['contact']['accountNumber'],
        ),
      );
      transactions.add(transaction);
    }
    return transactions;
  }

  Future<Transaction> save(Transaction transaction) async {
    final transactionMap = {
      'value': transaction.value,
      'contact': {
        'name': transaction.contact.name,
        'accountNumber': transaction.contact.accountNumber
      },
    };
    final transactionJson = json.encode(transactionMap);

    final Response resp = await client.post('$baseUrl/transactions',
        headers: {
          'Content-type': 'application/json',
          'password': '1000',
        },
        body: transactionJson);

    final jsonResp = jsonDecode(resp.body);
    final createdTransaction = Transaction(
      jsonResp['value'],
      Contact(
        0,
        jsonResp['contact']['name'],
        jsonResp['contact']['accountNumber'],
      ),
    );
    return createdTransaction;
  }
}
