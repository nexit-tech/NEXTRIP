import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart'; // Pra abrir o maps externo se clicar na seta
import '../theme/app_colors.dart';

class InternalMapPage extends StatefulWidget {
  final Map<String, dynamic> selectedStore;
  final List<Map<String, dynamic>> allStores;

  const InternalMapPage({
    super.key,
    required this.selectedStore,
    required this.allStores,
  });

  @override
  State<InternalMapPage> createState() => _InternalMapPageState();
}

class _InternalMapPageState extends State<InternalMapPage> {
  late GoogleMapController mapController;
  Set<Marker> _markers = {};
  late Map<String, dynamic> _currentStore;

  @override
  void initState() {
    super.initState();
    _currentStore = widget.selectedStore;
    _loadMarkers();
  }

  Future<void> _launchURL(String url) async {
    if (!await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication)) {
      debugPrint('Could not launch $url');
    }
  }

  // --- 1. PINOS MENORES E MAIS ELEGANTES ---
// --- VERSÃO OTIMIZADA PARA IMAGENS NO PINO ---
  Future<Uint8List> _createCustomMarkerBitmap(String? imageUrl, String name) async {
    final int size = 50; // <--- TAMANHO IDEAL (Nem gigante, nem formiga)
    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);
    final Paint paint = Paint();
    final double radius = size / 2;

    // 1. Círculo Preto (Fundo)
    paint.color = AppColors.black;
    canvas.drawCircle(Offset(radius, radius), radius, paint);

    // 2. Borda Branca Fina
    paint.color = AppColors.white;
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 4; // Borda mais fina pra não comer a foto
    canvas.drawCircle(Offset(radius, radius), radius - 2, paint);

    bool imageDrawn = false;
    
    // 3. Tenta desenhar a IMAGEM
    if (imageUrl != null) {
      try {
        final ByteData data = await NetworkAssetBundle(Uri.parse(imageUrl)).load("");
        // Redimensiona a imagem para caber exatamento no pino
        final ui.Codec codec = await ui.instantiateImageCodec(
          data.buffer.asUint8List(),
          targetHeight: size,
          targetWidth: size
        );
        final ui.FrameInfo fi = await codec.getNextFrame();
        
        // Recorta a imagem em círculo
        // Deixamos uma margem de 4px pra não cobrir a borda branca
        final Path clipPath = Path()..addOval(Rect.fromCircle(center: Offset(radius, radius), radius: radius - 4));
        canvas.clipPath(clipPath);
        canvas.drawImage(fi.image, Offset.zero, Paint());
        imageDrawn = true;
      } catch (e) {
        // Se der erro (CORS na web ou link quebrado), vai pro texto
        imageDrawn = false;
      }
    }

    // 4. Fallback: Se não conseguiu a imagem, desenha a INICIAL menorzinha
    if (!imageDrawn) {
      // Reseta o clip (corte) anterior se houve erro
      // Preenche de novo o fundo preto pra garantir
      paint.style = PaintingStyle.fill;
      paint.color = AppColors.black;
      canvas.drawCircle(Offset(radius, radius), radius - 2, paint);
      
      TextPainter painter = TextPainter(textDirection: TextDirection.ltr);
      painter.text = TextSpan(
        text: name.isNotEmpty ? name[0].toUpperCase() : "?",
        // Fonte ajustada: Metade do tamanho do pino
        style: TextStyle(fontSize: size * 0.4, color: AppColors.white, fontWeight: FontWeight.bold),
      );
      painter.layout();
      painter.paint(canvas, Offset(radius - painter.width / 2, radius - painter.height / 2));
    }

    final ui.Image markerAsImage = await pictureRecorder.endRecording().toImage(size, size);
    final ByteData? byteData = await markerAsImage.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }

  Future<void> _loadMarkers() async {
    Set<Marker> markers = {};

    for (var store in widget.allStores) {
      if (store['lat'] != null && store['lng'] != null) {
        final iconBytes = await _createCustomMarkerBitmap(store['img'], store['name']);

        markers.add(
          Marker(
            markerId: MarkerId(store['name']),
            position: LatLng(store['lat'], store['lng']),
            icon: BitmapDescriptor.fromBytes(iconBytes),
            zIndex: store['name'] == widget.selectedStore['name'] ? 2 : 1,
            onTap: () {
              mapController.animateCamera(CameraUpdate.newLatLng(LatLng(store['lat'], store['lng'])));
              setState(() {
                _currentStore = store;
              });
            },
          ),
        );
      }
    }

    if (mounted) {
      setState(() {
        _markers = markers;
      });
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    final position = LatLng(widget.selectedStore['lat'], widget.selectedStore['lng']);

    return Scaffold(
      backgroundColor: AppColors.black,
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(target: position, zoom: 15),
            markers: _markers,
            cloudMapId: '6c7622be7f6dee45b4819305',
            zoomControlsEnabled: false,
            myLocationButtonEnabled: false,
            mapToolbarEnabled: false,
            compassEnabled: false,
          ),
          
          // Botão Voltar
          Positioned(
            top: 50, left: 20,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.black,
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 10)]
                ),
                child: const Icon(Icons.arrow_back, color: AppColors.white),
              ),
            ),
          ),

          // --- 2. NOVO HUD MINIMALISTA (O Estilinho Bonito) ---
          Positioned(
            bottom: 30, left: 20, right: 20,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.black.withOpacity(0.95), // Quase sólido
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.nightRider),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 20, offset: const Offset(0, 10))],
              ),
              child: Row(
                children: [
                  // Foto Redonda
                  Container(
                    height: 56, width: 56,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.nightRider),
                      image: DecorationImage(
                        image: NetworkImage(_currentStore['img']),
                        fit: BoxFit.cover,
                        colorFilter: const ColorFilter.mode(Colors.grey, BlendMode.saturation)
                      ),
                    ),
                  ),
                  
                  const SizedBox(width: 16),
                  
                  // Infos
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _currentStore['name'], 
                          style: const TextStyle(color: AppColors.white, fontSize: 18, fontWeight: FontWeight.bold)
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.star, color: AppColors.white, size: 12),
                            const SizedBox(width: 4),
                            Text(
                              "${_currentStore['rating'] ?? 4.8}", 
                              style: const TextStyle(color: AppColors.white, fontSize: 12, fontWeight: FontWeight.bold)
                            ),
                            const SizedBox(width: 8),
                            // Badge "4 Ofertas"
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.white,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                "4 OFERTAS",
                                style: TextStyle(color: AppColors.black, fontSize: 9, fontWeight: FontWeight.w900),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Botão de Rota Minimalista (Seta)
                  GestureDetector(
                    onTap: () {
                      // Abre o Maps Externo pra navegar de verdade
                      _launchURL('https://www.google.com/maps/search/?api=1&query=${_currentStore['lat']},${_currentStore['lng']}');
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.eerieBlack,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.nightRider),
                      ),
                      child: const Icon(Icons.near_me, color: AppColors.white),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}