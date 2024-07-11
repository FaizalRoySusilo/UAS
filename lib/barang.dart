
import 'package:flutter/material.dart';
import 'package:coba/edit.dart';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  TextEditingController namaController = TextEditingController();
  TextEditingController jumlahController = TextEditingController();
  TextEditingController hargaController = TextEditingController();
  late dynamic db = null;
  final dio = Dio();
  List<dynamic> barang = [];

  @override
  void initState() {
    super.initState();
    retrieve();
  }

  void retrieve() async {
    Response response = await dio.get('http://192.168.18.112:8000/api/barang');
    setState(() {
     barang = response.data;
    });
  }
  void simpan() async{
    Response response = await dio.post(
      'http://192.168.18.112:8000/api/barang',
      data: {
        'Nama_Barang': namaController.text,
        'Jumlah_Barang': jumlahController.text,
        'Harga_Barang': hargaController.text,
      },
      );
      retrieve();
  }
  void save() async {
    if (namaController.text.isEmpty ||
        jumlahController.text.isEmpty ||
        hargaController.text.isEmpty) {
    
        final snackBar = SnackBar(
        content: Text('Nama Barang, Jumlah Barang, Atau Harga Barang Tidak Boleh Kosong!'),
        );
        ScaffoldMessenger.of(this.context).showSnackBar(snackBar);
        return;
    }

   else {
    simpan();
   }
    retrieve();
  }


  void delete(id) async{
    Response response = await dio.delete("http://192.168.18.112:8000/api/barang/${id}");
  }

void deleteRow(id) async {
  showDialog(
    context: this.context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text("Konfirmasi"),
        content: Text("Apakah Anda yakin ingin menghapus barang ini?"),
        actions: <Widget>[
          TextButton(
            onPressed: () async {
              delete(id);
              retrieve();
              Navigator.of(context).pop(); 
            },
            child: Text("Ya"),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); 
            },
            child: Text("Tidak"),
          ),
        ],
      );
    },
  );
}

  void editRow(int id) {
    Navigator.push(
      this.context,
      MaterialPageRoute(builder: (context) => EditPage(id: id)),
    
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Input Data Barang"),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
              this.context,
              MaterialPageRoute(builder: (context) => Home()),
              );
            },
            icon: Icon(Icons.refresh),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: namaController,
              decoration: InputDecoration(
                labelText: "Nama Barang",
              ),
            ),
            SizedBox(height: 20.0),
            TextField(
              controller: jumlahController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                labelText: "Jumlah Barang",
              ),
            ),
            SizedBox(height: 20.0),
            TextField(
              controller: hargaController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                labelText: "Harga Barang",
              ),
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: save,
              child: Text("Simpan Data Barang"),
            ),
            SizedBox(height: 20.0),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: [
                      DataColumn(label: Text('Nama Barang')),
                      DataColumn(label: Text('Jumlah Barang')),
                      DataColumn(label: Text('Harga Barang')),
                      DataColumn(label: Text('Action')),
                    ],
                    rows: barang.map((e) {
                      return DataRow(
                        cells: [
                          DataCell(Text(e['Nama_Barang'].toString())),
                          DataCell(Text(e['Jumlah_Barang'].toString())),
                          DataCell(Text(e['Harga_Barang'].toString())),
                          DataCell(
                            Row(
                              children: [
                                IconButton(
                                  onPressed: () {
                                    editRow(e['id'] as int);
                                  },
                                  icon: Icon(Icons.edit),
                                ),
                                IconButton(
                                  onPressed: () {
                                    deleteRow(e['id'] as int);
                                  },
                                  icon: Icon(Icons.delete),
                                ),
                              ],
                            ),
                          )
                        ],
                      );
                    }).toList(),
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