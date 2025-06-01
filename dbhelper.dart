import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class Task {
  final int? id;
  final String day;
  final String task;
  final String createdAt;

  Task({
    this.id,
    required this.day,
    required this.task,
    required this.createdAt,
  });

  // Map'ten Task objesi oluşturma
  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      day: map['day'],
      task: map['task'],
      createdAt: map['created_at'],
    );
  }

  // Task objesini Map'e çevirme
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'day': day,
      'task': task,
      'created_at': createdAt,
    };
  }
}

class DBHelper {
  static Database? _database;
  static const String _tableName = 'tasks';
  static const String _databaseName = 'muslim_todo.db';
  static const int _databaseVersion = 1;

  // Database instance'ını al (Singleton pattern)
  static Future<Database> get database async {
    if (_database != null) return _database!;
    
    _database = await _initDatabase();
    return _database!;
  }

  // Database'i başlat ve oluştur
  static Future<Database> _initDatabase() async {
    try {
      // Database dosyasının yolunu al
      String path = join(await getDatabasesPath(), _databaseName);
      
      print('Database path: $path');
      
      // Database'i oluştur veya aç
      return await openDatabase(
        path,
        version: _databaseVersion,
        onCreate: _createTable,
        onUpgrade: _upgradeDatabase,
      );
    } catch (e) {
      print('Database başlatma hatası: $e');
      rethrow;
    }
  }

  // Tablo oluşturma
  static Future<void> _createTable(Database db, int version) async {
    try {
      await db.execute('''
        CREATE TABLE $_tableName (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          day TEXT NOT NULL,
          task TEXT NOT NULL,
          created_at TEXT NOT NULL
        )
      ''');
      
      print('Tasks tablosu başarıyla oluşturuldu!');
    } catch (e) {
      print('Tablo oluşturma hatası: $e');
      rethrow;
    }
  }

  // Database güncelleme (versiyon değiştiğinde)
  static Future<void> _upgradeDatabase(Database db, int oldVersion, int newVersion) async {
    print('Database $oldVersion\'dan $newVersion\'a güncelleniyor');
    // Gerekirse migration kodları buraya
  }

  // Yeni görev ekleme
  static Future<bool> insertTask(String day, String task) async {
    try {
      final db = await database;
      
      final newTask = Task(
        day: day,
        task: task,
        createdAt: DateTime.now().toIso8601String(),
      );

      int result = await db.insert(
        _tableName,
        newTask.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      print('Görev eklendi - ID: $result, Day: $day, Task: $task');
      return result > 0;
    } catch (e) {
      print('Görev ekleme hatası: $e');
      return false;
    }
  }

  // Belirli bir günün görevlerini getirme
  static Future<List<String>> getTasksForDay(String day) async {
    try {
      final db = await database;
      
      final List<Map<String, dynamic>> maps = await db.query(
        _tableName,
        where: 'day = ?',
        whereArgs: [day],
        orderBy: 'created_at ASC', // Eski görevler önce
      );

      List<String> tasks = maps.map((map) => map['task'] as String).toList();
      
      print('$day için ${tasks.length} görev bulundu');
      return tasks;
    } catch (e) {
      print('Görevleri getirme hatası: $e');
      return [];
    }
  }

  // Belirli bir günün tüm görev objelerini getirme (detaylı bilgi için)
  static Future<List<Task>> getDetailedTasksForDay(String day) async {
    try {
      final db = await database;
      
      final List<Map<String, dynamic>> maps = await db.query(
        _tableName,
        where: 'day = ?',
        whereArgs: [day],
        orderBy: 'created_at ASC',
      );

      List<Task> tasks = maps.map((map) => Task.fromMap(map)).toList();
      
      print('$day için ${tasks.length} detaylı görev bulundu');
      return tasks;
    } catch (e) {
      print('Detaylı görevleri getirme hatası: $e');
      return [];
    }
  }

  // Görev silme (index'e göre)
  static Future<bool> deleteTaskByIndex(String day, int index) async {
    try {
      final db = await database;
      
      // Önce o günün görevlerini al
      final List<Map<String, dynamic>> maps = await db.query(
        _tableName,
        where: 'day = ?',
        whereArgs: [day],
        orderBy: 'created_at ASC',
      );

      if (index >= 0 && index < maps.length) {
        int taskId = maps[index]['id'];
        
        int result = await db.delete(
          _tableName,
          where: 'id = ?',
          whereArgs: [taskId],
        );

        print('Görev silindi - ID: $taskId, Index: $index');
        return result > 0;
      } else {
        print('Geçersiz index: $index');
        return false;
      }
    } catch (e) {
      print('Görev silme hatası: $e');
      return false;
    }
  }

  // ID'ye göre görev silme
  static Future<bool> deleteTaskById(int id) async {
    try {
      final db = await database;
      
      int result = await db.delete(
        _tableName,
        where: 'id = ?',
        whereArgs: [id],
      );

      print('Görev silindi - ID: $id');
      return result > 0;
    } catch (e) {
      print('Görev silme hatası: $e');
      return false;
    }
  }

  // Belirli bir günün tüm görevlerini silme
  static Future<bool> deleteAllTasksForDay(String day) async {
    try {
      final db = await database;
      
      int result = await db.delete(
        _tableName,
        where: 'day = ?',
        whereArgs: [day],
      );

      print('$day gününün $result görevi silindi');
      return true;
    } catch (e) {
      print('Günün görevlerini silme hatası: $e');
      return false;
    }
  }

  // Tüm görevleri getirme
  static Future<List<Task>> getAllTasks() async {
    try {
      final db = await database;
      
      final List<Map<String, dynamic>> maps = await db.query(
        _tableName,
        orderBy: 'day ASC, created_at ASC',
      );

      List<Task> tasks = maps.map((map) => Task.fromMap(map)).toList();
      
      print('Toplam ${tasks.length} görev bulundu');
      return tasks;
    } catch (e) {
      print('Tüm görevleri getirme hatası: $e');
      return [];
    }
  }

  // Gün bazında görev sayılarını getirme
  static Future<Map<String, int>> getTaskCountByDay() async {
    try {
      final db = await database;
      
      final List<Map<String, dynamic>> result = await db.rawQuery('''
        SELECT day, COUNT(*) as count 
        FROM $_tableName 
        GROUP BY day
        ORDER BY day
      ''');

      Map<String, int> taskCounts = {};
      
      // Tüm günleri 0 ile başlat
      List<String> allDays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
      for (String day in allDays) {
        taskCounts[day] = 0;
      }
      
      // Database'den gelen sayıları güncelle
      for (var row in result) {
        taskCounts[row['day']] = row['count'];
      }

      print('Gün bazında görev sayıları: $taskCounts');
      return taskCounts;
    } catch (e) {
      print('Görev sayısı getirme hatası: $e');
      return {};
    }
  }

  // Database'i temizleme (test için)
  static Future<bool> clearAllTasks() async {
    try {
      final db = await database;
      
      int result = await db.delete(_tableName);
      
      print('Tüm görevler temizlendi - $result kayıt silindi');
      return true;
    } catch (e) {
      print('Database temizleme hatası: $e');
      return false;
    }
  }

  // Database'i kapatma
  static Future<void> closeDatabase() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
      print('Database kapatıldı');
    }
  }

  // Database durumu kontrolü
  static Future<bool> isDatabaseReady() async {
    try {
      final db = await database;
      
      // Test sorgusu çalıştır
      await db.rawQuery('SELECT COUNT(*) FROM $_tableName');
      
      print('Database hazır ve çalışıyor');
      return true;
    } catch (e) {
      print('Database durum kontrolü hatası: $e');
      return false;
    }
  }

  // Database bilgilerini yazdır (debug için)
  static Future<void> printDatabaseInfo() async {
    try {
      final db = await database;
      
      print('=== DATABASE BİLGİLERİ ===');
      print('Database yolu: ${db.path}');
      print('Database versiyonu: $_databaseVersion');
      
      // Tablo bilgileri
      final tableInfo = await db.rawQuery("PRAGMA table_info($_tableName)");
      print('Tablo yapısı:');
      for (var column in tableInfo) {
        print('  ${column['name']}: ${column['type']}');
      }
      
      // Toplam kayıt sayısı
      final count = await db.rawQuery('SELECT COUNT(*) as count FROM $_tableName');
      print('Toplam kayıt sayısı: ${count.first['count']}');
      
      print('========================');
    } catch (e) {
      print('Database bilgileri yazdırma hatası: $e');
    }
  }
}