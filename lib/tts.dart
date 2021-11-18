import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pdf;
import 'package:printing/printing.dart';

class SpeechConv extends StatefulWidget {
  String text;

  SpeechConv(this.text);
  @override
  _MyAppState createState() => _MyAppState(text);
}

enum TtsState { playing, stopped }

class _MyAppState extends State<SpeechConv> {
  TextEditingController controller = TextEditingController();

  //String text;
  _MyAppState(this._newVoiceText);

  FlutterTts flutterTts;
  dynamic languages;
  String language;
  double volume = 1.0;
  double pitch = 1.0;
  double rate = 0.5;

  String _newVoiceText;

  TtsState ttsState = TtsState.stopped;

  get isPlaying => ttsState == TtsState.playing;

  get isStopped => ttsState == TtsState.stopped;

  @override
  initState() {
    super.initState();
    initTts();
    controller.text = _newVoiceText;
  }

  initTts() {
    flutterTts = FlutterTts();

    _getLanguages();

    flutterTts.setStartHandler(() {
      setState(() {
        print("playing");
        ttsState = TtsState.playing;
      });
    });

    flutterTts.setCompletionHandler(() {
      setState(() {
        print("Complete");
        ttsState = TtsState.stopped;
      });
    });

    flutterTts.setErrorHandler((msg) {
      setState(() {
        print("error: $msg");
        ttsState = TtsState.stopped;
      });
    });
  }

  Future _getLanguages() async {
    languages = await flutterTts.getLanguages;
    if (languages != null) setState(() => languages);
  }

  Future _speak() async {
    await flutterTts.setVolume(volume);
    await flutterTts.setSpeechRate(rate);
    await flutterTts.setPitch(pitch);

    if (_newVoiceText != null) {
      if (_newVoiceText.isNotEmpty) {
        var result = await flutterTts.speak(_newVoiceText);
        if (result == 1) setState(() => ttsState = TtsState.playing);
      }
    }
  }

  Future _stop() async {
    var result = await flutterTts.stop();
    if (result == 1) setState(() => ttsState = TtsState.stopped);
  }

  @override
  void dispose() {
    super.dispose();
    flutterTts.stop();
  }

  List<DropdownMenuItem<String>> getLanguageDropDownMenuItems() {
    var items = List<DropdownMenuItem<String>>();
    for (String type in languages) {
      items.add(DropdownMenuItem(value: type, child: Text(type)));
    }
    return items;
  }

  void changedLanguageDropDownItem(String selectedType) {
    setState(() {
      language = selectedType;
      flutterTts.setLanguage(language);
    });
  }

  void _onChange(String text) {
    setState(() {
      _newVoiceText = text;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

        theme: ThemeData(
          brightness: Brightness.dark,
        ),
        home: Scaffold(
            appBar: AppBar(
             leading: IconButton(
               icon: Icon(Icons.arrow_back),
               onPressed:(){ Navigator.pop(context);},
             ),
            ),
            body: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Column(children: [
                  _inputSection(),
                  toPdf(),
                  _btnSection(),
                  languages != null ? _languageDropDownSection() : Text(""),
                  _buildSliders()
                ]))));
  }

  Widget toPdf() {
    return Container(
      child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
              child: FlatButton.icon(
          color: Colors.blue,
          label: Text('Generate PDF'),
          icon: Icon(Icons.print),
          onPressed: () {
           
          
            Printing.layoutPdf(
              onLayout: buildPdf,
            );
             print(_newVoiceText);
          }
          
          )

            )
      );
  }

  Widget _inputSection() => Container(
      alignment: Alignment.topCenter,
      padding: EdgeInsets.only(top: 10.0, left: 25.0, right: 25.0),
      child: TextField(
        maxLines: 17,
        controller: controller,
        onChanged: (String value) {
          _onChange(value);
        },
      ));

  Widget _btnSection() => Container(
      padding: EdgeInsets.only(top: 30.0),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
        _buildButtonColumn(
            Colors.green, Colors.greenAccent, Icons.play_arrow, 'PLAY', _speak),
        _buildButtonColumn(
            Colors.red, Colors.redAccent, Icons.stop, 'STOP', _stop)
      ]));

  Widget _languageDropDownSection() => Container(
      padding: EdgeInsets.only(top: 50.0),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        DropdownButton(
          value: language,
          items: getLanguageDropDownMenuItems(),
          onChanged: changedLanguageDropDownItem,
        )
      ]));

  Column _buildButtonColumn(Color color, Color splashColor, IconData icon,
      String label, Function func) {
    return Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
              icon: Icon(icon),
              color: color,
              splashColor: splashColor,
              onPressed: () => func()),
          Container(
              margin: const EdgeInsets.only(top: 8.0),
              child: Text(label,
                  style: TextStyle(
                      fontSize: 12.0,
                      fontWeight: FontWeight.w400,
                      color: color)))
        ]);
  }

  Widget _buildSliders() {
    return Column(
      children: [_volume(), _pitch(), _rate()],
    );
  }

  Widget _volume() {
    return Slider(
        value: volume,
        onChanged: (newVolume) {
          setState(() => volume = newVolume);
        },
        min: 0.0,
        max: 1.0,
        divisions: 10,
        label: "Volume: $volume");
  }

  Widget _pitch() {
    return Slider(
      value: pitch,
      onChanged: (newPitch) {
        setState(() => pitch = newPitch);
      },
      min: 0.5,
      max: 2.0,
      divisions: 15,
      label: "Pitch: $pitch",
      activeColor: Colors.red,
    );
  }

  Widget _rate() {
    return Slider(
      value: rate,
      onChanged: (newRate) {
        setState(() => rate = newRate);
      },
      min: 0.0,
      max: 1.0,
      divisions: 10,
      label: "Rate: $rate",
      activeColor: Colors.green,
    );
  }



  List<int> buildPdf(PdfPageFormat format) {
    final pdf.Document doc = pdf.Document();

    doc.addPage(
      pdf.MultiPage(
        crossAxisAlignment: pdf.CrossAxisAlignment.start,
         pageFormat:
          PdfPageFormat.letter.copyWith(marginBottom: 1.5 * PdfPageFormat.cm),
  
       header: (pdf.Context context){
         
        if (context.pageNumber == 1) {
          return null;
        }
        return pdf.Container(
          
          alignment: pdf.Alignment.topRight,
          margin: const pdf.EdgeInsets.only(bottom: 3.0 * PdfPageFormat.mm),
        padding: const pdf.EdgeInsets.only(bottom: 3.0 * PdfPageFormat.mm),
         decoration: const pdf.BoxDecoration(
           border: pdf.BoxBorder(bottom: true, width: 0.5, color: PdfColors.grey)),
          
          child: pdf.Text('portaible doc format',)
          
           // child: Text('Portable Document Format',
            );

       },
        footer: (pdf.Context context) {
        return pdf.Container(
           alignment: pdf.Alignment.topRight,
            margin: const pdf.EdgeInsets.only(top: 1.0 * PdfPageFormat.cm),
          
            child: pdf.Text('Page ${context.pageNumber} of ${context.pagesCount}',
               ));
      },
      build: (pdf.Context context) => <pdf.Widget>[
             pdf.Column(
                  mainAxisAlignment: pdf.MainAxisAlignment.spaceBetween,
                  children: <pdf.Widget>[
                    pdf.Text("$_newVoiceText")

                  ]

                ),
                  
                  //  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                   // children: <Widget>[
       
      
    
    ]));

    return 
    doc.save();
    
  }

}