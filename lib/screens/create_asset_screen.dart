import 'package:flutter/material.dart';

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
  bool _isLoading = false;

  String? _selectedStatus = null;

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

  @override
  void dispose() {
    _nameController.dispose();
    _categoryController.dispose();
    _userController.dispose();
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
                    hintStyle: const TextStyle(color: Colors.grey),
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
                TextFormField(
                  controller: _categoryController,
                  decoration: InputDecoration(
                    hintText: 'Selecione a categoria',
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
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Por favor, preencha o campo';
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
                TextFormField(
                  controller: _userController,
                  decoration: InputDecoration(
                    // labelText: 'Usuário Responsável',
                    hintText: 'Selecione um usuário responsável',
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
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Por favor, preencha o campo';
                    }
                    return null;
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
                TextFormField(
                  controller: TextEditingController(),
                  decoration: InputDecoration(
                    // labelText: 'Usuário Responsável',
                    hintText: 'Selecione um local',
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
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Por favor, preencha o campo';
                    }
                    return null;
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
                  // initialValue: '_selectedStatus',
                  decoration: InputDecoration(
                    hintText: 'Selecione o status',
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
                        : const Text('Criar Asset'),
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
