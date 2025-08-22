import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class TaskData {
  // Tüm görev listelerini saklamak için bir veri deposu
  static Map<String, List<String>> allTasks = {
    'Monday': [],
    'Tuesday': [],
    'Wednesday': [],
    'Thursday': [],
    'Friday': [],
    'Saturday': [],
    'Sunday': [],
  };
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ToDoListApp(),
    );
  }
}

class ToDoListApp extends StatelessWidget {
  const ToDoListApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('To-Do List'),
          backgroundColor: Colors.blueAccent,
        ),
        body: Container(
          //height: 600,
          color: const Color.fromARGB(255, 229, 228, 228),
          child: Stack(
            alignment: AlignmentDirectional.center,
            children: [
              Image(
                image: AssetImage('images/kaaba4.jpg'),
                fit: BoxFit.cover,
                width: double.infinity, // genişlik tüm ekranı kaplar
                height: double.infinity, // yükseklik tüm ekranı kaplar
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      buildDayButton(context, 'Monday'),
                      SizedBox(
                        width: 10,
                      ),
                      buildDayButton(context, 'Tuesday'),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      buildDayButton(context, 'Wednesday'),
                      SizedBox(
                        width: 10,
                      ),
                      buildDayButton(context, 'Thursday'),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      buildDayButton(context, 'Friday'),
                      SizedBox(
                        width: 10,
                      ),
                      buildDayButton(context, 'Saturday'),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      buildDayButton(context, 'Sunday'),
                    ],
                  ),
                  Container(
                    width: 400,
                    color: Colors.blueAccent,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '"لا إله إلا الله محمد رسول الله"',
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w100,
                            color: const Color.fromARGB(255, 255, 255, 255),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.mosque),
              label: 'Hadith',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.book),
              label: 'Verse',
            ),
          ],
          unselectedItemColor: const Color.fromARGB(255, 0, 0, 0),
          selectedItemColor: const Color.fromARGB(255, 0, 0, 0),
          backgroundColor: Colors.blue,
          selectedFontSize: 18, // Seçili item'in yazı tipi boyutu
          unselectedFontSize: 14, // Seçilmemiş item'in yazı tipi boyutu
          selectedLabelStyle: TextStyle(
            fontSize: 16,
            //fontWeight: FontWeight.bold,
            color: Colors.white, // Seçili item'in yazı tipi rengi
            fontFamily: 'Montserrat', // Seçili item'in yazı tipi ailesi
          ),
          unselectedLabelStyle: TextStyle(
            fontSize: 16,
            color: Colors.grey, // Seçilmemiş item'in yazı tipi rengi
            fontFamily: 'Montserrat', // Seçilmemiş item'in yazı tipi ailesi
          ),
        ));
  }

  Row buildDayButton(BuildContext context, String day) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          height: 70,
          width: 170,
          child: ElevatedButton(
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                // Görev listesi için ilgili günün görevlerini al
                List<String> tasks = TaskData.allTasks[day]!;
                return ListeEkrani(
                    tasks: tasks, day: day); // ListeEkrani'na günü de geçir
              }));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 227, 141, 11),

              padding: EdgeInsets.zero, // Remove padding
            ),
            child: Text(
              day,
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.w300,
                color: const Color.fromARGB(255, 0, 0, 0),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class ListeEkrani extends StatefulWidget {
  final List<String> tasks;
  final String day;
  const ListeEkrani({Key? key, required this.tasks, required this.day})
      : super(key: key);

  @override
  State<ListeEkrani> createState() => _ListeEkraniState();
}

class _ListeEkraniState extends State<ListeEkrani> {
  late TextEditingController taskController;
  bool _hasBeenPresseds = false;
  bool _hasBeenPressedo = false;
  bool _hasBeenPressedi = false;
  bool _hasBeenPresseda = false;
  bool _hasBeenPressedy = false;

  @override
  void initState() {
    super.initState();
    taskController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.day.toUpperCase()}'S TASKS"),
        backgroundColor: Colors.blueAccent,
      ),
      body: Container(
        child: Stack(alignment: AlignmentDirectional.center, children: [
          Image(
            image: AssetImage('images/kaaba3.jpg'),
            fit: BoxFit.cover,
            width: double.infinity, // genişlik tüm ekranı kaplar
            height: double.infinity, // yükseklik tüm ekranı kaplar
          ),
          Center(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          style: TextStyle(
                            color: const Color.fromARGB(255, 0, 0, 0),
                          ),
                          controller: taskController,
                          decoration: InputDecoration(
                            hintText: 'Add Tasks',
                            iconColor: Colors.white,
                            hintStyle: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.add),
                        color: Colors.white,
                        onPressed: () {
                          addTask();
                        },
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: widget.tasks.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(
                            style: TextStyle(
                              color: Colors.white,
                            ),
                            widget.tasks[index]),
                        trailing: IconButton(
                          icon: Icon(Icons.delete),
                          color: Colors.white,
                          onPressed: () {
                            deleteTask(index);
                          },
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  height: 100,
                  child: Row(
                    children: [
                      Flexible(
                        fit: FlexFit.tight,
                        flex: 1,
                        child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _hasBeenPresseds = !_hasBeenPresseds;
                              });
                            },
                            style: ElevatedButton.styleFrom(
                                backgroundColor: _hasBeenPresseds
                                    ? Colors.green
                                    : Colors.red, //background color of button
                                side: BorderSide(
                                    width: 10,
                                    color: _hasBeenPresseds
                                        ? Colors.green
                                        : Colors.red), //border width and color
                                elevation: 3, //elevation of button
                                shape: RoundedRectangleBorder(
                                    //to set border radius to button
                                    borderRadius: BorderRadius.circular(20)),
                                padding: EdgeInsets.all(
                                    15) //content padding inside button

                                ),
                            child: Text(
                              "Fajr",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white,
                                //backgroundColor: Colors.,

                                //fontWeight: FontWeight.w400),
                              ),
                            )),
                      ),
                      Flexible(
                        fit: FlexFit.tight,
                        flex: 1,
                        child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _hasBeenPressedo = !_hasBeenPressedo;
                              });
                            },
                            style: ElevatedButton.styleFrom(
                                backgroundColor: _hasBeenPressedo
                                    ? Colors.green
                                    : Colors.red, //background color of button
                                side: BorderSide(
                                    width: 3,
                                    color: _hasBeenPressedo
                                        ? Colors.green
                                        : Colors.red), //border width and color
                                elevation: 3, //elevation of button
                                shape: RoundedRectangleBorder(
                                    //to set border radius to button
                                    borderRadius: BorderRadius.circular(20)),
                                padding: EdgeInsets.all(
                                    15) //content padding inside button

                                ),
                            child: Text(
                              "Dhuhr",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white,
                                //backgroundColor: Colors.,

                                //fontWeight: FontWeight.w400),
                              ),
                            )),
                      ),
                      Flexible(
                        fit: FlexFit.tight,
                        flex: 1,
                        child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _hasBeenPressedi = !_hasBeenPressedi;
                              });
                            },
                            style: ElevatedButton.styleFrom(
                                backgroundColor: _hasBeenPressedi
                                    ? Colors.green
                                    : Colors.red, //background color of button
                                side: BorderSide(
                                    width: 3,
                                    color: _hasBeenPressedi
                                        ? Colors.green
                                        : Colors.red), //border width and color
                                elevation: 3, //elevation of button
                                shape: RoundedRectangleBorder(
                                    //to set border radius to button
                                    borderRadius: BorderRadius.circular(20)),
                                padding: EdgeInsets.all(
                                    15) //content padding inside button

                                ),
                            child: Text(
                              "Asr",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white,
                                //backgroundColor: Colors.,

                                //fontWeight: FontWeight.w400),
                              ),
                            )),
                      ),
                      Flexible(
                        fit: FlexFit.tight,
                        flex: 1,
                        child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _hasBeenPresseda = !_hasBeenPresseda;
                              });
                            },
                            style: ElevatedButton.styleFrom(
                                backgroundColor: _hasBeenPresseda
                                    ? Colors.green
                                    : Colors.red, //background color of button
                                side: BorderSide(
                                    width: 3,
                                    color: _hasBeenPresseda
                                        ? Colors.green
                                        : Colors.red), //border width and color
                                elevation: 3, //elevation of button
                                shape: RoundedRectangleBorder(
                                    //to set border radius to button
                                    borderRadius: BorderRadius.circular(20)),
                                padding: EdgeInsets.all(
                                    15) //content padding inside button

                                ),
                            child: Text(
                              "Maghrib",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white,
                                //backgroundColor: Colors.,

                                //fontWeight: FontWeight.w400),
                              ),
                            )),
                      ),
                      Flexible(
                        fit: FlexFit.tight,
                        flex: 1,
                        child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _hasBeenPressedy = !_hasBeenPressedy;
                              });
                            },
                            style: ElevatedButton.styleFrom(
                                backgroundColor: _hasBeenPressedy
                                    ? Colors.green
                                    : Colors.red, //background color of button
                                side: BorderSide(
                                    width: 3,
                                    color: _hasBeenPressedy
                                        ? Colors.green
                                        : Colors.red), //border width and color
                                elevation: 3, //elevation of button
                                shape: RoundedRectangleBorder(
                                    //to set border radius to button
                                    borderRadius: BorderRadius.circular(20)),
                                padding: EdgeInsets.all(
                                    15) //content padding inside button

                                ),
                            child: Text(
                              "Isha",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white,
                                //backgroundColor: Colors.,

                                //fontWeight: FontWeight.w400),
                              ),
                            )),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 100.0,
                  height: 50.0,
                  //child: Card(child: Text('Hello World!')),
                )
                /*ElevatedButton(
                  onPressed: () {
                    // Ana veri deposundaki ilgili günün görev listesini güncelle
                    TaskData.allTasks[widget.day] = widget.tasks;
                    Navigator.of(context).maybePop(true);
                  },
                  child: Text(
                    'Evet',
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).maybePop(false);
                  },
                  child: Text(
                    'Hayır',
                  ),
                ),*/
              ],
            ),
          ),
        ]),
      ),
    );
  }

  void addTask() {
    String newTask = taskController.text;
    if (newTask.isNotEmpty) {
      setState(() {
        widget.tasks.add(newTask);
        taskController.clear();
      });
    }
  }

  void deleteTask(int index) {
    setState(() {
      widget.tasks.removeAt(index);
    });
  }

  @override
  void dispose() {
    taskController.dispose();
    super.dispose();
  }
}
