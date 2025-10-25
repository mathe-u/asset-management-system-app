import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/asset.dart';
import '../screens/login_screen.dart';
import '../screens/asset_detail_screen.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../models/user.dart';

class MainAssetScreen extends StatefulWidget {
  const MainAssetScreen({super.key});

  @override
  State<MainAssetScreen> createState() => _MainAssetScreenState();
}

class _MainAssetScreenState extends State<MainAssetScreen> {
  // int _currentIndex = 0;

  // final List<Widget> _screens = const [];

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List<Asset> _assets = [];
  List<Asset> _filteredAssets = [];
  User? _user;
  bool _isLoading = true;
  String? _error;
  final TextEditingController _searchController = TextEditingController();

  final Set<Asset> _selectedAssets = {};
  bool get _isSelectionMode => _selectedAssets.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _loadAssets();
    _loadUserInfo();
    _searchController.addListener(_filterAssets);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterAssets() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredAssets = _assets;
      } else {
        _filteredAssets = _assets.where((asset) {
          return asset.name.toLowerCase().contains(query);
        }).toList();
      }
    });
  }

  void _loadUserInfo() async {
    final int? userId = await StorageService.getUserId();
    final User user = await ApiService.getUserById(userId);

    print(user.id);
    print(user.username);
    print(user.email);

    if (mounted) {
      setState(() {
        _user = user;
      });
    }
  }

  void _loadAssets() async {
    setState(() {
      _isLoading = true;
      _error = null;
      _isLoading = false;
    });

    try {
      final List<Asset> assets = await ApiService.getAssets();

      if (mounted) {
        setState(() {
          _assets = assets;
          _filteredAssets = assets;

          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  void _showAssetDetail(Asset asset) {
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (context) => AssetDetailScreen(asset: asset),
          ),
        )
        .then((_) => _loadAssets());
  }

  void _toggleSelection(Asset asset) {
    setState(() {
      if (_selectedAssets.contains(asset)) {
        _selectedAssets.remove(asset);
      } else {
        _selectedAssets.add(asset);
      }
    });
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

    return Scaffold(
      key: _scaffoldKey,
      appBar: _buildAppBar(),
      drawer: sideBar,
      backgroundColor: const Color(0xFFF8F9FA),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16.0),
            color: const Color(0xFFF8F9FA),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Buscar...',
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Erro: $_error'),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadAssets,
                          child: const Text('Tentar Novamente'),
                        ),
                      ],
                    ),
                  )
                : _filteredAssets.isEmpty
                ? const Center(child: Text('Nenhum asset encontrado'))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _filteredAssets.length,
                    itemBuilder: (context, index) {
                      final asset = _filteredAssets[index];
                      final isSelected = _selectedAssets.contains(asset);

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        color: Colors.white,
                        elevation: isSelected ? 4 : 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: ListTile(
                          selected: isSelected,
                          selectedTileColor: const Color.fromARGB(
                            255,
                            255,
                            150,
                            150,
                          ).withValues(alpha: 0.2),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          leading: Container(
                            width: 45,
                            height: 45,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFFDC2626)
                                  : const Color(0xFFF3F4F6),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: isSelected
                                  ? const Icon(Icons.check, color: Colors.white)
                                  : Text(
                                      asset.name[0].toUpperCase(),
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20,
                                      ),
                                    ),
                            ),
                          ),
                          title: Text(
                            asset.name,
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w500,
                              fontSize: 18,
                              color: Colors.black,
                            ),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Código: ${asset.code}',
                                  style: const TextStyle(fontSize: 14),
                                ),
                                Text(
                                  asset.location,
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                          trailing: _isSelectionMode
                              ? null
                              : const Icon(Icons.arrow_forward_ios, size: 16),
                          onTap: () {
                            if (_isSelectionMode) {
                              _toggleSelection(asset);
                            } else {
                              _showAssetDetail(asset);
                            }
                          },
                          onLongPress: () {
                            _toggleSelection(asset);
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

// AppBar(
//         backgroundColor: const Color(0xFFDC2626),
        // title: Text(
        //   'Assets',
        //   style: GoogleFonts.inter(
        //     color: Colors.white,
        //     fontSize: 26,
        //     fontWeight: FontWeight.bold,
        //   ),
        // ),
//         centerTitle: true,
        
//       ),
