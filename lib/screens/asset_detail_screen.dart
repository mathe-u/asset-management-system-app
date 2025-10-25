import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/asset.dart';
import '../services/api_service.dart';

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
        backgroundColor: Colors.white,
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
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(fontWeight: FontWeight.w500, fontSize: 20),
          ),
          SizedBox(height: 2),
          Text(
            value,
            style: GoogleFonts.inter(
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
              fontSize: 20,
            ),
          ),
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
      backgroundColor: const Color(0xfff8f9fa),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Card(
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
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
                    SizedBox(height: 8),
                    Text(
                      'Código: ${asset.code}',
                      style: GoogleFonts.inter(
                        color: Colors.grey[600],
                        fontSize: 18,
                        fontWeight: FontWeight.w400,
                      ),
                    ),

                    _buildDetailRow('Status', asset.status),
                    _buildDetailRow('Responsavel', asset.custodian),
                    _buildDetailRow('Categoria', asset.category),
                    _buildDetailRow('Local', asset.location),
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
