import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/asset.dart';
import '../services/api_service.dart';
import '../screens/main_screen.dart';

class AssetDetailScreen extends StatefulWidget {
  final Asset asset;
  const AssetDetailScreen({super.key, required this.asset});

  @override
  State<StatefulWidget> createState() {
    return _AsserDetailScreenState();
  }
}

class _AsserDetailScreenState extends State<AssetDetailScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  bool _isEditing = false;
  bool _isSaving = false;

  List<String> _statusChoices = [];
  bool _statusLoading = false;
  String? _statusError;
  String? _selectedStatus;
  late String _displayStatusChoices;
  late String _currentAssetStatus;

  List<String> _custodians = [];
  bool _custodianLoding = false;
  String? _custodianError;
  String? _selectedCustodian;
  late String _displayCustodian;

  List<String> _categories = [];
  bool _categoriesLoading = false;
  String? _categoriesError;
  String? _selectedCategory;
  late String _displayCategory;

  List<String> _locations = [];
  bool _locationsLoading = false;
  String? _locationsError;
  String? _selectedLocation;
  late String _displayLocation;

  final Map<String, String> _statusTranslations = {
    'available': 'Disponível',
    'broken': 'Quebrado',
    'maintenance': 'Manutenção',
    'inuse': 'Em Uso',
  };

  @override
  void initState() {
    super.initState();
    _currentAssetStatus = widget.asset.status;
    _displayStatusChoices =
        _statusTranslations[widget.asset.status] ?? widget.asset.status;
    _displayCustodian = widget.asset.custodian;
    _displayCategory = widget.asset.category;
    _displayLocation = widget.asset.location;
    _loadStatus();
    _loadCustodian();
    _loadCategories();
    _loadLocations();
  }

  void _deletAsset(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: Text(
          'Deseja realmente excluir o asset "${widget.asset.name}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Excluir'),
          ),
        ],
        backgroundColor: Colors.white,
      ),
    );

    if (confirm == true && context.mounted) {
      try {
        await ApiService.deleteAsset(widget.asset.code);

        if (!context.mounted) return;

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Asset excluído com sucesso')));

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MainScreen()),
        );
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showMaterialBanner(
            MaterialBanner(content: Text('data'), actions: []),
          );
        }
      }
    }
  }

  Future<void> _loadStatus() async {
    setState(() {
      _statusLoading = true;
      _statusError = null;
    });
    try {
      final status = await ApiService.getStatusChoices();
      if (mounted) {
        setState(() {
          _statusChoices = status.cast<String>();
          _statusLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _statusError = 'Erro';
          _statusLoading = false;
        });
      }
    }
  }

  Future<void> _loadCustodian() async {
    setState(() {
      _custodianLoding = true;
      _custodianError = null;
    });
    try {
      final users = await ApiService.getUsers();
      if (mounted) {
        setState(() {
          _custodians = users.map((user) {
            return user.username;
          }).toList();
          _custodianLoding = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _categoriesError = "Erro categories";
          _categoriesLoading = false;
        });
      }
    }
  }

  Future<void> _loadCategories() async {
    setState(() {
      _categoriesLoading = true;
      _categoriesError = null;
    });
    try {
      final categories = await ApiService.getCategories();
      if (mounted) {
        setState(() {
          _categories = categories.cast<String>();
          _categoriesLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _categoriesError = "Erro categories";
          _categoriesLoading = false;
        });
      }
    }
  }

  Future<void> _loadLocations() async {
    setState(() {
      _locationsLoading = true;
      _locationsError = null;
    });

    try {
      final locations = await ApiService.getLocations();
      if (mounted) {
        setState(() {
          _locations = locations.cast<String>();
          _locationsLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _locationsError = "Erro categories";
          _locationsLoading = false;
        });
      }
    }
  }

  void _toggleEdit() {
    setState(() {
      if (!_isEditing) {
        _selectedStatus = _currentAssetStatus;
        _selectedCustodian = _displayCustodian;
        _selectedCategory = _displayCategory;
        _selectedLocation = _displayLocation;
        if (_categories.isEmpty && _categoriesError != null ||
            _statusChoices.isEmpty && _statusError != null) {
          _loadStatus();
          _loadCustodian();
          _loadCategories();
          _loadLocations();
        }
      }
      _isEditing = !_isEditing;
    });
  }

  Future<void> _save() async {
    if (_selectedCategory == null || _selectedCategory == _displayCategory) {
      _toggleEdit();
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      await ApiService.updateAsset(widget.asset.code, {
        'status': _selectedStatus,
        'custodian': _selectedCustodian,
        'category': _selectedCategory,
        'location': _selectedLocation,
      });

      if (!mounted) return;

      setState(() {
        _currentAssetStatus = _selectedStatus!;
        _displayStatusChoices =
            _statusTranslations[_selectedStatus!] ?? _selectedStatus!;
        _displayCustodian = _selectedCustodian!;
        _displayCategory = _selectedCategory!;
        _displayLocation = _selectedLocation!;
        _isEditing = false;
        _isSaving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Categoria atualizada'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error on updating: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildDetailRow(String label, String value, {Widget? customContent}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w500,
              fontSize: 18,
              // color: Colors.blueAccent,
            ),
          ),

          // const SizedBox(height: 2),
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child:
                  customContent ??
                  Text(
                    value,
                    textAlign: TextAlign.end,
                    style: GoogleFonts.inter(
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                      fontSize: 18,
                    ),
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomDropdown(
    List<String> items,
    String? selectedItem,
    bool isLoading,
    String? error,
    ValueChanged<String?> onChanged, // Adicionado parâmetro de callback
  ) {
    if (isLoading) {
      return const SizedBox(
        height: 24,
        width: 24,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: Color(0xFFFF7043),
        ),
      );
    }

    if (error != null) {
      return Text(
        'Erro',
        style: TextStyle(color: Colors.red[300], fontSize: 14),
      );
    }

    return DropdownButtonFormField<String>(
      initialValue: items.contains(selectedItem) ? selectedItem : null,
      isExpanded: true,
      icon: const Icon(Icons.arrow_drop_down, color: Colors.grey, size: 18),
      decoration: const InputDecoration(
        isDense: true,
        contentPadding: EdgeInsets.zero,
        border: OutlineInputBorder(borderSide: BorderSide.none),
      ),
      alignment: AlignmentDirectional.centerEnd,

      // Lista de opções (Aberta)
      items: items.map((itemKey) {
        return DropdownMenuItem(
          value: itemKey, // O valor interno é a chave (ex: 'available')
          child: Text(
            _statusTranslations[itemKey] ?? itemKey, // O texto é traduzido
            textAlign: TextAlign.right,
            style: GoogleFonts.inter(
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
              fontSize: 18,
            ),
          ),
        );
      }).toList(),

      // O que aparece quando o item é SELECIONADO (Fechado)
      selectedItemBuilder: (BuildContext context) {
        return items.map<Widget>((String itemKey) {
          return Container(
            alignment: Alignment.centerRight,
            child: Text(
              _statusTranslations[itemKey] ??
                  itemKey, // <--- TRADUÇÃO AQUI TAMBÉM
              textAlign: TextAlign.right,
              style: GoogleFonts.inter(
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
                fontSize: 18,
              ),
            ),
          );
        }).toList();
      },

      // Callback para atualizar o estado na tela principal
      onChanged: onChanged,
    );
  }

  @override
  Widget build(BuildContext context) {
    final Asset asset = widget.asset;
    final List<String> assetImages = asset.images
        .map(
          (img) =>
              '${ApiService.getBaseUrl().replaceFirst(RegExp(r'/api$'), '')}${img.url}',
        )
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Detalhes do Ativo'),
        backgroundColor: const Color(0xfff8f9fa),
        centerTitle: true,
        actions: _isEditing
            ? [
                IconButton(
                  onPressed: _toggleEdit,
                  icon: const Icon(Icons.close, color: Colors.red),
                  tooltip: 'Cancelar',
                ),
                IconButton(
                  onPressed: _isSaving ? null : _save,
                  icon: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.check, color: Colors.green),
                  tooltip: 'Salvar',
                ),
              ]
            : [
                IconButton(
                  onPressed: _toggleEdit,
                  icon: const Icon(Icons.edit),
                  tooltip: 'Editar',
                ),
                IconButton(
                  onPressed: () => _deletAsset(context),
                  icon: Icon(Icons.delete),
                  tooltip: 'Deletar',
                ),
              ],
      ),
      backgroundColor: const Color(0xfff8f9fa),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.bottomCenter,
              children: [
                SizedBox(
                  height: 240,
                  width: double.infinity,
                  child: assetImages.isEmpty
                      ? const Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.image_not_supported,
                                size: 64,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Nenhuma imagem disponível',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        )
                      : PageView.builder(
                          controller: _pageController,
                          itemCount: assetImages.length,
                          onPageChanged: (index) {
                            setState(() {
                              _currentPage = index;
                            });
                          },
                          itemBuilder: (context, index) {
                            return Image.network(
                              assetImages[index],
                              fit: BoxFit.cover,
                              width: double.infinity,
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return const Center(
                                      child: CircularProgressIndicator(),
                                    );
                                  },
                              errorBuilder: (context, error, stackTrace) {
                                return const Center(
                                  child: Icon(
                                    Icons.broken_image,
                                    size: 48,
                                    color: Colors.grey,
                                  ),
                                );
                              },
                            );
                          },
                        ),
                ),

                if (assetImages.isNotEmpty)
                  Positioned(
                    bottom: 10,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(assetImages.length, (index) {
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          height: 8,
                          width: _currentPage == index ? 16 : 8,
                          decoration: BoxDecoration(
                            color: _currentPage == index
                                ? Colors.white
                                : Colors.white.withAlpha(128),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        );
                      }),
                    ),
                  ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Card(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        asset.name,
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.bold,
                          fontSize: 34,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Código: ${asset.code}',
                        style: GoogleFonts.inter(
                          color: Colors.grey[600],
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      _buildDetailRow(
                        'Status',
                        _displayStatusChoices,
                        customContent: _isEditing
                            ? _buildCustomDropdown(
                                _statusChoices,
                                _selectedStatus,
                                _statusLoading,
                                _statusError,
                                (value) {
                                  setState(() {
                                    _selectedStatus = value;
                                  });
                                },
                              )
                            : null,
                      ),

                      _buildDetailRow(
                        'Responsavel',
                        _displayCustodian,
                        customContent: _isEditing
                            ? _buildCustomDropdown(
                                _custodians,
                                _selectedCustodian,
                                _custodianLoding,
                                _custodianError,
                                (value) {
                                  setState(() {
                                    _selectedCustodian = value;
                                  });
                                },
                              )
                            : null,
                      ),

                      _buildDetailRow(
                        'Categoria',
                        _displayCategory,
                        customContent: _isEditing
                            ? _buildCustomDropdown(
                                _categories,
                                _selectedCategory,
                                _categoriesLoading,
                                _categoriesError,
                                (value) {
                                  setState(() {
                                    _selectedCategory = value;
                                  });
                                },
                              )
                            : null,
                      ),

                      _buildDetailRow(
                        'Local',
                        _displayLocation,
                        customContent: _isEditing
                            ? _buildCustomDropdown(
                                _locations,
                                _selectedLocation,
                                _locationsLoading,
                                _locationsError,
                                (value) {
                                  setState(() {
                                    _selectedLocation = value;
                                  });
                                },
                              )
                            : null,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
