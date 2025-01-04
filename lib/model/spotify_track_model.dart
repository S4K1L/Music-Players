class SpotifyTrack {
  final String name;
  final String artist;
  final String albumCover;

  SpotifyTrack({required this.name, required this.artist, required this.albumCover});

  factory SpotifyTrack.fromJson(Map<String, dynamic> json) {
    return SpotifyTrack(
      name: json['name'],
      artist: json['artists'][0]['name'],
      albumCover: json['album']['images'][0]['url'],
    );
  }
}