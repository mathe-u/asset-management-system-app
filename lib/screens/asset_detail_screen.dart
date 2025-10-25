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
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(fontWeight: FontWeight.w500, fontSize: 18),
          ),
          SizedBox(height: 2),
          Text(
            value,
            style: GoogleFonts.inter(
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<String> assetImages = ['images/asset.png', 'images/asset.png'];

    return Scaffold(
      appBar: AppBar(
        title: Text('Detalhes do Ativo'),
        centerTitle: true,
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.edit)),
          IconButton(
            onPressed: () => _deletAsset(context),
            icon: Icon(Icons.delete),
          ),
        ],
      ),
      backgroundColor: const Color(0xfff8f9fa),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: 240,
              width: double.infinity,
              child: assetImages.length > 1
                  ? PageView.builder(
                      itemCount: assetImages.length,
                      itemBuilder: (context, index) {
                        return Image.asset(
                          assetImages[index],
                          fit: BoxFit.cover,
                          width: double.infinity,
                        );
                      },
                    )
                  : Image.asset(
                      assetImages.first,
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
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
                      _buildDetailRow('Status', asset.status),
                      _buildDetailRow('Responsavel', asset.custodian),
                      _buildDetailRow('Categoria', asset.category),
                      _buildDetailRow('Local', asset.location),
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


// Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             Card(
//               color: Colors.white,
//               child: Padding(
//                 padding: const EdgeInsets.all(16.0),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
                    
//                     SizedBox(height: 8),
                    

//                     _buildDetailRow('Status', asset.status),
//                     _buildDetailRow('Responsavel', asset.custodian),
//                     _buildDetailRow('Categoria', asset.category),
//                     _buildDetailRow('Local', asset.location),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),