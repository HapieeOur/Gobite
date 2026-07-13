import 'package:flutter/material.dart';
import 'package:projek/model/meja_model.dart';
import 'package:projek/services/meja_service.dart';

class PilihMejaPage extends StatefulWidget {
  const PilihMejaPage({super.key});

  @override
  State<PilihMejaPage> createState() => _PilihMejaPageState();
}

class _PilihMejaPageState extends State<PilihMejaPage> {
  final TextEditingController mejaController = TextEditingController();
  final MejaService mejaService = MejaService();
  List<MejaModel> mejaList = [];
  int? selectedMeja;

  @override
  void initState() {
    super.initState();
    getMeja();
  }

  void dispose() {
    mejaController.dispose(); // WAJIB biar nggak memory leak
    super.dispose();
  }

  Future<void> getMeja() async {
    final data = await mejaService.getMeja();

    setState(() {
      mejaList = data;
    });
  }

  Future<void> konfirmasiMeja() async {
    FocusScope.of(context).unfocus();

    final text = mejaController.text.trim();
    final meja = int.tryParse(text);

    if (meja == null || meja <= 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Masukkan nomor meja yang valid")));
      return;
    }

    bool berhasil = await mejaService.pilihMeja(meja);

    if (!berhasil) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Meja sudah dipakai')));
      return;
    }

    Navigator.pop(context, meja);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFF7A00), Color(0xFFFF3D00)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(20),
            child: Column(
              children: [
                /// HEADER
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context, null),
                      child: Icon(Icons.arrow_back, color: Colors.white),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        "Pilih Lokasi Meja",
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 30),

                /// CARD SCAN QR
                Container(
                  padding: EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                    color: Colors.white.withOpacity(0.15),
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: Colors.white.withOpacity(0.25),
                        ),
                        child: Icon(
                          Icons.qr_code_scanner,
                          size: 40,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 20),
                      Text(
                        "Scan QR Code",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        "Scan QR code yang ada di meja Anda",
                        style: TextStyle(color: Colors.white70),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.orange,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {},
                        child: Text("Buka Scanner"),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 25),
                Text("atau", style: TextStyle(color: Colors.white70)),
                SizedBox(height: 25),

                /// CARD INPUT NOMOR MEJA
                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                    color: Colors.white,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Masukkan Nomor Meja",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 15),
                      TextField(
                        controller: mejaController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: "Contoh: 12",
                          filled: true,
                          fillColor: Colors.grey[200],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange[300],
                            padding: EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          onPressed: konfirmasiMeja,
                          child: Text("Konfirmasi Meja"),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 19),
                Text("Pilih Cepat:", style: TextStyle(color: Colors.white)),
                SizedBox(height: 15),

                /// GRID PILIH CEPAT
                GridView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: mejaList.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 5,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                  ),
                  //ini
                  itemBuilder: (context, index) {
                    final meja = mejaList[index];
                    int number = meja.nomorMeja;
                    String status = meja.status;
                    bool isUsed = status == 'dipakai';
                    bool isSelected = selectedMeja == number;

                    return GestureDetector(
                      onTap: isUsed
                          ? null
                          : () {
                              setState(() {
                                selectedMeja = number;
                                mejaController.text = number.toString();
                              });
                            },
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          //ini
                          color: isUsed
                              ? Colors.grey
                              : isSelected
                              ? Colors.white
                              : Colors.white.withOpacity(0.3),
                        ),
                        child: Center(
                          child: Text(
                            number.toString(),
                            style: TextStyle(
                              //ini
                              fontWeight: FontWeight.bold,
                              color: isUsed
                                  ? Colors.black45
                                  : isSelected
                                  ? Colors.orange
                                  : Colors.white,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),

                SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
