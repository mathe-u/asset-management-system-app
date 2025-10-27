import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/asset.dart';
import '../screens/login_screen.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../models/user.dart';
import '../screens/asset_screen.dart';
import '../screens/create_asset_screen.dart';
import '../screens/scanner_screen.dart';

class MainAssetScreen extends StatefulWidget {
  const MainAssetScreen({super.key});

  @override
  State<MainAssetScreen> createState() => _MainAssetScreenState();
}

class _MainAssetScreenState extends State<MainAssetScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    AssetScreen(),
    ScannerScreen(),
    CreateAssetScreen(),
  ];

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  User? _user;

  final Set<Asset> _selectedAssets = {};
  bool get _isSelectionMode => _selectedAssets.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  void _loadUserInfo() async {
    final int? userId = await StorageService.getUserId();
    final User user = await ApiService.getUserById(userId);

    if (mounted) {
      setState(() {
        _user = user;
      });
    }
  }

  void _clearSelection() {
    setState(() {
      _selectedAssets.clear();
    });
  }

  Future<void> _handleLogout(BuildContext context) async {
    await StorageService.deleteToken();
    await ApiService.logout();
    if (context.mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  AppBar _buildAppBar() {
    if (_isSelectionMode) {
      return AppBar(
        backgroundColor: Color(0xFFEA2831),
        title: Text(
          '${_selectedAssets.length} selecionado(s)',
          style: GoogleFonts.inter(color: Colors.white),
        ),
        leading: IconButton(
          onPressed: _clearSelection,
          icon: const Icon(Icons.close, color: Colors.white),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.print, color: Colors.white),
            tooltip: 'Imprimir Etiquetas',
          ),
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.delete, color: Colors.white),
            tooltip: 'Deletar Ativos',
          ),
        ],
      );
    } else {
      return AppBar(
        backgroundColor: Color(0xFFEA2831),
        title: Text(
          'Assets',
          style: GoogleFonts.inter(
            color: Colors.white,
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
          icon: Icon(Icons.menu, color: Colors.white, size: 30),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final Widget sideBar = Drawer(
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 45, 16, 25),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: const Color(0xFFFEE2E2),
                  child: Text(
                    (_user?.username != null && _user!.username.isNotEmpty)
                        ? _user!.username[0].toUpperCase()
                        : '?',
                    style: GoogleFonts.inter(
                      color: const Color(0xFFDC2626),
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _user?.username ?? 'Carregando...',
                      style: GoogleFonts.inter(
                        color: Colors.black,
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      _user?.email ?? 'Carregando...',
                      style: GoogleFonts.inter(
                        color: Colors.grey[600],
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(
            color: Colors.grey,
            thickness: 0.4,
            height: 1,
            indent: 0,
            endIndent: 0,
          ),
          Expanded(child: Container()),
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton.icon(
              onPressed: () => _handleLogout(context),
              icon: Icon(
                Icons.logout,
                color: const Color(0xFFDC2626),
                size: 24,
              ),
              label: Text(
                'Sair',
                style: GoogleFonts.inter(
                  color: const Color(0xFFDC2626),
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFEE2E2),
                foregroundColor: const Color(0xFFDC2626),
                minimumSize: Size(double.infinity, 50),
                elevation: 0,
                surfaceTintColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                shadowColor: Colors.transparent,
                alignment: Alignment.centerLeft,
              ),
            ),
          ),
        ],
      ),
    );

    final Container navigationBar = Container(
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0xffe5e7eb), width: 1.0)),
      ),
      child: BottomNavigationBar(
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFFDC2626),
        unselectedItemColor: Color(0xff6c757d),
        currentIndex: _currentIndex,
        onTap: (index) => setState(() {
          _currentIndex = index;
        }),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory_2_outlined),
            activeIcon: Icon(Icons.inventory_2),
            label: 'Ativos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.qr_code_scanner_outlined),
            activeIcon: Icon(Icons.qr_code_scanner),
            label: 'Scanner',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline),
            activeIcon: Icon(Icons.add_circle),
            label: 'Criar',
          ),
        ],
      ),
    );

    return Scaffold(
      key: _scaffoldKey,
      appBar: _buildAppBar(),
      drawer: sideBar,
      backgroundColor: const Color(0xFFF8F9FA),
      body: _screens[_currentIndex],
      bottomNavigationBar: navigationBar,
    );
  }
}
