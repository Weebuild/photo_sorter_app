import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';

// Import our production AI services
import 'services/production_ai_classifier.dart';
import 'services/production_storage_service.dart';

// Import AI pages
import 'widgets/ai_pages.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AISchoolPhotoOrganizerApp());
}

class AISchoolPhotoOrganizerApp extends StatelessWidget {
  const AISchoolPhotoOrganizerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI Photo Organizer',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF007AFF)),
        useMaterial3: true,
        fontFamily: GoogleFonts.inter().fontFamily,
      ),
      home: const AIPhotoSorterHome(),
      debugShowCheckedModeBanner: false,
    );
  }
}

// AI-Enhanced Photo Sorter Home with Bottom Navigation
class AIPhotoSorterHome extends StatefulWidget {
  const AIPhotoSorterHome({super.key});

  @override
  State<AIPhotoSorterHome> createState() => _AIPhotoSorterHomeState();
}

class _AIPhotoSorterHomeState extends State<AIPhotoSorterHome> {
  int _currentIndex = 0;

  static const List<Widget> _pages = <Widget>[
    AIHomePage(),
    AIFoldersPage(),
    AICalendarPage(),
    AISearchPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          child: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            selectedItemColor: const Color(0xFF007AFF),
            unselectedItemColor: const Color(0xFF8E8E93),
            selectedLabelStyle: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
            unselectedLabelStyle: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            currentIndex: _currentIndex,
            onTap: _onItemTapped,
            elevation: 0,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_rounded),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.folder_rounded),
                label: 'Folders',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.calendar_today_rounded),
                label: 'Calendar',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.search_rounded),
                label: 'Search',
              ),
            ],
          ),
        ),
      ),
    );
  }
}