

import 'package:flutter/material.dart';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pdf;
import 'package:printing/printing.dart';



class MyApp extends StatelessWidget {

  @override
   String anytext;
  Widget build(BuildContext context) {
   
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Printing Demo'),
        ),
        floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.print),
          tooltip: 'Print Document',
          onPressed: () {
           
          
            Printing.layoutPdf(
              onLayout: buildPdf,
            );
             print(anytext);
          },
        ),
        body:Center(
          child:Column(children: <Widget>[ 
           TextField(
                maxLines: 5,
               keyboardType: TextInputType.multiline,
               
                onChanged: (value) {
                  anytext = value;
                 
                },
                decoration: InputDecoration(
                    labelText: 'NOTE',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5))),
              ),
      
        FlatButton(onPressed: (){
        
        },
        child:Text('save')
        ,)
        ],))
      ),
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
                    pdf.Text('$anytext')

                  ]

                ),
                  
                  //  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                   // children: <Widget>[
       
      
    
    ]));

    return 
    doc.save();
    
  }




 
}