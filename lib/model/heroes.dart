class Heroes {
  final int ename; //105
  final String cname; //廉颇
  final String title; //正义爆轰

  Heroes({
    required this.ename,
    required this.cname,
    required this.title,
  });


  factory Heroes.fromJson(Map<String, dynamic> json) {
    return Heroes(
      ename: json['ename'] as int,  // 对应修改
      cname: json['cname'] as String,
      title: json['title'] as String,
    );
  }
}



