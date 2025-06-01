import 'package:flutter/material.dart';
import 'dbhelper.dart'; // DBHelper'ı import et

class MissionList extends StatefulWidget {
  const MissionList({super.key, required this.day});

  final String day; // tasks parametresini kaldırdık, database'den alacağız

  @override
  State<MissionList> createState() => _MissionListState();
}

class _MissionListState extends State<MissionList> {
  late TextEditingController taskController;
  ScrollController scrollController = ScrollController();

  List<String> currentTasks = []; // Database'den yüklenecek
  bool isLoading = true; // Yükleme durumu
  bool isProcessing = false; // İşlem durumu

  @override
  void initState() {
    super.initState();
    taskController = TextEditingController();
    _loadTasks(); // Görevleri database'den yükle
  }

  // Database'den görevleri yükle
  Future<void> _loadTasks() async {
    print('${widget.day} için görevler yükleniyor...');
    
    setState(() {
      isLoading = true;
    });

    try {
      // Database hazır mı kontrol et
      bool dbReady = await DBHelper.isDatabaseReady();
      if (!dbReady) {
        throw Exception('Database hazır değil');
      }

      // O günün görevlerini getir
      List<String> tasks = await DBHelper.getTasksForDay(widget.day);
      
      setState(() {
        currentTasks = tasks;
        isLoading = false;
      });

      print('${widget.day} için ${tasks.length} görev yüklendi');
    } catch (e) {
      print('Görevleri yükleme hatası: $e');
      
      setState(() {
        isLoading = false;
      });

      // Kullanıcıya hata göster
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Görevler yüklenemedi: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Yeni görev ekleme
  Future<void> addTask() async {
    String newTask = taskController.text.trim();
    
    if (newTask.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lütfen bir görev yazın!')),
      );
      return;
    }

    setState(() {
      isProcessing = true;
    });

    try {
      print('Görev ekleniyor: ${widget.day} - $newTask');
      
      // Database'e görev ekle
      bool success = await DBHelper.insertTask(widget.day, newTask);
      
      if (success) {
        // Text field'ı temizle
        taskController.clear();
        
        // Görevleri yeniden yükle
        await _loadTasks();
        
        // Başarı mesajı göster
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Görev eklendi!'),
            backgroundColor: Colors.blueAccent,
            duration: Duration(seconds: 2),
          ),
        );

        // Liste sonuna scroll yap
        _scrollToBottom();
      } else {
        throw Exception('Database\'e görev eklenemedi');
      }
    } catch (e) {
      print('Görev ekleme hatası: $e');
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Görev eklenemedi: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        isProcessing = false;
      });
    }
  }

  // Görev silme
  Future<void> deleteTask(int index) async {
    if (index < 0 || index >= currentTasks.length) {
      print('Geçersiz index: $index');
      return;
    }

    setState(() {
      isProcessing = true;
    });

    try {
      String taskToDelete = currentTasks[index];
      print('Görev siliniyor: Index $index - $taskToDelete');
      
      // Database'den görev sil
      bool success = await DBHelper.deleteTaskByIndex(widget.day, index);
      
      if (success) {
        // Görevleri yeniden yükle
        await _loadTasks();
        
        // Başarı mesajı göster
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Görev silindi!'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        throw Exception('Database\'den görev silinemedi');
      }
    } catch (e) {
      print('Görev silme hatası: $e');
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Görev silinemedi: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        isProcessing = false;
      });
    }
  }

  // Tüm görevleri silme
  Future<void> _deleteAllTasks() async {
    // Onay diyalogu göster
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Tüm Görevleri Sil'),
          content: Text('${widget.day} gününün tüm görevlerini silmek istediğinizden emin misiniz?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('İptal'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text('Sil', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    setState(() {
      isProcessing = true;
    });

    try {
      print('${widget.day} gününün tüm görevleri siliniyor...');
      
      // Database'den tüm görevleri sil
      bool success = await DBHelper.deleteAllTasksForDay(widget.day);
      
      if (success) {
        // Görevleri yeniden yükle
        await _loadTasks();
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Tüm görevler silindi!'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('Tüm görevleri silme hatası: $e');
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Görevler silinemedi: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        isProcessing = false;
      });
    }
  }

  // Liste sonuna scroll yapma
  void _scrollToBottom() {
    if (scrollController.hasClients) {
      Future.delayed(Duration(milliseconds: 100), () {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
        title: Text(
          "${widget.day.toUpperCase()}'S TASKS",
          style: TextStyle(color: Colors.white, fontSize: 25),
        ),
        actions: [
          // Görev sayısı göster
          if (currentTasks.isNotEmpty && !isLoading)
            Padding(
              padding: EdgeInsets.only(right: 8),
              child: Center(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${currentTasks.length}',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          
          // Tümünü sil butonu
          if (currentTasks.isNotEmpty && !isLoading && !isProcessing)
            IconButton(
              icon: Icon(
                color: Colors.white,
                Icons.clear_all
                ),
              onPressed: _deleteAllTasks,
              tooltip: 'Tüm görevleri sil',
            ),
          
          // Yenile butonu
          IconButton(
            icon: Icon(
              color: Colors.white,
              Icons.refresh
              ),
            onPressed: isProcessing ? null : _loadTasks,
            tooltip: 'Yenile',
          ),
        ],
      ),
      body: Stack(
        children: [
          // Arkaplan resmi
          Image(
            image: AssetImage(
              '/Users/siracsenbay/Development/flutter_projects/calisma/images/kaaba3.jpg',
            ),
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          
          // Ana içerik
          Column(
            children: [
              // Görev ekleme kısmı
              Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        style: TextStyle(
                          color: const Color.fromARGB(255, 255, 255, 255),
                        ),
                        controller: taskController,
                        decoration: InputDecoration(
                          hintText: 'Add Tasks',
                          hintStyle: TextStyle(
                            fontStyle: FontStyle.italic,
                            color: const Color.fromARGB(255, 255, 255, 255),
                          ),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white, width: 2),
                          ),
                        ),
                        onSubmitted: (_) => isProcessing ? null : addTask(),
                        enabled: !isProcessing,
                      ),
                    ),
                    SizedBox(width: 8),
                    IconButton(
                      icon: isProcessing 
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Icon(Icons.add),
                      color: const Color.fromARGB(255, 255, 255, 255),
                      onPressed: isProcessing ? null : addTask,
                    ),
                  ],
                ),
              ),
              
              // Görev listesi veya yükleme göstergesi
              Expanded(
                child: isLoading
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(color: Colors.white),
                            SizedBox(height: 16),
                            Text(
                              'Görevler yükleniyor...',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      )
                    : currentTasks.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.task_alt,
                                  size: 80,
                                  color: Colors.white.withOpacity(0.7),
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'Henüz görev eklenmemiş',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Yukarıdan yeni görev ekleyebilirsiniz',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.8),
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(8.0),
                            itemCount: currentTasks.length,
                            controller: scrollController,
                            itemBuilder: (context, index) {
                              return Container(
                                margin: const EdgeInsets.symmetric(vertical: 4),
                                height: 80,
                                child: Card(
                                  color: const Color.fromARGB(255, 227, 141, 11).withOpacity(0.6),
                                  elevation: 3,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Center(
                                    child: ListTile(
                                      leading: CircleAvatar(
                                        backgroundColor: Colors.blueAccent,
                                        radius: 20,
                                        child: Text(
                                          '${index + 1}',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      title: Text(
                                        currentTasks[index],
                                        style: TextStyle(
                                          color: const Color.fromARGB(255, 255, 255, 255),
                                          fontSize: 20,
                                        ),
                                      ),
                                      trailing: SizedBox(
                                        width: 100,
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          children: [
                                            IconButton(
                                              icon: const Icon(Icons.delete),
                                              color: Colors.blueAccent,
                                              onPressed: isProcessing 
                                                  ? null 
                                                  : () => deleteTask(index),
                                              tooltip: 'Delete task',
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
              ),
            ],
          ),
          
          // İşlem durumu overlay'i
          if (isProcessing)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: Center(
                child: Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('İşlem yapılıyor...'),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.mosque), label: 'Hadith'),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Verse'),
        ],
        unselectedItemColor: Colors.white,
        selectedItemColor: Colors.white,
        backgroundColor: Colors.blueAccent,
        selectedFontSize: 18,
        unselectedFontSize: 14,
        selectedLabelStyle: TextStyle(
          fontSize: 18,
          color: Colors.white,
          fontFamily: 'Montserrat',
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 16,
          color: Colors.grey,
          fontFamily: 'Montserrat',
        ),
      ),
    );
  }

  @override
  void dispose() {
    taskController.dispose();
    scrollController.dispose();
    super.dispose();
  }
}