class WeatherData {
  final String temp;
  final int id;
  final String title;

  WeatherData({this.temp, this.id, this.title});

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    return WeatherData(
      temp: json['main']['temp'].toString(),
      id: json['id'],
      title: json['name'],
    );
  }
}