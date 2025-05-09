import 'package:flutter/material.dart';

class Event {
  String name;
  String category;
  String status;

  Event({required this.name, required this.category, required this.status});
}

class EventListPage extends StatefulWidget {
  @override
  _EventListPageState createState() => _EventListPageState();
}

class _EventListPageState extends State<EventListPage> {
  List<Event> events = [
    Event(name: "Birthday", category: "Personal", status: "Upcoming"),
    Event(name: "Graduation", category: "Academic", status: "Past"),
    Event(name: "Eid", category: "Holiday", status: "Current"),
  ];

  String sortBy = "Name";

  void sortEvents() {
    setState(() {
      if (sortBy == "Name") {
        events.sort((a, b) => a.name.compareTo(b.name));
      } else if (sortBy == "Category") {
        events.sort((a, b) => a.category.compareTo(b.category));
      } else if (sortBy == "Status") {
        events.sort((a, b) => a.status.compareTo(b.status));
      }
    });
  }

  void addOrEditEvent({Event? event, int? index}) {
    final nameController = TextEditingController(text: event?.name ?? '');
    final categoryController = TextEditingController(text: event?.category ?? '');
    String status = event?.status ?? 'Upcoming';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(event == null ? "Add Event" : "Edit Event"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: InputDecoration(labelText: "Name")),
            TextField(controller: categoryController, decoration: InputDecoration(labelText: "Category")),
            DropdownButton<String>(
              value: status,
              onChanged: (val) => setState(() => status = val!),
              items: ['Upcoming', 'Current', 'Past'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
            )
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isEmpty || categoryController.text.isEmpty) return;
              final newEvent = Event(
                name: nameController.text,
                category: categoryController.text,
                status: status,
              );
              setState(() {
                if (event == null) {
                  events.add(newEvent);
                } else {
                  events[index!] = newEvent;
                }
              });
              Navigator.pop(context);
            },
            child: Text("Save"),
          ),
        ],
      ),
    );
  }

  void deleteEvent(int index) {
    setState(() {
      events.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    sortEvents();
    return Scaffold(
      appBar: AppBar(
        title: Text("Event List"),
        actions: [
          DropdownButton<String>(
            value: sortBy,
            underline: SizedBox(),
            onChanged: (val) {
              setState(() => sortBy = val!);
              sortEvents();
            },
            items: ['Name', 'Category', 'Status'].map((s) => DropdownMenuItem(value: s, child: Text("Sort by $s"))).toList(),
          )
        ],
      ),
      body: ListView.builder(
        itemCount: events.length,
        itemBuilder: (context, index) {
          final e = events[index];
          return ListTile(
            title: Text(e.name),
            subtitle: Text("${e.category} - ${e.status}"),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(icon: Icon(Icons.edit), onPressed: () => addOrEditEvent(event: e, index: index)),
                IconButton(icon: Icon(Icons.delete), onPressed: () => deleteEvent(index)),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => addOrEditEvent(),
      ),
    );
  }
}
