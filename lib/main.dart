import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/rendering.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:gal/gal.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

void main() {
  runApp(const CPSAfisApp());
}

class CPSAfisApp extends StatelessWidget {
  const CPSAfisApp({super.key});

  @override
  Widget build(BuildContext context) {
    const altin = Color(0xFFF1C40F);
    const lacivert = Color(0xFF0A0A1F);

    return MaterialApp(
      title: 'CPS Gayrimenkul - Afiş Oluşturucu',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: altin,
          brightness: Brightness.light,
          primary: lacivert,
          secondary: altin,
        ),
        scaffoldBackgroundColor: const Color(0xFFF6F6FA),
        appBarTheme: const AppBarTheme(
          backgroundColor: lacivert,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: BorderSide(color: Colors.grey.shade200),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFFF6F6FA),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: altin,
            foregroundColor: lacivert,
            elevation: 0,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            textStyle:
                const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
          ),
        ),
      ),
      home: const AfisOlusturucuSayfasi(),
    );
  }
}

/// Afişte kullanılacak tüm verileri tutan basit model.
class AfisVerisi {
  String sirket;
  String baslik;
  String fiyat;
  String telefon;
  String danisman;
  List<String> ozellikler;
  Uint8List? anaFoto;
  Uint8List? logo;
  List<Uint8List> icFotolar;
  Color bgColor;
  Color accentColor;
  Color textColor;

  AfisVerisi({
    this.sirket = 'CPS Gayrimenkul',
    this.baslik = '',
    this.fiyat = '',
    this.telefon = '',
    this.danisman = '',
    List<String>? ozellikler,
    this.anaFoto,
    this.logo,
    List<Uint8List>? icFotolar,
    this.bgColor = const Color(0xFF0A0A1F),
    this.accentColor = const Color(0xFFF1C40F),
    this.textColor = Colors.white,
  })  : ozellikler = ozellikler ?? [],
        icFotolar = icFotolar ?? [];
}

class AfisOlusturucuSayfasi extends StatefulWidget {
  const AfisOlusturucuSayfasi({super.key});

  @override
  State<AfisOlusturucuSayfasi> createState() => _AfisOlusturucuSayfasiState();
}

class _AfisOlusturucuSayfasiState extends State<AfisOlusturucuSayfasi> {
  final _veri = AfisVerisi();
  final _picker = ImagePicker();

  final _baslikCtrl = TextEditingController(
      text: "");
  final _fiyatCtrl = TextEditingController(text: '4200000');
  final _telefonCtrl = TextEditingController(text: '');
  final _danismanCtrl = TextEditingController(text: '');
  final _ozelliklerCtrl = TextEditingController(
      text:
          '');

  bool _uretiliyor = false;

  @override
  void dispose() {
    _baslikCtrl.dispose();
    _fiyatCtrl.dispose();
    _telefonCtrl.dispose();
    _danismanCtrl.dispose();
    _ozelliklerCtrl.dispose();
    super.dispose();
  }

  Future<void> _fotoSec({required bool anaFoto}) async {
    final XFile? secilen =
        await _picker.pickImage(source: ImageSource.gallery, imageQuality: 95);
    if (secilen == null) return;
    final bytes = await secilen.readAsBytes();
    setState(() {
      if (anaFoto) {
        _veri.anaFoto = bytes;
      } else {
        _veri.logo = bytes;
      }
    });
  }

  Future<void> _icFotoEkle() async {
    if (_veri.icFotolar.length >= 10) {
      _mesajGoster('En fazla 10 iç mekan fotoğrafı ekleyebilirsiniz.');
      return;
    }
    final List<XFile> secilenler = await _picker.pickMultiImage(imageQuality: 90);
    if (secilenler.isEmpty) return;
    final kalanYer = 10 - _veri.icFotolar.length;
    final secilenBytes = await Future.wait(
      secilenler.take(kalanYer).map((x) => x.readAsBytes()),
    );
    setState(() {
      _veri.icFotolar.addAll(secilenBytes);
    });
  }

  void _icFotoSil(int index) {
    setState(() => _veri.icFotolar.removeAt(index));
  }

  Future<void> _renkSec({required bool arkaPlan}) async {
    Color seciliRenk = arkaPlan ? _veri.bgColor : _veri.accentColor;
    final sonuc = await showDialog<Color>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(arkaPlan ? 'Arka Plan Rengi' : 'Vurgu Rengi'),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: seciliRenk,
            onColorChanged: (c) => seciliRenk = c,
            enableAlpha: false,
            labelTypes: const [ColorLabelType.hex],
            pickerAreaHeightPercent: 0.7,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Vazgeç'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, seciliRenk),
            child: const Text('Seç'),
          ),
        ],
      ),
    );
    if (sonuc != null) {
      setState(() {
        if (arkaPlan) {
          _veri.bgColor = sonuc;
        } else {
          _veri.accentColor = sonuc;
        }
      });
    }
  }

  void _mesajGoster(String metin, {bool hata = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(metin),
        backgroundColor: hata ? Colors.red.shade700 : Colors.black87,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  List<String> get _ozellikListesi => _ozelliklerCtrl.text
      .split('\n')
      .map((s) => s.trim())
      .where((s) => s.isNotEmpty)
      .toList();

  Future<void> _afisiOlustur() async {
    if (_baslikCtrl.text.trim().isEmpty) {
      _mesajGoster('Lütfen bir başlık girin.', hata: true);
      return;
    }
    if (_fiyatCtrl.text.trim().isEmpty) {
      _mesajGoster('Lütfen fiyat girin.', hata: true);
      return;
    }
    if (_veri.anaFoto == null) {
      _mesajGoster('Lütfen ana dış mekan fotoğrafı seçin.', hata: true);
      return;
    }

    setState(() => _uretiliyor = true);

    _veri
      ..baslik = _baslikCtrl.text.trim()
      ..fiyat = _fiyatCtrl.text.trim()
      ..telefon = _telefonCtrl.text.trim()
      ..danisman = _danismanCtrl.text.trim()
      ..ozellikler = _ozellikListesi;

    try {
      final Uint8List pngBytes = await _widgetiGoruntuyeDonustur(
        PosterCanvas(veri: _veri),
        const Size(1200, 1900),
        pixelRatio: 2.2, // yüksek çözünürlük / baskı kalitesi
      );

      if (!mounted) return;
      setState(() => _uretiliyor = false);

      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => AfisOnizlemeSayfasi(pngBytes: pngBytes),
        ),
      );
    } catch (e) {
      setState(() => _uretiliyor = false);
      _mesajGoster('Afiş oluşturulurken hata: $e', hata: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CPS Gayrimenkul • Afiş Oluşturucu'),
      ),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 120),
            children: [
              _bolumBasligi('Renkler'),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: _renkKutusu(
                          etiket: 'Arka Plan',
                          renk: _veri.bgColor,
                          onTap: () => _renkSec(arkaPlan: true),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: _renkKutusu(
                          etiket: 'Vurgu (Altın)',
                          renk: _veri.accentColor,
                          onTap: () => _renkSec(arkaPlan: false),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              _bolumBasligi('İlan Bilgileri'),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      TextField(
                        controller: _baslikCtrl,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'Başlık (çok satırlı olabilir)',
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: _fiyatCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Fiyat (₺, sadece rakam)',
                          prefixText: '₺ ',
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: _telefonCtrl,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          labelText: 'Telefon',
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: _danismanCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Danışman Adı',
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: _ozelliklerCtrl,
                        maxLines: 5,
                        decoration: const InputDecoration(
                          labelText: 'Özellikler (her satır bir madde)',
                          alignLabelWithHint: true,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              _bolumBasligi('Fotoğraflar'),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _fotoSeciciSatiri(
                        baslik: 'Ana Dış Mekan Fotoğrafı',
                        zorunlu: true,
                        dosya: _veri.anaFoto,
                        onSec: () => _fotoSec(anaFoto: true),
                        onSil: () => setState(() => _veri.anaFoto = null),
                      ),
                      const Divider(height: 28),
                      _fotoSeciciSatiri(
                        baslik: 'Logo (Opsiyonel)',
                        zorunlu: false,
                        dosya: _veri.logo,
                        onSec: () => _fotoSec(anaFoto: false),
                        onSil: () => setState(() => _veri.logo = null),
                      ),
                      const Divider(height: 28),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Expanded(
                            child: Text(
                              'İç Mekan Fotoğrafları (max 10)',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                          TextButton.icon(
                            onPressed: _icFotoEkle,
                            icon: const Icon(Icons.add_photo_alternate_outlined),
                            label: const Text('Ekle'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 84,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: _veri.icFotolar.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 10),
                          itemBuilder: (ctx, i) => Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.memory(
                                  _veri.icFotolar[i],
                                  width: 84,
                                  height: 84,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Positioned(
                                top: -6,
                                right: -6,
                                child: IconButton(
                                  icon: const Icon(Icons.cancel,
                                      color: Colors.redAccent, size: 20),
                                  onPressed: () => _icFotoSil(i),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
          if (_uretiliyor)
            Container(
              color: Colors.black45,
              child: const Center(
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.all(28),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Afiş oluşturuluyor...'),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: ElevatedButton.icon(
            onPressed: _uretiliyor ? null : _afisiOlustur,
            icon: const Icon(Icons.auto_awesome),
            label: const Text('AFİŞİ OLUŞTUR'),
          ),
        ),
      ),
    );
  }

  Widget _bolumBasligi(String metin) => Padding(
        padding: const EdgeInsets.only(bottom: 10, left: 4),
        child: Text(
          metin,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: Color(0xFF0A0A1F),
          ),
        ),
      );

  Widget _renkKutusu({
    required String etiket,
    required Color renk,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: renk,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey.shade300, width: 2),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                etiket,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _fotoSeciciSatiri({
    required String baslik,
    required bool zorunlu,
    required Uint8List? dosya,
    required VoidCallback onSec,
    required VoidCallback onSil,
  }) {
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: dosya != null
              ? Image.memory(dosya, width: 64, height: 64, fit: BoxFit.cover)
              : Container(
                  width: 64,
                  height: 64,
                  color: const Color(0xFFF0F0F5),
                  child: const Icon(Icons.image_outlined, color: Colors.grey),
                ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text.rich(
            TextSpan(
              text: baslik,
              style: const TextStyle(fontWeight: FontWeight.w600),
              children: zorunlu
                  ? const [
                      TextSpan(
                        text: '  *',
                        style: TextStyle(color: Colors.redAccent),
                      )
                    ]
                  : [],
            ),
          ),
        ),
        if (dosya != null)
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
            onPressed: onSil,
          ),
        TextButton(onPressed: onSec, child: Text(dosya == null ? 'Seç' : 'Değiştir')),
      ],
    );
  }
}

/// Bir widget'ı, ekranda hiç göstermeden, yüksek çözünürlüklü bir
/// PNG'ye dönüştürür. Baskı/paylaşım kalitesinde çıktı için pixelRatio
/// yüksek tutulur (ör. 2.0 - 3.0).
Future<Uint8List> _widgetiGoruntuyeDonustur(
  Widget widget,
  Size boyut, {
  double pixelRatio = 2.0,
}) async {
  final repaintBoundary = RenderRepaintBoundary();

  final view = WidgetsBinding.instance.platformDispatcher.views.first;

  final renderView = RenderView(
    view: view,
    child: RenderPositionedBox(
      alignment: Alignment.center,
      child: repaintBoundary,
    ),
    configuration: ViewConfiguration(
      logicalConstraints: BoxConstraints.tight(boyut),
      devicePixelRatio: pixelRatio,
    ),
  );

  final pipelineOwner = PipelineOwner();
  final buildOwner = BuildOwner(focusManager: FocusManager());

  pipelineOwner.rootNode = renderView;
  renderView.prepareInitialFrame();

  final rootElement = RenderObjectToWidgetAdapter<RenderBox>(
    container: repaintBoundary,
    child: Directionality(
      textDirection: ui.TextDirection.ltr,
      child: MediaQuery(
        data: MediaQueryData(size: boyut, devicePixelRatio: pixelRatio),
        child: SizedBox(width: boyut.width, height: boyut.height, child: widget),
      ),
    ),
  ).attachToRenderTree(buildOwner);

  buildOwner.buildScope(rootElement);
  buildOwner.finalizeTree();

  pipelineOwner.flushLayout();
  pipelineOwner.flushCompositingBits();
  pipelineOwner.flushPaint();

  final image = await repaintBoundary.toImage(pixelRatio: pixelRatio);
  final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  return byteData!.buffer.asUint8List();
}

/// Afişin görsel tasarımı. Orijinal Python (Pillow) düzenini birebir
/// yansıtır: üstte ana fotoğraf, logo, şirket adı; ortada başlık/fiyat/
/// özellikler; altta iç mekan fotoğrafları ve iletişim bandı.
class PosterCanvas extends StatelessWidget {
  final AfisVerisi veri;
  const PosterCanvas({super.key, required this.veri});

  String get _fiyatFormatli {
    final sayi = int.tryParse(veri.fiyat.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    final format = NumberFormat.decimalPattern('tr_TR');
    return format.format(sayi);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1200,
      height: 1900,
      color: veri.bgColor,
      child: Stack(
        children: [
          // Ana dış mekan fotoğrafı
          if (veri.anaFoto != null)
            SizedBox(
              width: 1200,
              height: 950,
              child: Image.memory(
                veri.anaFoto!,
                fit: BoxFit.cover,
                alignment: const Alignment(0, -0.4),
              ),
            ),

          // Fotoğrafın altına hafif bir gölge geçişi (metin okunurluğu için)
          Positioned(
            top: 780,
            left: 0,
            right: 0,
            height: 170,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, veri.bgColor],
                ),
              ),
            ),
          ),

          // Logo
          if (veri.logo != null)
            Positioned(
              top: 40,
              left: 50,
              child: Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: veri.accentColor, width: 4),
                  boxShadow: const [
                    BoxShadow(color: Colors.black45, blurRadius: 14, offset: Offset(0, 6)),
                  ],
                ),
                padding: const EdgeInsets.all(8),
                child: ClipOval(
                  child: Image.memory(veri.logo!, fit: BoxFit.cover),
                ),
              ),
            ),

          // Şirket adı
          Positioned(
            top: 70,
            left: veri.logo != null ? 230 : 60,
            right: 40,
            child: Text(
              veri.sirket,
              style: TextStyle(
                fontSize: 62,
                fontWeight: FontWeight.w900,
                color: veri.accentColor,
                shadows: const [Shadow(color: Colors.black54, blurRadius: 10)],
              ),
            ),
          ),

          // Başlık / Fiyat / Özellikler
          Positioned(
            top: 990,
            left: 60,
            right: 60,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  veri.baslik,
                  style: TextStyle(
                    fontSize: 62,
                    fontWeight: FontWeight.w900,
                    color: veri.textColor,
                    height: 1.18,
                  ),
                ),
                const SizedBox(height: 26),
                Text(
                  '₺$_fiyatFormatli',
                  style: TextStyle(
                    fontSize: 96,
                    fontWeight: FontWeight.w900,
                    color: veri.accentColor,
                    shadows: const [Shadow(color: Colors.black45, blurRadius: 8)],
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: 140,
                  height: 6,
                  color: veri.accentColor,
                  margin: const EdgeInsets.only(bottom: 26),
                ),
                ...veri.ozellikler.map(
                  (o) => Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(top: 10, right: 14),
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: veri.accentColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            o,
                            style: TextStyle(fontSize: 40, color: veri.textColor),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // İç mekan fotoğrafları
          if (veri.icFotolar.isNotEmpty)
            Positioned(
              bottom: 100,
              left: 60,
              right: 60,
              height: 190,
              child: Row(
                children: veri.icFotolar
                    .map(
                      (f) => Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 14),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: Image.memory(f, fit: BoxFit.cover, height: 190),
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),

          // Alt iletişim bandı
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 90,
            child: Container(
              color: const Color(0xFF111133),
              padding: const EdgeInsets.symmetric(horizontal: 60),
              child: Row(
                children: [
                  Icon(Icons.phone, color: veri.accentColor, size: 34),
                  const SizedBox(width: 14),
                  Text(
                    veri.telefon,
                    style: TextStyle(
                      fontSize: 38,
                      fontWeight: FontWeight.w700,
                      color: veri.accentColor,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    veri.danisman,
                    style: TextStyle(
                      fontSize: 34,
                      color: veri.accentColor.withOpacity(0.9),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Oluşturulan afişi gösteren, kaydeden ve paylaşan önizleme ekranı.
class AfisOnizlemeSayfasi extends StatefulWidget {
  final Uint8List pngBytes;
  const AfisOnizlemeSayfasi({super.key, required this.pngBytes});

  @override
  State<AfisOnizlemeSayfasi> createState() => _AfisOnizlemeSayfasiState();
}

class _AfisOnizlemeSayfasiState extends State<AfisOnizlemeSayfasi> {
  bool _kaydediliyor = false;
  bool _kaydedildi = false;

  Future<void> _galeriyeKaydet() async {
    setState(() => _kaydediliyor = true);
    if (kIsWeb) {
      // Web'de "galeri" kavramı yok; dosyayı indirme/paylaşma penceresiyle sunuyoruz.
      try {
        final dosya = XFile.fromData(
          widget.pngBytes,
          mimeType: 'image/png',
          name: 'cps_afis_${DateTime.now().millisecondsSinceEpoch}.png',
        );
        await Share.shareXFiles([dosya], text: 'CPS Gayrimenkul Afişi');
        setState(() {
          _kaydediliyor = false;
          _kaydedildi = true;
        });
      } catch (e) {
        setState(() => _kaydediliyor = false);
        _mesaj('İndirme sırasında hata: $e', hata: true);
      }
      return;
    }
    try {
      final izinVar = await Gal.hasAccess();
      if (!izinVar) {
        final verildi = await Gal.requestAccess();
        if (!verildi) {
          _mesaj('Galeri izni verilmedi.', hata: true);
          setState(() => _kaydediliyor = false);
          return;
        }
      }
      await Gal.putImageBytes(widget.pngBytes, name: 'cps_afis_${DateTime.now().millisecondsSinceEpoch}');
      setState(() {
        _kaydediliyor = false;
        _kaydedildi = true;
      });
      _mesaj('Afiş galeriye kaydedildi ✓');
    } on GalException catch (e) {
      setState(() => _kaydediliyor = false);
      _mesaj('Kaydetme hatası: ${e.type.message}', hata: true);
    } catch (e) {
      setState(() => _kaydediliyor = false);
      _mesaj('Beklenmeyen hata: $e', hata: true);
    }
  }

  Future<void> _paylas() async {
    final dosya = XFile.fromData(
      widget.pngBytes,
      mimeType: 'image/png',
      name: 'cps_afis_paylasim.png',
    );
    await Share.shareXFiles([dosya], text: 'CPS Gayrimenkul İlanı');
  }

  void _mesaj(String metin, {bool hata = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(metin),
        backgroundColor: hata ? Colors.red.shade700 : Colors.black87,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Afiş Önizleme'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: InteractiveViewer(
              minScale: 0.5,
              maxScale: 4,
              child: Center(
                child: Image.memory(widget.pngBytes),
              ),
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white54),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      onPressed: _paylas,
                      icon: const Icon(Icons.ios_share),
                      label: const Text('Paylaş'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: _kaydediliyor ? null : _galeriyeKaydet,
                      icon: _kaydediliyor
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Icon(_kaydedildi ? Icons.check_circle : Icons.save_alt),
                      label: Text(_kaydedildi ? 'Kaydedildi' : 'Galeriye Kaydet'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
