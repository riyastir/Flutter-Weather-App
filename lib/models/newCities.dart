class NewCities {
  int id;
  String name;
  double lat;
  double lng;

  citiesMap() {
    var mapping = Map<String, dynamic>();
    mapping['id'] = id;
    mapping['name'] = name;
    mapping['lat'] = lat;
    mapping['lng'] = lng;

    return mapping;
  }
}
