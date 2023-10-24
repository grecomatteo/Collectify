
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:collectify/ConexionBD.dart';
import 'package:flutter/services.dart';
import 'package:mysql1/mysql1.dart';
import 'package:image_picker/image_picker.dart';
import 'VentanaListaProductos.dart';

import 'package:image/image.dart' as img;
import 'package:cross_file_image/cross_file_image.dart';


MySqlConnection? conn;
String nombre = "";
String description = "";
//Placeholder, se debe cambiar
Usuario logged = new Usuario();

Future<bool> validateFields() async {
  conn = await MySqlConnection.connect(
      ConnectionSettings(
        host: "collectify-server-mysql.mysql.database.azure.com",
        port: 3306,
        user: "pin2023",
        password: "AsLpqR_23",
        db: "collectifyDB",
      ));
  await conn?.query('select * from producto where (nombre = $nombre AND descripcion = $description)').then((result) {
    if (result != null) return true;
  }
  );
  return false;
  //return true;
}


class VentanaAnadirProducto extends StatelessWidget {
  const VentanaAnadirProducto({super.key, required this.user});

  final Usuario user;

  @override
  Widget build(BuildContext context) {
    logged = user;
    return Scaffold(
      appBar: AppBar(
        title: Text('Anadir nuevo producto'),
      ),
      body: AddProductForm(),
    );
  }
}

class AddProductForm extends StatefulWidget {
  const AddProductForm({super.key});

  @override
  _AddProductFormState createState() => _AddProductFormState();
}

class _AddProductFormState extends State<AddProductForm> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();


  final priceFormatter = FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'));

  bool _imageTaken = false; // Per tenere traccia se l'immagine è stata scattata

  late File _image;
  XFile? get pickedFile => null;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TextFormField(
            controller: nameController,
            decoration: InputDecoration(labelText: 'Nombre producto'),
          ),
          TextFormField(
            controller: priceController,
            decoration: InputDecoration(labelText: 'Precio'),
            inputFormatters: [priceFormatter], // Applica il formatter per il prezzo
            keyboardType: TextInputType.numberWithOptions(decimal: true)
          ),
          TextFormField(
            controller: descriptionController,
            decoration: InputDecoration(labelText: 'Descripción'),
          ),
          const SizedBox(height: 16),
          _imageTaken
              ? Icon(
            Icons.check_circle,
            color: Colors.green,
            size: 48.0,
          )
              : ElevatedButton(
            onPressed: () async {
              final imagePicker = ImagePicker();
              final XFile? pickedFile =
              await imagePicker.pickImage(source: ImageSource.camera);
              if (pickedFile != null) {
                setState(() {
                  _imageTaken = true;
                });
              }
            },
            child: Text('Toma una foto'),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () async {
              final productName = nameController.text;
              final productPrice = priceController.text;
              final productDescription = descriptionController.text;

              Producto prod = Producto();
              prod.nombre = productName;
              prod.precio = double.parse(productPrice);
              prod.descripcion = productDescription;
              prod.imagePath = "lib/assets/productos/$productName.png";

              await Conexion().anadirProducto(prod).then((results){
                if(results != -1){
                  int newId = results;
                  Imagen img = Imagen();
                  pickedFile?.readAsBytes().then((value)
                  {
                      img.nombre = productName;
                      img.productoID =  newId;
                      img.image = value as List<int>?;
                      Conexion().anadirImagen(img).then((value) {
                          Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => ListaProductos(connected: logged)));
                      });
                });
                  }
                else{
                  var errorText = "Falta details";
                }
              });
              Navigator.pop(context);
            },
            child: Text('Anadir Producto'),
          ),
        ],
      ),
    );
  }



}
