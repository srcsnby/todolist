import 'package:calisma/missionscreen.dart';
import 'package:flutter/material.dart';
import 'dbhelper.dart'; // DBHelper'ı import et

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const MyHomePage(),
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.blueAccent,
        textTheme: TextTheme(headlineMedium: TextStyle(color: Colors.white))),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<String> days = [
    "Monday",
    "Tuesday",
    "Wednesday",
    "Thursday",
    "Friday",
    "Saturday",
    "Sunday",
  ];

  Map<String, int> taskCounts = {}; // Her günün görev sayısını tut
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTaskCounts(); // Görev sayılarını yükle
  }

  // Her günün görev sayısını database'den yükle
  Future<void> _loadTaskCounts() async {
    try {
      print('Görev sayıları yükleniyor...');
      
      Map<String, int> counts = await DBHelper.getTaskCountByDay();
      
      setState(() {
        taskCounts = counts;
        isLoading = false;
      });

      print('Görev sayıları yüklendi: $counts');
    } catch (e) {
      print('Görev sayılarını yükleme hatası: $e');
      
      setState(() {
        isLoading = false;
      });
    }
  }

  // Gün butonu oluştur
  Widget buildDayButton(BuildContext context, String day) {
    int count = taskCounts[day] ?? 0;
    
    return Container(
      height: 70,
      width: 170,
      child: ElevatedButton(
        onPressed: () async {
          // MissionList sayfasına git
          await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => MissionList(day: day), // Sadece day parametresi geçir
            ),
          );
          
          // Geri dönünce görev sayılarını yenile
          _loadTaskCounts();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromARGB(255, 227, 141, 11),
          foregroundColor: const Color.fromARGB(255, 255, 255, 255),
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Stack(
          children: [
            // Gün ismi
            Center(
              child: Text(
                day,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w300,
                  color: const Color.fromARGB(255, 255, 255, 255),
                ),
              ),
            ),
            
            // Görev sayısı badge'i
            if (count > 0)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  padding: EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.blueAccent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  constraints: BoxConstraints(
                    minWidth: 20,
                    minHeight: 20,
                  ),
                  child: Text(
                    '$count',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: Center(
          child: Text(
            "MUSLIM'S TO-DO LIST",
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.white,
              fontSize: 25,
            ),
          ),
        ),
        actions: [
          // Database bilgilerini göster (debug için)
          IconButton(
            icon: Icon(
              Icons.info_outline,
              color: Colors.white,
              ),
            onPressed: () async {
              await DBHelper.printDatabaseInfo();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Database bilgileri console\'da yazdırıldı'),
                ),
              );
            },
            tooltip: 'Database bilgileri',
          ),
          
          // Yenile butonu
          IconButton(
            icon: Icon(
              Icons.refresh,
              color: Colors.white,
              ),
            onPressed: _loadTaskCounts,
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
          Container(
            padding: const EdgeInsets.all(20),
            margin: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 30, 110, 172).withOpacity(0.3),
              borderRadius: BorderRadius.circular(15),
            ),
            child: isLoading
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(color: Colors.white),
                        SizedBox(height: 16),
                        Text(
                          'Görev sayıları yükleniyor...',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  )
                : Container(
                    height: 400,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Pazartesi - Salı
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            buildDayButton(context, 'Monday'),
                            SizedBox(width: 10),
                            buildDayButton(context, 'Tuesday'),
                          ],
                        ),
                        
                        // Çarşamba - Perşembe
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            buildDayButton(context, 'Wednesday'),
                            SizedBox(width: 10),
                            buildDayButton(context, 'Thursday'),
                          ],
                        ),
                        
                        // Cuma - Cumartesi
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            buildDayButton(context, 'Friday'),
                            SizedBox(width: 10),
                            buildDayButton(context, 'Saturday'),
                          ],
                        ),
                        
                        // Pazar
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            buildDayButton(context, 'Sunday'),
                          ],
                        ),
                      ],
                    ),
                  ),
          ),
          
          // Alt yazı
          Positioned(
            bottom: 10,
            right: 75,
            child: Text(
              'لا إله إلا الله محمد رسول الله',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w100,
                color: Color.fromARGB(255, 255, 255, 255),
                shadows: [
                  Shadow(
                    offset: Offset(1, 1),
                    blurRadius: 3,
                    color: Colors.black26,
                  ),
                ],
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
}