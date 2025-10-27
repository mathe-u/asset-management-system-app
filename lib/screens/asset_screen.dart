import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/asset.dart';
import '../screens/asset_detail_screen.dart';
import '../services/api_service.dart';

class AssetScreen extends StatefulWidget {
  const AssetScreen({super.key});

  @override
  State<AssetScreen> createState() => _AssetScreenState();
}

class _AssetScreenState extends State<AssetScreen> {
  List<Asset> _assets = [];
  List<Asset> _filteredAssets = [];
  bool _isLoading = true;
  String? _error;
  final TextEditingController _searchController = TextEditingController();
  final Set<Asset> _selectedAssets = {};

  bool get _isSelectionMode => _selectedAssets.isNotEmpty;

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
        _error = e.toString();
        _isLoading = false;
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

  void _filterAssets() {
    final String query = _searchController.text.toLowerCase();
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

  @override
  void initState() {
    _loadAssets();
    _searchController.addListener(_filterAssets);
    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Column body = Column(
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
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(40),

                        child: ListTile(
                          splashColor: Colors.transparent,
                          // hoverColor: Colors.transparent,
                          selectedColor: Colors.grey.shade800,
                          iconColor: Colors.black,
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
                      ),
                    );
                  },
                ),
        ),
      ],
    );

    return Scaffold(body: body);
  }
}
