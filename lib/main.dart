import 'package:dictionary_app/views/screen.dart';
import 'package:flutter/material.dart';
void main(){
  runApp(myApp());

}class myApp extends StatelessWidget {
  const myApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: DictionaryScreen(),
    );
  }
}
