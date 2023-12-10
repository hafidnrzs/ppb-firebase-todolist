// ignore_for_file: no_leading_underscores_for_local_identifiers

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'todo.dart';

class ItemList extends StatelessWidget {
  final String transaksiDocId;
  final Todo todo;
  const ItemList({super.key, required this.todo, required this.transaksiDocId});

  @override
  Widget build(BuildContext context) {
    FirebaseFirestore _firestore = FirebaseFirestore.instance;
    CollectionReference todoCollection = _firestore.collection('Todos');
    TextEditingController _titleController = TextEditingController();
    TextEditingController _descriptionController = TextEditingController();

    Future<void> deleteTodo() async {
      await _firestore.collection('Todos').doc(transaksiDocId).delete();
    }

    Future<void> updateTodo() async {
      await _firestore.collection('Todos').doc(transaksiDocId).update({
        'title': _titleController.text,
        'description': _descriptionController.text,
      });
    }

    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Update Todo'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller:
                      // ignore: unnecessary_null_comparison
                      todo.title == null ? _titleController : _titleController
                        ..text = todo.title,
                  decoration: const InputDecoration(
                    hintText: 'Title',
                  ),
                ),
                TextField(
                  // ignore: unnecessary_null_comparison
                  controller: todo.description == null
                      ? _descriptionController
                      : _descriptionController
                    ..text = todo.description,
                  decoration: const InputDecoration(
                    hintText: 'Description',
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Batalkan'),
              ),
              TextButton(
                onPressed: () {
                  updateTodo();
                  Navigator.pop(context);
                },
                child: const Text('Update'),
              ),
            ],
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        height: 100,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              offset: Offset(0, 2),
              blurRadius: 6,
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    todo.title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    todo.description,
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            IconButton(
              onPressed: () {
                todoCollection.doc(transaksiDocId).update({
                  'isComplete': !todo.isComplete,
                });
              },
              icon: Icon(
                todo.isComplete
                    ? Icons.check_box
                    : Icons.check_box_outline_blank,
                color: todo.isComplete ? Colors.blue : Colors.grey,
              ),
            ),
            IconButton(
              onPressed: () {
                deleteTodo();
              },
              icon: const Icon(Icons.delete),
            )
          ],
        ),
      ),
    );
  }
}
