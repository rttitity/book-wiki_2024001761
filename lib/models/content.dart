class Content {
  final String content;
  final String downloadUrl;
  final String date;
  final String email;

  Content({required this.content, required this.downloadUrl, required this.date, required this.email});

  factory Content.fromJson(Map<String, dynamic> json) => Content(
    content: json['content'],
    downloadUrl: json['downloadUrl'],
    date: json['date'],
    email: json['email'],
  );

  Map<String, dynamic> toJson() => {'content': content, 'downloadUrl': downloadUrl, 'date': date, 'email': email};
}
