import 'package:flutter/material.dart';
import 'Statistique.dart';
import 'dart:ui';

class Accueil extends StatefulWidget {
  const Accueil({super.key});

  @override
  State<Accueil> createState() => _AccueilState();
}

class _AccueilState extends State<Accueil> {
  // --- THÈME HARMONISÉ ---
  static const Color _noraAccentBlue = Color(0xFF201293);
  static const Color _softBlue = Color(0xFF5B9EEA);
  static const Color _lightPurple = Color(0xFF9D84F5);
  static const Color _accentGreen = Color(0xFF4CAF50);
  static const Color _warningRed = Color(0xFFF44336);
  static const Color _bgColor = Color(0xFFF8F9FA);

  int _selectedIndex = 0;

  // Données des salles
  final List<Map<String, dynamic>> _rooms = const [
    {
      'name': 'Amphi Théâtre',
      'aqi': 95,
      'status': 'Excellent',
      'temp': '22°C',
      'hum': '45%',
      'color': Colors.green,
      'icon': Icons.meeting_room_rounded
    },
    {
      'name': 'Salle Cisco',
      'aqi': 82,
      'status': 'Bon',
      'temp': '21°C',
      'hum': '50%',
      'color': Colors.lightGreen,
      'icon': Icons.computer_rounded
    },
    {
      'name': 'Sigl 3',
      'aqi': 68,
      'status': 'Moyen',
      'temp': '24°C',
      'hum': '55%',
      'color': Colors.orange,
      'icon': Icons.class_rounded
    },
    {
      'name': 'Bibliothèque',
      'aqi': 92,
      'status': 'Excellent',
      'temp': '22°C',
      'hum': '48%',
      'color': Colors.green,
      'icon': Icons.menu_book_rounded
    },
    {
      'name': 'Labo Réseaux',
      'aqi': 45,
      'status': 'Faible',
      'temp': '23°C',
      'hum': '60%',
      'color': Colors.red,
      'icon': Icons.settings_input_component
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      drawer: _buildDrawer(),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              _lightPurple.withOpacity(0.15),
              _softBlue.withOpacity(0.1),
              Colors.white,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              _buildAppBar(),
              SliverPadding(
                padding: const EdgeInsets.all(20),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _buildWelcomeSection(),
                    const SizedBox(height: 25),
                    _buildGlobalAQICard(),
                    const SizedBox(height: 30),
                    _buildSectionTitle("Statistiques"),
                    const SizedBox(height: 15),
                    _buildSummaryRow(),
                    const SizedBox(height: 30),
                    _buildSectionTitle("Salles & Laboratoires"),
                    const SizedBox(height: 15),
                  ]),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 15,
                    crossAxisSpacing: 15,
                    childAspectRatio: 0.85,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => _buildRoomCard(_rooms[index]),
                    childCount: _rooms.length,
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 120)),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
      floatingActionButton: FloatingActionButton(
        backgroundColor: _noraAccentBlue,
        elevation: 8,
        onPressed: () {},
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 30),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  // --- WIDGETS DE CONSTRUCTION ---

  Widget _buildAppBar() {
    return SliverAppBar(
      floating: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      leading: Builder(
        builder: (context) => IconButton(
          icon: const Icon(Icons.menu_rounded, color: _noraAccentBlue, size: 28),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
      ),
      title: const Row(
        children: [
          Text("Nora", style: TextStyle(color: _noraAccentBlue, fontWeight: FontWeight.w900, fontSize: 24)),
          Text(" Air", style: TextStyle(color: _softBlue, fontWeight: FontWeight.w400, fontSize: 24)),
        ],
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 15),
          child: CircleAvatar(
            backgroundColor: Colors.white,
            child: IconButton(
              icon: const Icon(Icons.notifications_none_rounded, color: _noraAccentBlue),
              onPressed: () {},
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWelcomeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Bonjour,", 
          style: TextStyle(fontSize: 16, color: _noraAccentBlue.withOpacity(0.6), fontWeight: FontWeight.w500)),
        const Text("Utilisateur Nora", 
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: _noraAccentBlue)),
      ],
    );
  }

  Widget _buildGlobalAQICard() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: const LinearGradient(
          colors: [_noraAccentBlue, _softBlue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(color: _softBlue.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: Stack(
          children: [
            Positioned(
              right: -20, top: -20,
              child: Icon(Icons.wb_cloudy_rounded, size: 150, color: Colors.white.withOpacity(0.1)),
            ),
            Padding(
              padding: const EdgeInsets.all(25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Qualité de l'air globale", 
                    style: TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Text("84", 
                        style: TextStyle(color: Colors.white, fontSize: 55, fontWeight: FontWeight.w900)),
                      const SizedBox(width: 15),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(20)),
                            child: const Text("BON", 
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                          ),
                          const SizedBox(height: 4),
                          const Text("Index AQI", style: TextStyle(color: Colors.white70, fontSize: 14)),
                        ],
                      )
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _cardInfoTile(Icons.thermostat_rounded, "22°C"),
                      _cardInfoTile(Icons.water_drop_rounded, "50%"),
                      _cardInfoTile(Icons.info_outline_rounded, "1 Alerte"),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _cardInfoTile(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, color: Colors.white, size: 18),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildRoomCard(Map<String, dynamic> room) {
    return InkWell(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => RoomDetailPage(room: room))),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.6),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(room['icon'], color: _noraAccentBlue, size: 30),
                  const Spacer(),
                  Text(room['name'],
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: _noraAccentBlue)),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("${room['aqi']} AQI", 
                        style: TextStyle(color: room['color'], fontWeight: FontWeight.w900, fontSize: 16)),
                      Icon(Icons.circle, color: room['color'], size: 10),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow() {
    return Row(
      children: [
        Expanded(child: _miniSummaryCard("Salles Actives", "4 / 5", _accentGreen)),
        const SizedBox(width: 15),
        Expanded(child: _miniSummaryCard("Alertes", "1", _warningRed)),
      ],
    );
  }

  Widget _miniSummaryCard(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(color: _noraAccentBlue.withOpacity(0.6), fontSize: 12, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: _noraAccentBlue));
  }

Widget _buildBottomNav() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      height: 70,
      decoration: BoxDecoration(
        color: _noraAccentBlue.withOpacity(0.95),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [BoxShadow(color: _noraAccentBlue.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BottomNavigationBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          currentIndex: _selectedIndex,
          selectedItemColor: _softBlue,
          unselectedItemColor: Colors.white54,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.dashboard_rounded), label: ""),
            BottomNavigationBarItem(icon: Icon(Icons.bar_chart_rounded), label: ""), // Index 1
            BottomNavigationBarItem(icon: SizedBox.shrink(), label: ""),
            BottomNavigationBarItem(icon: Icon(Icons.notifications_active_outlined), label: ""),
            BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: ""),
          ],
          onTap: (i) {
            setState(() => _selectedIndex = i);
            // LOGIQUE DE NAVIGATION
            if (i == 1) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Statistique()),
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: _bgColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.horizontal(right: Radius.circular(30))),
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(color: _noraAccentBlue),
            accountName: const Text("Utilisateur Nora", style: TextStyle(fontWeight: FontWeight.bold)),
            accountEmail: const Text("contact@nora-ai.com"),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.person, color: _noraAccentBlue, size: 40),
            ),
          ),
          _drawerItem(Icons.history_rounded, "Historique"),
          _drawerItem(Icons.favorite_rounded, "Salles favorites"),
          _drawerItem(Icons.settings_rounded, "Paramètres"),
          const Divider(),
          _drawerItem(Icons.help_outline_rounded, "Aide & Support"),
          const Spacer(),
          _drawerItem(Icons.logout_rounded, "Déconnexion", color: _warningRed),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _drawerItem(IconData icon, String title, {Color color = _noraAccentBlue, VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title, style: TextStyle(color: color, fontWeight: FontWeight.w600)),
      onTap: onTap,
    );
  }
}

// --- PAGE DÉTAIL (VERSION AMÉLIORÉE) ---

class RoomDetailPage extends StatelessWidget {
  final Map<String, dynamic> room;
  const RoomDetailPage({super.key, required this.room});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(room['name'], style: const TextStyle(color: Color(0xFF201293), fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF201293)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25),
        child: Column(
          children: [
            _buildCircularGauge(),
            const SizedBox(height: 40),
            _buildDetailGrid(),
          ],
        ),
      ),
    );
  }

  Widget _buildCircularGauge() {
    return Center(
      child: Container(
        width: 220,
        height: 220,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          boxShadow: [BoxShadow(color: room['color'].withOpacity(0.2), blurRadius: 30, spreadRadius: 10)],
          border: Border.all(color: room['color'].withOpacity(0.1), width: 15),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("${room['aqi']}", 
              style: TextStyle(fontSize: 65, fontWeight: FontWeight.w900, color: room['color'])),
            Text("Index AQI", style: TextStyle(fontSize: 16, color: Colors.grey.shade600, fontWeight: FontWeight.w500)),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(color: room['color'], borderRadius: BorderRadius.circular(20)),
              child: Text(room['status'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildDetailGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 20,
      crossAxisSpacing: 20,
      childAspectRatio: 1.4,
      children: [
        _detailTile(Icons.thermostat_rounded, "Température", room['temp'], Colors.orange),
        _detailTile(Icons.water_drop_rounded, "Humidité", room['hum'], Colors.blue),
        _detailTile(Icons.sensors_rounded, "Capteur", "Actif", Colors.green),
        _detailTile(Icons.timer_rounded, "Mise à jour", "2 min", Colors.grey),
      ],
    );
  }

  Widget _detailTile(IconData icon, String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const Spacer(),
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500)),
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF201293))),
        ],
      ),
    );
  }
}