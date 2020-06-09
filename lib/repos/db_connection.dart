import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseConnection {
  setDatabase() async {
    var directory = await getApplicationDocumentsDirectory();
    var path = join(directory.path, 'db_weather_app');
    var database =
        await openDatabase(path, version: 1, onCreate: _onCreatingDatabase);
    return database;
  }

  _onCreatingDatabase(Database database, int version) async {
    await database.execute(
        "CREATE TABLE Cities(id INTEGER PRIMARY KEY, name TEXT, lat REAL,lng REAL)");

    //Insert Default Cities

    await database.execute(
      "INSERT INTO Cities (id,name,lat,lng) SELECT 1, 'Kuala Lumpur',3.1390,101.6869 WHERE NOT EXISTS(SELECT 1 FROM Cities WHERE id = 1 AND name = 'Kuala Lumpur');"
    );

    await database.execute(
      "INSERT INTO Cities (id,name,lat,lng) SELECT 2, 'George Town',5.411229,100.335426 WHERE NOT EXISTS(SELECT 1 FROM Cities WHERE id = 2 AND name = 'George Town');"
    );

     await database.execute(
      "INSERT INTO Cities (id,name,lat,lng) SELECT 3, 'Johor Bahru',1.4655,103.7578 WHERE NOT EXISTS(SELECT 1 FROM Cities WHERE id = 3 AND name = 'Johor Bahru');"
    );
  }
}
