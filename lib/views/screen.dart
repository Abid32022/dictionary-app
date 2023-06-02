import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class DictionaryScreen extends StatefulWidget {
  const DictionaryScreen({Key? key}) : super(key: key);

  @override
  State<DictionaryScreen> createState() => _DictionaryScreenState();
}

class _DictionaryScreenState extends State<DictionaryScreen> {
  String url = "https://owlbot.info/api/v4/dictionary/";
  String token = "1c508be35c0395d814a741f653a6426947264117";

  TextEditingController textEditingController = TextEditingController();

  StreamController<dynamic> streamController = StreamController<dynamic>();

  late Stream<dynamic> stream;

  Timer? _debounce;

  void searchWord() async {
    String searchText = textEditingController.text.trim();

    if (searchText.isNotEmpty) {
      streamController.add("waiting");

      http.Response response = await http.get(Uri.parse(url + searchText), headers: {"Authorization": "Token " + token},);

      streamController.add(json.decode(response.body));
    } else {
      streamController.add(null); // Clear the stream when the search text is empty
    }
  }


  @override
  void initState() {
    super.initState();
    stream = streamController.stream;
  }

  @override
  void dispose() {
    streamController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          'Dictionary',
          style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(45),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  margin: EdgeInsets.only(bottom: 10, left: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    color: Colors.white,
                  ),
                  child: TextFormField(
                    onChanged: (String text) {
                      if (_debounce?.isActive ?? false) _debounce!.cancel();
                      _debounce = Timer(const Duration(milliseconds: 1000), () {
                        searchWord();
                      });
                    },
                    controller: textEditingController,
                    decoration: InputDecoration(
                      hintText: "Search for a word",
                      contentPadding: EdgeInsets.only(left: 24),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
              IconButton(
                onPressed: () {
                  searchWord();
                },
                icon: Icon(
                  Icons.search,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
      body: Container(
        margin: EdgeInsets.all(8),
        child: StreamBuilder<dynamic>(
          builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
            if (snapshot.data == null) {
              return Center(
                child: Text("Enter a search word"),
              );
            }
            if (snapshot.data == "waiting") {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
            if (snapshot.data is Map<String, dynamic>) {
              var definitions = snapshot.data["definitions"];
              return ListView.builder(
                itemCount: definitions.length,
                itemBuilder: (context, index) {
                  var definition = definitions[index];
                  return ListBody(
                    children: [
                      Container(
                        color: Colors.grey[300],
                        child: ListTile(
                          leading: definition["image_url"] == null
                              ? null
                              : CircleAvatar(
                            backgroundImage:
                            NetworkImage(definition["image_url"]),
                          ),
                          title: Text(
                            textEditingController.text.trim() +
                                "(" +
                                definition["type"] +
                                ")",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            definition["definition"],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              );
            }

            return Center(
              child: Text("No definitions found"),
            );
          },
          stream: stream,
        ),
      ),
    );
  }

}
