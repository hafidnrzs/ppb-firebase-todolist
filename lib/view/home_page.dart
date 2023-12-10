import 'package:base_todolist/model/item_list.dart';
import 'package:base_todolist/view/login_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:base_todolist/model/todo.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() {
    return _HomePageState();
  }
}

class _HomePageState extends State<HomePage> {
  FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseFirestore _firestore = FirebaseFirestore.instance;

  TextEditingController _titleController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  TextEditingController _searchController = TextEditingController();
  bool isComplete = false;

  Future<void> _signOut() async {
    await _auth.signOut();
    runApp(new MaterialApp(
      home: new LoginPage(),
    ));
  }

  Future<QuerySnapshot>? searchResultsFuture;
  Future<void> searchResult(String textEntered) async {
    QuerySnapshot querySnapshot = await _firestore
        .collection("Todos")
        .where("title", isGreaterThanOrEqualTo: textEntered)
        .where("title", isLessThan: textEntered + 'z')
        .get();

    setState(() {
      searchResultsFuture = Future.value(querySnapshot);
    });
  }

  void cleartext() {
    _titleController.clear();
    _descriptionController.clear();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // getTodo();
  }

  @override
  Widget build(BuildContext context) {
    CollectionReference todoCollection = _firestore.collection('Todos');
    final User? user = _auth.currentUser;

    Future<void> addTodo() {
      return todoCollection.add({
        'title': _titleController.text,
        'description': _descriptionController.text,
        'isComplete': isComplete,
        'uid': _auth.currentUser!.uid,
        // ignore: invalid_return_type_for_catch_error
      }).catchError((error) => print("Failed to add todo: $error"));
    }

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Todo List'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Logout'),
                  content: Text('Apakah Anda yakin ingin logout?'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text('Tidak'),
                    ),
                    TextButton(
                        onPressed: () {
                          _signOut();
                        },
                        child: Text('Ya'))
                  ],
                ),
              );
            },
          )
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
            child: TextField(
              decoration: InputDecoration(
                  labelText: 'Search',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder()),
              onChanged: (textEntered) {
                searchResult(textEntered);

                setState(() {
                  _searchController.text = textEntered;
                });
              },
            ),
          ),
          Expanded(
              child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: _searchController.text.isEmpty
                ? _firestore
                    .collection('Todos')
                    .where('uid', isEqualTo: user!.uid)
                    .snapshots()
                : searchResultsFuture != null
                    ? searchResultsFuture!
                        .asStream()
                        .cast<QuerySnapshot<Map<String, dynamic>>>()
                    : Stream.empty(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Center(child: CircularProgressIndicator());
              }
              List<Todo> listTodo = snapshot.data!.docs.map((document) {
                final data = document.data();
                final String title = data['title'];
                final String description = data['description'];
                final bool isComplete = data['isComplete'];
                final String uid = data['uid'];

                return Todo(
                  description: description,
                  title: title,
                  isComplete: isComplete,
                  uid: uid,
                );
              }).toList();

              return ListView.builder(
                shrinkWrap: true,
                itemCount: listTodo.length,
                itemBuilder: (context, index) {
                  return ItemList(
                    todo: listTodo[index],
                    transaksiDocId: snapshot.data!.docs[index].id,
                  );
                },
              );
            },
          ))
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
              context: context,
              builder: (context) => AlertDialog(
                    title: Text('Tambah Todo'),
                    content: SizedBox(
                      width: 200,
                      height: 100,
                      child: Column(
                        children: [
                          TextField(
                              controller: _titleController,
                              decoration:
                                  InputDecoration(hintText: 'Judul Todo')),
                          TextField(
                            controller: _descriptionController,
                            decoration:
                                InputDecoration(hintText: 'Deskripsi Todo'),
                          )
                        ],
                      ),
                    ),
                    actions: [
                      TextButton(
                        child: Text('Batal'),
                        onPressed: () => Navigator.pop(context),
                      ),
                      TextButton(
                        child: Text('Tambah'),
                        onPressed: () {
                          addTodo();
                          cleartext();
                          Navigator.pop(context);
                        },
                      )
                    ],
                  ));
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

// class TodoPage extends StatelessWidget {
//   final Todo dataList;
//   const TodoPage({super.key, required this.dataList});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Todo List'),
//         centerTitle: true,
//       ),
//       body: Column(
//         children: [
//           const Padding(
//             padding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
//             child: TextField(
//               decoration: InputDecoration(
//                 labelText: 'Search',
//                 prefixIcon: Icon(Icons.search),
//                 border: OutlineInputBorder(),
//               ),
//             ),
//           ),
//           Expanded(
//             child: ListView.builder(
//               itemCount: listdata.length,
//               itemBuilder: (context, index) {
//                 return ItemList(
//                   dataList: listdata[index],
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () {
//           showDialog(
//             context: context,
//             builder: (context) => AlertDialog(
//               title: const Text(
//                 'Tambah Data',
//               ),
//               content: const Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   TextField(
//                     decoration: InputDecoration(
//                       labelText: 'Nama Kegiatan',
//                       border: OutlineInputBorder(),
//                     ),
//                   ),
//                   SizedBox(height: 10),
//                   TextField(
//                     decoration: InputDecoration(
//                       labelText: 'Deskripsi Kegiatan',
//                       border: OutlineInputBorder(),
//                     ),
//                   ),
//                 ],
//               ),
//               actions: [
//                 TextButton(
//                   onPressed: () {
//                     Navigator.pop(context);
//                   },
//                   child: const Text('Batal'),
//                 ),
//                 TextButton(
//                   onPressed: () {
//                     Navigator.pop(context);
//                   },
//                   child: const Text('Simpan'),
//                 ),
//               ],
//             ),
//           );
//         },
//         child: const Icon(Icons.add),
//       ),
//     );
//   }
// }
