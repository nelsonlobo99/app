import 'package:flutter/material.dart';

import 'package:image_picker/image_picker.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'dart:io';

import './tts.dart';



void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
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
  int _counter = 0;
String convText="";




  Future<File> imageFile;
  File img;
Future readText() async {
    FirebaseVisionImage ourImage = FirebaseVisionImage.fromFile(img);
    TextRecognizer recognizeText = FirebaseVision.instance.textRecognizer();
    VisionText readText = await recognizeText.processImage(ourImage);
    setState(() {
      convText = "";
    });
    for (TextBlock block in readText.blocks) {
      for (TextLine line in block.lines) {
        String ln = line.text;
        for (TextElement word in line.elements) {
          //print(word.text);
         // append(word.text);
        }
        append(ln+"\n");
      }
      print(this.convText);
    }



  Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SpeechConv(convText)),
  );

}


append(String str){
  setState(() {
    convText = convText + " " + str;
  });


}
  Widget showImage(){
    return FutureBuilder<File>(
      future: Future.value(imageFile), 
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if(snapshot.connectionState == ConnectionState.done && snapshot.data != null){
          img = snapshot.data;
          return Image.file(
            snapshot.data,
            width: 300,
            height: 300,
          );
        }else return const Icon(Icons.image);
      },

    );
  }


  _pickImage(ImageSource source){
    setState(() {
        convText= "";
       imageFile = ImagePicker.pickImage(source: source);
    print(imageFile.asStream());
    });
   
  }



  @override
  Widget build(BuildContext context) {
    
    return Scaffold(

       bottomNavigationBar: BottomAppBar(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            IconButton(
              icon: Icon(
                Icons.photo_camera,
                size: 30,
              ),
              onPressed: () => _pickImage(ImageSource.camera),
              color: Colors.green,
            ),
            IconButton(
              icon: Icon(
                Icons.photo_library,
                size: 30,
              ),
              onPressed: () => _pickImage(ImageSource.gallery),
              color: Colors.pink,
            ),
          ],
        ),
      ),

      body: Center(

        child: ListView(
          
          //mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Card(
             child:Container(
               width: 300,
                height: 400,
                child: Center(child: showImage(),)
             )  
            ),
                 Padding(
              padding: const EdgeInsets.all(32),
              child: FlatButton.icon(
          color: Colors.blue,
          label: Text('Convert to Text'),
          icon: Icon(Icons.text_fields),
          onPressed: readText)

            ),

          

          
          ],
        ),
      ),
    );
  }



    


}
