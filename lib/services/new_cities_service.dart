import 'package:weatherapp/models/newCities.dart';
import 'package:weatherapp/repos/repo.dart';

class CitiesService {
  Repository _repository;

  CitiesService() {
    _repository = Repository();
  }

  // Create data
  saveCity(NewCities city) async {
    return await _repository.insertData('Cities', city.citiesMap());
  }

  // Create data
  addNewCity(id,name,lat,lng) async {
    return await _repository.insertNewData('Cities', id, name, lat, lng);
  }

  // Read data from table
  readCities() async {
    return await _repository.readData('cities');
  }

  // Read data from table by Id
  readCityById(cityId) async {
    return await _repository.readDataById('cities', cityId);
  }

  // Read data from table by column
  readCityByName(cityName) async {
    return await _repository.readDataByColumnName('cities', 'name',cityName);
  }

  // Update data from table
  updateCity(NewCities city) async {
    return await _repository.updateData('cities', city.citiesMap());
  }

  // Delete data from table
  deleteCity(cityId) async{
    return await _repository.deleteData('cities', cityId);
  }
}
