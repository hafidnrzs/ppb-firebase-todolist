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
        'isComplete': false,
      });
    }

    return Container(
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
                  dataList.nama,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 15),
                Text(
                  dataList.deskripsi,
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          const ChecklistButton(),
        ],
      ),
    );
  }
}

class ChecklistButton extends StatefulWidget {
  const ChecklistButton({super.key});

  @override
  State<ChecklistButton> createState() => _ChecklistButtonState();
}

class _ChecklistButtonState extends State<ChecklistButton> {
  bool isChecked = false;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        isChecked ? Icons.check_box : Icons.check_box_outline_blank,
        color: isChecked ? Colors.blue : Colors.grey,
        size: 25,
      ),
      onPressed: () {
        setState(() {
          isChecked = !isChecked;
        });
      },
    );
  }
}
