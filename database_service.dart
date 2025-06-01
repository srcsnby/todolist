import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class Task {
  final int? id;
  final String day;
  final String task;
  final String? createdAt;

  Task({
    this.id,
    required this.day,
    required this.task,
    this.createdAt,
  });

  // JSON'dan Task oluştur
  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      day: map['day'],
      task: map['task'],
      createdAt: map['created_at'],
    );
  }

  // Task'ı Map'e çevir
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'day': day,
      'task': task,
      'created_at': createdAt ?? DateTime.now().toIso8601String(),
    };
  }
}

class DatabaseService {
  static Database? _database;
  static const String _tableName = 'tasks';

  // Veritabanını başlat
  static Future<Database> get database async {
    if (_database != null) return _database!;
    
    _database = await _initDatabase();
    return _database!;
  }

  // Veritabanını oluştur
  static Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'todo_app.db');
    
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createTable,
    );
  }

  // Tablo oluştur (MySQL CREATE TABLE gibi)
  static Future<void> _createTable(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $_tableName (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        day TEXT NOT NULL,
        task TEXT NOT NULL,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP
      )
    ''');
    
    print('Tasks tablosu oluşturuldu!');
  }

  // Belirli bir günün görevlerini getir (MySQL SELECT gibi)
  static Future<List<Task>> getTasks(String day) async {
    try {
      final db = await database;
      
      final List<Map<String, dynamic>> maps = await db.query(
        _tableName,
        where: 'day = ?',
        whereArgs: [day],
        orderBy: 'created_at DESC',
      );

      return maps.map((map) => Task.fromMap(map)).toList();
    } catch (e) {
      print('Görevleri getirme hatası: $e');
      return [];
    }
  }

  // Yeni görev ekle (MySQL INSERT gibi)
  static Future<bool> addTask(String day, String task) async {
    try {
      final db = await database;
      
      int result = await db.insert(
        _tableName,
        {
          'day': day,
          'task': task,
          'created_at': DateTime.now().toIso8601String(),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      print('Görev eklendi! ID: $result');
      return result > 0;
    } catch (e) {
      print('Görev ekleme hatası: $e');
      return false;
    }
  }

  // Görev sil (MySQL DELETE gibi)
  static Future<bool> deleteTask(int taskId) async {
    try {
      final db = await database;
      
      int result = await db.delete(
        _tableName,
        where: 'id = ?',
        whereArgs: [taskId],
      );

      print('Görev silindi! Etkilenen satır: $result');
      return result > 0;
    } catch (e) {
      print('Görev silme hatası: $e');
      return false;
    }
  }

  // Belirli bir günün tüm görevlerini sil
  static Future<bool> deleteAllTasksForDay(String day) async {
    try {
      final db = await database;
      
      int result = await db.delete(
        _tableName,
        where: 'day = ?',
        whereArgs: [day],
      );

      print('$day gününün $result görevi silindi!');
      return true;
    } catch (e) {
      print('Görevleri silme hatası: $e');
      return false;
    }
  }

  // Tüm görevleri getir (istatistik için)
  static Future<List<Task>> getAllTasks() async {
    try {
      final db = await database;
      
      final List<Map<String, dynamic>> maps = await db.query(
        _tableName,
        orderBy: 'created_at DESC',
      );

      return maps.map((map) => Task.fromMap(map)).toList();
    } catch (e) {
      print('Tüm görevleri getirme hatası: $e');
      return [];
    }
  }

  // Gün bazında görev sayısını getir
  static Future<Map<String, int>> getTaskCountByDay() async {
    try {
      final db = await database;
      
      final List<Map<String, dynamic>> result = await db.rawQuery('''
        SELECT day, COUNT(*) as count 
        FROM $_tableName 
        GROUP BY day
      ''');

      Map<String, int> taskCounts = {};
      for (var row in result) {
        taskCounts[row['day']] = row['count'];
      }

      return taskCounts;
    } catch (e) {
      print('Görev sayısı getirme hatası: $e');
      return {};
    }
  }

  // Veritabanını temizle (test için)
  static Future<void> clearDatabase() async {
    try {
      final db = await database;
      await db.delete(_tableName);
      print('Veritabanı temizlendi!');
    } catch (e) {
      print('Veritabanı temizleme hatası: $e');
    }
  }

  // Veritabanını kapat
  static Future<void> closeDatabase() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}