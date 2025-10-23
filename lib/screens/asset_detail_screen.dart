import 'package:assets_app/models/asset.dart';
import 'package:assets_app/services/api_service.dart';
import 'package:flutter/material.dart';

class AssetDetailScreen extends StatelessWidget {
  final Asset asset;
  const AssetDetailScreen({super.key, required this.asset});

  void _deletAsset(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: Text('Deseja realmente excluir o asset "${asset.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      try {
        await ApiService.deleteAsset(asset.code);
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Asset excluído com sucesso')));
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showMaterialBanner(
            MaterialBanner(content: Text('data'), actions: []),
          );
        }
      }
    }
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(asset.name),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.edit)),
          IconButton(
            onPressed: () => _deletAsset(context),
            icon: Icon(Icons.delete),
          ),
        ],
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailRow('Nome', asset.name),
                    _buildDetailRow('Código', asset.code),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // @override
  // State<StatefulWidget> createState() {
  //   return _AssetDetailState();
  // }
}

// class _AssetDetailState extends State<AssetDetailScreen> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold();
//   }
// }
