class izlenenFilmler {
  final String? imagepath;
  final String movieName;
  final String movieGenre;
  final String director;
  final double averageRating;
  final String? imageUrl;

  izlenenFilmler({
    this.imagepath,
    required this.movieName,
    required this.movieGenre,
    required this.director,
    required this.averageRating,
    this.imageUrl,
  });

  factory izlenenFilmler.fromJson(Map<String, dynamic> json) {
    return izlenenFilmler(
        movieName: json['movieName'],
        director: json['director'],
        movieGenre: json['movieGenre'],
        imagepath: json['imagepath'],
        averageRating: (json['averageRating'] ?? 0).toDouble(),
        imageUrl: json['imageUrl']);
  }

  Map<String, dynamic> toJson() {
    return {
      'movieName': movieName,
      'director': director,
      'movieGenre': movieGenre,
      'imageUrl': imageUrl,
      'averageRating': averageRating,
    };
  }
}

List<izlenenFilmler> izlenenFilmList = [];

// ignore: camel_case_types
class kartlar {
  String kartAdi;

  kartlar({
    this.kartAdi = "",
  });
}

final List<kartlar> kartListesi = [];
