import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:btl_flutter_nhom6/widgets/recipe_card.dart';
import 'package:btl_flutter_nhom6/screens/recipe_detail_screen.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';


class SearchScreen extends StatefulWidget {
  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  List<String> _searchHistory = [];
  late String historyDocId;
  Timer? _debounce;
  String _searchText = ""; // Biến lưu trữ từ khóa tìm kiếm
  //khoi tao speech to text
  late TextEditingController _controller;
  stt.SpeechToText speech=stt.SpeechToText();
  bool isListening=false;

  @override
  void initState(){
    super.initState();
    speech = stt.SpeechToText();
    _controller = TextEditingController();
    final user = FirebaseAuth.instance.currentUser; // 
    if (user != null) {
      historyDocId = user.uid; //  mỗi người dùng sẽ có 1 document riêng
      loadSearchHistory(); //  chỉ gọi khi đã có uid
    }
  }
  Future<void> loadSearchHistory() async {
    final doc = await FirebaseFirestore.instance
        .collection('searchHistories')
        .doc(historyDocId)
        .get();

    if (doc.exists) {
      final data = doc.data();
      if (data != null && data.containsKey('history')) {
        setState(() {
          _searchHistory = List<String>.from(data['history']);
        });
      }
    }
  }

  Future<void> saveSearchHistory() async {
    await FirebaseFirestore.instance.collection('searchHistories').doc(historyDocId).set({
      'history': _searchHistory,
    }, SetOptions(merge: true));
  }
  void onlisten() async{
    if(!isListening){
      bool available= await speech.initialize(
        onStatus:(val) => print('onStatus: $val'),
        onError: (val) => print('onError: $val')
      );
      if (available) {
        setState(() {
          isListening = true;
        });
        speech.listen(onResult: (val) => setState(() {
              _searchText = val.recognizedWords;
              _controller.text = val.recognizedWords;
            _controller.selection = TextSelection.fromPosition(
              TextPosition(offset: _controller.text.length),
          );
              _addToSearchHistory(val.recognizedWords); // Lưu lịch sử khi dùng mic
            }));
      }
    } else {
      setState(() {
        isListening = false;
      });
      speech.stop();
    }

  }
  void _addToSearchHistory(String keyword) {
    keyword = keyword.trim();
    if (keyword.length < 3) return; // ✅ Bỏ qua từ quá ngắn
    if (_searchHistory.contains(keyword)) return; // ✅ Không lưu trùng lặp
    if (keyword.isEmpty) return;
    if (_searchHistory.contains(keyword)) return;

    setState(() {
      _searchHistory.insert(0, keyword);
      if (_searchHistory.length > 3) {
        _searchHistory = _searchHistory.sublist(0, 3);
      }
    });
    saveSearchHistory();
  }
  @override
  void dispose() {
  _debounce?.cancel();
  _controller.dispose();
  speech.stop();
  super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tìm kiếm công thức"),
        backgroundColor: Colors.pinkAccent,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 🔍 Thanh tìm kiếm
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _controller,//luu tu sau khi noi tu mic 
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  prefixIcon: const Icon(Icons.search),
                  hintText: 'Ví dụ: Burger rau củ',
                  suffixIcon: IconButton(
                    icon:  Icon(Icons.mic,color: isListening ? Colors.green : Colors.black,),
                      onPressed: () {
                        // gọi chức năng ghi âm
                        
                        onlisten();
                        
                      }
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchText = value; // Cập nhật từ khóa tìm kiếm
                  });
                  
                  // ✅ Debounce: nếu người dùng tiếp tục gõ, hủy timer cũ
                  if (_debounce?.isActive ?? false) _debounce!.cancel();

                  // ✅ Đợi 800ms sau khi người dùng ngừng gõ mới lưu
                  _debounce = Timer(const Duration(milliseconds: 1000), () {
                    if (value.trim().isNotEmpty) {
                      _addToSearchHistory(value);
                    }
                  });
  
                },
              ),
            ),
            // ✅ Hiển thị lịch sử tìm kiếm khi chưa nhập gì
            if (_searchText.isEmpty && _searchHistory.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      'Lịch sử tìm kiếm:',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),

                  ///  Giới hạn chiều cao vùng hiển thị lịch sử (200 là ví dụ, có thể điều chỉnh)
                  SizedBox(
                    height: 100,
                    child: ListView.builder(
                      itemCount: _searchHistory.length,
                      itemBuilder: (context, index) {
                        final keyword = _searchHistory[index];
                        return ListTile(
                          title: Text(keyword),
                          leading: Icon(Icons.history),
                          onTap: () {
                            setState(() {
                              _searchText = keyword;
                              _controller.text = keyword;
                            });
                          },
                        );
                },
              ),
            ),

                  const Divider(),
                ],
              ),
            // 📃 Danh sách kết quả tìm kiếm
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream:
                    FirebaseFirestore.instance
                        .collection(
                          'recipes',
                        ) // Lấy dữ liệu từ collection 'recipes'
                        .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return const Center(child: Text('Có lỗi xảy ra!'));
                  }

                  final recipes =
                      snapshot.data!.docs; // Danh sách tài liệu từ Firestore
                  // Lọc các công thức theo từ khóa tìm kiếm
                  final filteredRecipes =
                      recipes.where((recipe) {
                        final title = recipe['title'].toString().toLowerCase();
                        return title.contains(_searchText.toLowerCase());
                      }).toList();

                  if (filteredRecipes.isEmpty) {
                    return const Center(
                      child: Text('Không tìm thấy công thức nào.'),
                    );
                  }

                  return ListView.builder(
                    itemCount: filteredRecipes.length,
                    itemBuilder: (context, index) {
                      final item =
                          filteredRecipes[index].data() as Map<String, dynamic>;
                      return RecipeCard(
                        item: item,
                      ); // Hiển thị công thức tìm được
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
