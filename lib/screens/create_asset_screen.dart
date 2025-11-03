import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../models/user.dart';
import '../services/api_service.dart';

class CreateAssetScreen extends StatefulWidget {
  const CreateAssetScreen({super.key});

  @override
  State<StatefulWidget> createState() {
    return _CreateAssetState();
  }
}

class _CreateAssetState extends State<CreateAssetScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _categoryController = TextEditingController();
  final _userController = TextEditingController();
  final _locationController = TextEditingController();
  bool _isLoading = false;

  String? _selectedCategory;
  String? _selectedStatus;
  String? _selectedUser;
  String? _selectedLocation;

  List<String> _categories = [];
  bool _categoriesLoading = true;
  String? _categoriesError;

  List<User> _users = [];
  bool _usersLoading = true;
  String? _usersError;

  List<String> _locations = [];
  bool _locationsLoading = true;
  String? _locationsError;

  final List<File> _images = [];
  final ImagePicker _picker = ImagePicker();

  final List<String> _statusChoices = [
    'Disponivel',
    'Em Uso',
    'Manutenção',
    'Quebrado',
  ];

  void _createAsset() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Asset criado com sucesso!')),
        );
        _nameController.clear();
        _categoryController.clear();
        _userController.clear();
        setState(() {
          _images.clear();
          _selectedStatus = null;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro ao criar asset: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      setState(() {
        _images.add(File(pickedFile.path));
      });
    }
  }

  Future<void> _loadCategories() async {
    try {
      final categories = await ApiService.getCategories();
      setState(() {
        _categories = categories.cast<String>();
        _categoriesLoading = false;
      });
    } catch (e) {
      setState(() {
        _categoriesError = 'Erro ao carregar categorias';
        _categoriesLoading = false;
      });
    }
  }

  Future<void> _loadUsers() async {
    try {
      final List<User> users = await ApiService.getUsers();
      setState(() {
        _users = users;
      });
    } catch (e) {
      setState(() {
        _usersError = 'Erro ao carregar usuarios';
      });
    } finally {
      setState(() {
        _usersLoading = false;
      });
    }
  }

  Future<void> _loadLocations() async {
    try {
      final List<String> locations = await ApiService.getLocations();
      setState(() {
        _locations = locations;
      });
    } catch (e) {
      setState(() {
        _locationsError = 'Erro ao carregar locais';
      });
    } finally {
      setState(() {
        _locationsLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _loadUsers();
    _loadLocations();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _categoryController.dispose();
    _userController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        color: const Color(0xfff5f7f8),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Nome',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.left,
                ),

                const SizedBox(height: 8),
                TextFormField(
                  controller: _nameController,

                  decoration: InputDecoration(
                    hintText: 'Nome do Ativo',
                    hintStyle: const TextStyle(color: Color(0xff60708a)),
                    filled: true,
                    fillColor: Colors.white,
                    border: const OutlineInputBorder(),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 15,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        color: Color(0xFFdbdfe6),
                        width: 1,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        color: Color(0xFFdbdfe6),
                        width: 1.5,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Por favor, preencha o campo';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),
                const Text(
                  'Categoria',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.left,
                ),
                const SizedBox(height: 8),
                _categoriesLoading
                    ? const SizedBox(
                        height: 56,
                        child: Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFFFF7043),
                          ),
                        ),
                      )
                    : _categoriesError != null
                    ? TextFormField(
                        enabled: false,
                        decoration: InputDecoration(
                          hintText: _categoriesError,
                          filled: true,
                          fillColor: Colors.red[50],
                          border: const OutlineInputBorder(),
                        ),
                      )
                    : DropdownButtonFormField<String>(
                        initialValue: _selectedCategory,
                        hint: const Text(
                          'Selecione a categoria',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                        decoration: InputDecoration(
                          hintText: '',
                          hintStyle: const TextStyle(color: Colors.black),
                          filled: true,
                          fillColor: Colors.white,
                          border: const OutlineInputBorder(),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 15,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: Color(0xFFdbdfe6),
                              width: 1,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: Color(0xFFdbdfe6),
                              width: 1.5,
                            ),
                          ),
                        ),
                        items: _categories.map((category) {
                          return DropdownMenuItem(
                            value: category,
                            child: Text(category),
                          );
                        }).toList(),
                        onChanged: _isLoading
                            ? null
                            : (value) {
                                setState(() {
                                  _selectedCategory = value;
                                  _categoryController.text = value ?? '';
                                });
                              },
                      ),

                const SizedBox(height: 16),
                const Text(
                  'Status',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.left,
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  // value: _selectedStatus,
                  initialValue: _selectedStatus,
                  hint: Text(
                    'Selecione o status',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  decoration: InputDecoration(
                    // hintText: 'Selecione o status',
                    hintStyle: const TextStyle(color: Colors.black),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 15,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: Color(0xFFdbdfe6),
                        width: 1,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: Color(0xFFdbdfe6),
                        width: 1.5,
                      ),
                    ),
                  ),

                  items: _statusChoices.map((status) {
                    return DropdownMenuItem(value: status, child: Text(status));
                  }).toList(),

                  onChanged: _isLoading
                      ? null
                      : (value) {
                          setState(() {
                            _selectedStatus = value;
                          });
                        },

                  validator: (value) {
                    if (value == null) {
                      return 'Por favor, selecione um status';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),
                const Text(
                  'Responsável',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.left,
                ),
                const SizedBox(height: 8),
                _usersLoading
                    ? const SizedBox(
                        height: 56,
                        child: Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFFFF7043),
                          ),
                        ),
                      )
                    : _usersError != null
                    ? TextFormField(
                        enabled: false,
                        decoration: InputDecoration(
                          hintText: _usersError,
                          filled: true,
                          fillColor: Colors.red[50],
                          border: const OutlineInputBorder(),
                        ),
                      )
                    : DropdownButtonFormField(
                        initialValue: _selectedUser,
                        hint: const Text(
                          'Selecione um usuário responsável',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                        // style: const TextStyle(color: Colors.black),
                        decoration: InputDecoration(
                          hintText: '',
                          hintStyle: const TextStyle(color: Colors.black),
                          filled: true,
                          fillColor: Colors.white,
                          border: const OutlineInputBorder(),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 15,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: Color(0xFFdbdfe6),
                              width: 1,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: Color(0xFFdbdfe6),
                              width: 1.5,
                            ),
                          ),
                        ),
                        items: _users.map((user) {
                          return DropdownMenuItem(
                            value: user.username,
                            child: Text(user.username),
                          );
                        }).toList(),
                        onChanged: _isLoading
                            ? null
                            : (value) {
                                setState(() {
                                  // _selectedUser = value;
                                  // _userController.text = value ?? '';
                                });
                              },
                      ),

                const SizedBox(height: 16),
                const Text(
                  'Local',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.left,
                ),
                const SizedBox(height: 8),
                _locationsLoading
                    ? const SizedBox(
                        height: 56,
                        child: Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFFFF7043),
                          ),
                        ),
                      )
                    : _locationsError != null
                    ? TextFormField(
                        enabled: false,
                        decoration: InputDecoration(
                          hintText: _locationsError,
                          filled: true,
                          fillColor: Colors.red[50],
                          border: const OutlineInputBorder(),
                        ),
                      )
                    : DropdownButtonFormField(
                        initialValue: _selectedLocation,
                        hint: const Text(
                          'Selecione um local',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                        // style: const TextStyle(color: Colors.black),
                        decoration: InputDecoration(
                          hintText: '',
                          hintStyle: const TextStyle(color: Colors.black),
                          filled: true,
                          fillColor: Colors.white,
                          border: const OutlineInputBorder(),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 15,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: Color(0xFFdbdfe6),
                              width: 1,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: Color(0xFFdbdfe6),
                              width: 1.5,
                            ),
                          ),
                        ),
                        items: _locations.map((location) {
                          return DropdownMenuItem(
                            value: location,
                            child: Text(location),
                          );
                        }).toList(),
                        onChanged: _isLoading
                            ? null
                            : (value) {
                                setState(() {});
                              },
                      ),

                // TextFormField(
                //   controller: TextEditingController(),
                //   decoration: InputDecoration(
                //     // labelText: 'Usuário Responsável',
                //     hintText: 'Selecione um local',
                //     hintStyle: const TextStyle(color: Colors.black),
                //     filled: true,
                //     fillColor: Colors.white,
                //     border: const OutlineInputBorder(),
                //     contentPadding: const EdgeInsets.symmetric(
                //       horizontal: 12,
                //       vertical: 15,
                //     ),
                //     enabledBorder: OutlineInputBorder(
                //       borderRadius: BorderRadius.circular(8),
                //       borderSide: const BorderSide(
                //         color: Color(0xFFdbdfe6),
                //         width: 1,
                //       ),
                //     ),
                //     focusedBorder: OutlineInputBorder(
                //       borderRadius: BorderRadius.circular(8),
                //       borderSide: const BorderSide(
                //         color: Color(0xFFdbdfe6),
                //         width: 1.5,
                //       ),
                //     ),
                //   ),
                // ),
                const SizedBox(height: 16),
                const Text(
                  'Imagem',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.left,
                ),

                const SizedBox(height: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ..._images.map((image) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            image,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                      );
                    }),

                    GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: CustomPaint(
                          painter: DashedBorderPainter(),
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.add_a_photo_outlined,
                                  size: 24,
                                  color: const Color(0xff60708a),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Adicionar Imagem',
                                  style: TextStyle(
                                    color: const Color(0xff60708a),
                                    fontSize: 20,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _createAsset,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF7043),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),

                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Criar Asset',
                            style: TextStyle(fontSize: 20),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class DashedBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFd1d5db)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    const dashWidth = 9.0;
    const dashSpace = 7.0;
    double startX = 0;
    double startY = 0;

    while (startX < size.width) {
      canvas.drawLine(Offset(startX, 0), Offset(startX + dashWidth, 0), paint);
      startX += dashWidth + dashSpace;
    }

    startX = size.width;
    startY = 0;
    while (startY < size.height) {
      canvas.drawLine(
        Offset(startX, startY),
        Offset(startX, startY + dashWidth),
        paint,
      );
      startY += dashWidth + dashSpace;
    }

    startX = size.width;
    startY = size.height;
    while (startX > 0) {
      canvas.drawLine(
        Offset(startX, startY),
        Offset(startX - dashWidth, startY),
        paint,
      );
      startX -= dashWidth + dashSpace;
    }

    startX = 0;
    startY = size.height;
    while (startY > 0) {
      canvas.drawLine(
        Offset(startX, startY),
        Offset(startX, startY - dashWidth),
        paint,
      );
      startY -= dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
