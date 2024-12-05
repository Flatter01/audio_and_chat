import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class FirestoreExample extends StatefulWidget {
  @override
  _FirestoreExampleState createState() => _FirestoreExampleState();
}

class _FirestoreExampleState extends State<FirestoreExample> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> getData() async {
    try {
      QuerySnapshot querySnapshot = await _firestore.collection('users').get();
      // Преобразуем документы в список карт (Map)
      return querySnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    } catch (e) {
      debugPrint("Error fetching data: $e");
      // Показываем Snackbar при ошибке
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching data: $e')),
      );
      rethrow; // Повторно выбрасываем исключение, чтобы FutureBuilder знал о нём
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Firestore Example'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: getData(), // Future, который мы ожидаем
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CupertinoActivityIndicator(),
            );
          } else if (snapshot.hasError) {
            // Если произошла ошибка
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else if (snapshot.hasData) {
            // Если есть данные
            final data = snapshot.data!;
            return ListView.builder(
              itemCount: data.length,
              itemBuilder: (context, index) {
                final user = data[index];
                return Card(
                  child: ListTile(
                    title: Text(user['name'] ?? 'No Name'),
                    subtitle: Text(user['age'] ?? 'No age'),
                  ),
                );
              },
            );
          } else {
            // Если нет данных
            return const Center(
              child: Text('No data found'),
            );
          }
        },
      ),
    );
  }
}
