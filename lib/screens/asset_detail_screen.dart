import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/asset.dart';
import '../services/api_service.dart';

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
    final Asset asset = widget.asset;
    // final List<String> assetImages = [
    // 'https://lh3.googleusercontent.com/aida-public/',
    // 'https://lh3.googleusercontent.com/aida-public/AB6AXuAExuLLxNWza7jmqEKG8j4dA4PNYD5BnQ3lwHZh3YaMZN1TGqR8SpfIyP61MpIVX3irpJAsFyFxdGWws_LoUSFOh2_BRo_9u3WbEaCbxHkHqSDU8fRc3YqUnnYqLEvI-bfP-Zgy9h2g3S5X_7Z1WXHKmHIU4SW10dAYdEQ_T1K6uYt-wWsbUTF6YkgJHO2PQ8SNRTVHSyuReTOcgpm_WpqyyGZpOpt4pnKSpTBiZ1YmmgyNghRK-5fmhnL9_zRg1oMAFPx6VNdoum0',
    // 'https://lh3.googleusercontent.com/aida-public/AB6AXuAExuLLxNWza7jmqEKG8j4dA4PNYD5BnQ3lwHZh3YaMZN1TGqR8SpfIyP61MpIVX3irpJAsFyFxdGWws_LoUSFOh2_BRo_9u3WbEaCbxHkHqSDU8fRc3YqUnnYqLEvI-bfP-Zgy9h2g3S5X_7Z1WXHKmHIU4SW10dAYdEQ_T1K6uYt-wWsbUTF6YkgJHO2PQ8SNRTVHSyuReTOcgpm_WpqyyGZpOpt4pnKSpTBiZ1YmmgyNghRK-5fmhnL9_zRg1oMAFPx6VNdoum0',
    // ];
    final List<String> assetImages = asset.images
        .map((img) => 'http://192.168.0.108:8000${img.url}')
        .toList();

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
