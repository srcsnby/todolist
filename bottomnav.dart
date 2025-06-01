import 'package:flutter/material.dart';



class BottomNavigationBar extends StatelessWidget {
  const BottomNavigationBar({
    super.key, 
    required type, 
    required List<BottomNavigationBarItem> items, 
    required Color unselectedItemColor, 
    required Color selectedItemColor, 
    required MaterialAccentColor backgroundColor, 
    required int selectedFontSize, 
    required int unselectedFontSize, 
    required TextStyle selectedLabelStyle, 
    required TextStyle unselectedLabelStyle
    }
  );
  
  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.mosque), label: 'Hadith'),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Verse'),
        ],
        unselectedItemColor: Colors.white,
        selectedItemColor: Colors.white,
        backgroundColor: Colors.blueAccent,
        selectedFontSize: 18, // Seçili item'in yazı tipi boyutu
        unselectedFontSize: 14, // Seçilmemiş item'in yazı tipi boyutu
        selectedLabelStyle: TextStyle(
          fontSize: 18,
          //fontWeight: FontWeight.bold,
          color: Colors.white, // Seçili item'in yazı tipi rengi
          fontFamily: 'Montserrat', // Seçili item'in yazı tipi ailesi
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 16,
          color: Colors.grey, // Seçilmemiş item'in yazı tipi rengi
          fontFamily: 'Montserrat', // Seçilmemiş item'in yazı tipi ailesi
        ),
      );
    





  }

  

  
}
