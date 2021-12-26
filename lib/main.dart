import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // Bu widget, uygulamamızın köküdür.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'AES İLE PDF KORUMA'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              TextButton(
                style: TextButton.styleFrom(
                    primary: Colors.white,
                    backgroundColor: Colors.green,
                    side: BorderSide(color: Colors.green, width: 1),
                    elevation: 20,
                    minimumSize: Size(100, 50),
                    shadowColor: Colors.black,
                    padding: EdgeInsets.only(
                        left: 60, right: 60, top: 15, bottom: 15)),
                onPressed: securePdf,
                child: Text('AES İLE PDF ŞİFRELEME',
                    style: new TextStyle(
                      fontSize: 20.0,
                      color: Colors.white,
                    )),
              ),
              TextButton(
                  style: TextButton.styleFrom(
                      primary: Colors.white,
                      backgroundColor: Colors.green,
                      side: BorderSide(color: Colors.green, width: 1),
                      elevation: 20,
                      minimumSize: Size(100, 50),
                      shadowColor: Colors.black,
                      padding: EdgeInsets.only(
                          left: 60, right: 60, top: 15, bottom: 15)),
                  onPressed: restrictPermissions,
                  child: Text('KULLANICI İZİNLERİ',
                      style: new TextStyle(
                        fontSize: 20.0,
                        color: Colors.white,
                      ))),
              TextButton(
                  style: TextButton.styleFrom(
                      primary: Colors.white,
                      backgroundColor: Colors.green,
                      side: BorderSide(color: Colors.green, width: 1),
                      elevation: 20,
                      minimumSize: Size(100, 50),
                      shadowColor: Colors.black,
                      padding: EdgeInsets.only(
                          left: 60, right: 60, top: 15, bottom: 15)),
                  onPressed: decryptPDF,
                  child: Text('PDF ŞİFRE KALDIRMA',
                      style: new TextStyle(
                        fontSize: 20.0,
                        color: Colors.white,
                      ))),
            ]),
      ),
    );
  }

  Future<void> securePdf() async {
    //Mevcut PDF belgesini yükleme.
    PdfDocument document =
        PdfDocument(inputBytes: await _readDocumentData('ksu_kimlik.pdf'));
    //Belge güvenliğinin ayarlanması.
    document.security.userPassword = 'Ax57ky8';
    //Belgenin kaydedilmesi ve yönlendirme.
    List<int> bytes = document.save();
    document.dispose();
    //PDF dosyasının açılması.
    _launchPdf(bytes, 'sifrelenmis_dosya.pdf');
  }

  Future<void> _launchPdf(List<int> bytes, String fileName) async {
    //Harici depolamada dosya dizininin alınması.
    Directory directory = await getExternalStorageDirectory();
    //dosya dizininin alınması.
    String path = directory.path;
    //PDF verilerini yazmak için boş bir dosya oluşturulması.
    File file = File('$path/$fileName');
    //PDF verilerinin yazılması
    await file.writeAsBytes(bytes, flush: true);
    //PDF belgesinin telefonda açılması
    OpenFile.open('$path/$fileName');
  }

  Future<List<int>> _readDocumentData(String name) async {
    final ByteData data = await rootBundle.load('assets/$name');
    return data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
  }

  Future<void> restrictPermissions() async {
    //Mevcut PDF belgesini yükleme.
    PdfDocument document =
        PdfDocument(inputBytes: await _readDocumentData('ksu_kimlik.pdf'));
    //Güvenlik izinlerinin getirilmesi
    PdfSecurity security = document.security;
    //Belge için sahip parolasınının ayarlanması
    security.ownerPassword = 'izin_123';
    //Çeşitli izinlerin ayarlanması.
    security.permissions.addAll(<PdfPermissionsFlags>[]);
    List<int> bytes = document.save();
    document.dispose();
    _launchPdf(bytes, 'izinler_düzenlendi.pdf');
  }

  Future<void> decryptPDF() async {
    //PDF belgesini izin şifresinin yüklenmesi.
    PdfDocument document = PdfDocument(
        inputBytes: await _readDocumentData('sifrelenmis_dosya.pdf'),
        password: 'Ax57ky8');
    //Güvenlik izinlerinin getirilmesi
    PdfSecurity security = document.security;

    security.userPassword = '';
    security.ownerPassword = '';
    security.permissions.clear();
    //Belgenin kaydedilmesi
    List<int> bytes = document.save();
    document.dispose();
    //PDF belgesinin telefonda açılması
    _launchPdf(bytes, 'sifre_cozuldu.pdf');
  }
}
