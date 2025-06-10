
import 'package:cached_network_image/cached_network_image.dart' show CachedNetworkImage;
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'model/heroes.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '王者荣耀英雄榜',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: '王者荣耀英雄榜'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required String title});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Heroes> heroes = [];
  late Future<List<Heroes>> _heroesFuture;  // 新增：存储Future避免重复请求

  @override
  void initState() {
    super.initState();
    _heroesFuture = getHeroes();  // 初始化时获取数据
  }

  Future<List<Heroes>> getHeroes() async {  // 修改返回类型为Future<List>
    try {  // 添加异常捕获
      var response = await http.get(Uri.https('pvp.qq.com', '/web201605/js/herolist.json'));
      var jsonData = json.decode(utf8.decode(response.bodyBytes));
      
      // 关键修改：显式转换元素类型为Map<String, dynamic>
      return (jsonData as List).map((e) => Heroes.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      throw Exception('数据加载失败：$e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('王者荣耀英雄榜'),
      ),
      body: SafeArea(
        child: FutureBuilder<List<Heroes>>(  // 明确泛型类型
          future: _heroesFuture,  // 使用存储的Future
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {  // 错误处理
              return Center(child: Text(snapshot.error.toString()));
            }
            if (!snapshot.hasData) {
              return const Center(child: Text('无英雄数据'));
            }

            heroes = snapshot.data!;  // 赋值数据
            return GridView.builder(
              itemCount: heroes.length,  // 直接使用列表长度
              padding: const EdgeInsets.all(10),
              itemBuilder: (context, index) {
                final hero = heroes[index];
                return Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.grey[100],  // 添加背景色提升对比度
                    ),
                    child: Column(  // 使用Column替代ListTile更灵活
                      children: [
                        Expanded(
                          child: CachedNetworkImage(  // 替换为带缓存的图片组件
                            imageUrl: 'https://game.gtimg.cn/images/yxzj/img201606/heroimg/${hero.ename}/${hero.ename}.jpg',
                            placeholder: (context, url) => const Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator())),
                            errorWidget: (context, url, error) => const Icon(Icons.image_not_supported, size: 40),
                            fit: BoxFit.cover,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Text(hero.cname, style: const TextStyle(fontSize: 12)),
                        )
                      ],
                    ),
                  ),
                );
              },
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 120,  // 调整最大交叉轴范围
                childAspectRatio: 0.8,  // 调整宽高比更符合图片比例
                crossAxisSpacing: 8,  // 缩小横向间距
                mainAxisSpacing: 8,  // 缩小纵向间距
              ),
            );
          },
        ),
      ),
    );
  }
}
