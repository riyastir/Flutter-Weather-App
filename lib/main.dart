import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weatherapp/home.dart';
import 'package:weatherapp/addNewCity.dart';
import 'package:weatherapp/provider/stateprovider.dart';

void main() => runApp(EntryPoint());


class EntryPoint extends StatefulWidget{
  const EntryPoint({Key key}) : super(key: key);
  @override
  EntryPointState createState() => EntryPointState();
}
class EntryPointState extends State<EntryPoint>{
  
  int _currentIndex = 0;
  final tabs = [
    Home(),
    AddNewCity()
  ];
  static const String _title = 'Weather App';
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: _title, 
      theme: ThemeData(
        primarySwatch: Colors.blue,
        canvasColor: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      home: ChangeNotifierProvider<StateProvider>(
        create: (context) => StateProvider(),
        child: Scaffold(
        //appBar: AppBar(title: const Text(_title)),
        body: tabs[_currentIndex],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          items: [
            BottomNavigationBarItem(icon: Icon(Icons.cloud),title: Text('Weather'),backgroundColor: Colors.blue),
             BottomNavigationBarItem(icon: Icon(Icons.location_city),title: Text('Add City'),backgroundColor: Colors.blue),
          ],
          onTap: (index){
            setState(() {
              _currentIndex = index;
            });
          },
          backgroundColor: Colors.blue[900],
          type: BottomNavigationBarType.fixed,
        ),
      ),)
      
    );
  }
}