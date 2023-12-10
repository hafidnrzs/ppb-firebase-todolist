return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Update Todo'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller:
                      // ignore: unnecessary_null_comparison
                      todo.title == null ? _titleController : _titleController
                        ..text = todo.title,
                  decoration: InputDecoration(
                    hintText: 'Title',
                  ),
                ),
                TextField(
                  // ignore: unnecessary_null_comparison
                  controller: todo.description == null
                      ? _descriptionController
                      : _descriptionController
                    ..text = todo.description,
                  decoration: InputDecoration(
                    hintText: 'Description',
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                child: const Text('Batalkan'),
                onPressed: () => Navigator.pop(context),
              ),
              TextButton(
                child: const Text('Update'),
                onPressed: () {
                  updateTodo();
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },