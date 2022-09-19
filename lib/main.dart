import 'dart:convert';
import 'dart:io';

import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:filesystem_picker/filesystem_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_quill/flutter_quill.dart' hide Text;
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';
import 'package:get/get.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:quill_markdown/quill_markdown.dart' ;
import 'package:quill_test/uni_uidir/uni_ui.dart';
import 'package:uri_to_file/uri_to_file.dart';
import 'getxcont.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Editor(),
    );
  }
}

class Editor extends StatefulWidget {
  @override
  State<Editor> createState() => _EditorState();
}

class _EditorState extends State<Editor> {
  QuillController? _controller;
  final controllerx = Get.put(getxcontroller());
  var json;

  String quillDeltaToHtml(Delta delta) {
    print('In function--------------------------');
    final convertedValue = jsonEncode(delta.toJson());
    final markdown = quillToMarkdown(convertedValue);
    // print(markdown);          //마크다운으로 바꾸는 과정에서 같은줄에 none과 huge가 같이있으면 null이 되어버림
    //final markdown2 = deltaToMarkdown(convertedValue);   delta_markdown이 안깔림
    var html;
    if (markdown != null) {
      html = md.markdownToHtml(markdown);
      print('html--------------------------');
      print(html.toString());
    } else {html = '';}
    return html;}

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadFromAssets();
    // _controller!.addListener(() {
    //   double n = (MediaQuery.of(context).size.width) / 9.1;
    //   json = jsonEncode(_controller!.document.toDelta().toJson());
    //   controllerx.height.value = controllerx.cal_width(jsonDecode(json), MediaQuery.of(context).size.width).round();
    //    //controllerx.height.value = '\n'.allMatches(json.toString()).length;
    //  });
  }
Future<void> _loadFromAssets() async {
     try {
       final result = await rootBundle.loadString('assets/result.json');
       final doc = Document.fromJson(jsonDecode(result));
       setState(() {
         _controller = QuillController(
             document: doc,
             selection: const TextSelection.collapsed(offset: 0));
       });
     }catch(e){
       setState(() {
         final doc = Document()..insert(0, 'Empty asset');
         _controller = QuillController(
             document: doc, selection: const TextSelection.collapsed(offset: 0));
       });
     }
  }



  @override
  Widget build(BuildContext context) {
    if (_controller == null) {
      _controller = QuillController.basic();
    }
    return Scaffold(
      appBar: AppBar(
        title: Text('Flutter WebView example'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () async {
              // print(_controller.document);          //Instance of 'Document'
              // print(_controller.document.toString());   //Instance of 'Document'
              //  print(_controller.document.toPlainText());
              // print(_controller.document.toDelta());
              json = jsonEncode(_controller!.document.toDelta().toJson());
              print(json);
              final ref = await FirebaseStorage.instance.ref('upload_json/result.json');
              UploadTask uploadTask = ref.putString(json!);
              final snapshot = await uploadTask.whenComplete(() => null);
              final urlDownload = await snapshot.ref.getDownloadURL();
              print('Download Link : $urlDownload');
            },
          ),
        ],
      ),
      body: GestureDetector(
        onTap: () {
          _controller!.moveCursorToEnd();
        },
        child: GetX<getxcontroller>(builder: (_) {
          return SingleChildScrollView(
            child: Container(
              height: MediaQuery.of(context).size.height - 40,
              color: Colors.redAccent,
              child: Container(
                height: MediaQuery.of(context).size.height - controllerx.height.value,//삭제해야함
                color: Colors.white,
                // margin: EdgeInsets.fromLTRB(
                //     20,
                //     20,
                //     20,
                //     ((300 - controllerx.height.value * 0) > 20)
                //         ? (300 - controllerx.height.value * 0)
                //         : 20),
                child:_buildEditor(context),
              ),
            ),
          );
        }),
      ),
    );
  }


  Widget _buildEditor(BuildContext context) {
    var toolbar = QuillToolbar.basic(
          controller: _controller!,
          embedButtons: FlutterQuillEmbeds.buttons(
              //filePickImpl: openFileSystemPickerForDesktop,
              onImagePickCallback: _onImagePickCallback,
              webImagePickImpl: _webImagePickImpl
          ),showAlignmentButtons: true,
        );
       var quillEditor  = QuillEditor(
              embedBuilders: defaultEmbedBuildersWeb,
              controller: _controller!,
              scrollController: ScrollController(),
              scrollable: true,
              focusNode: FocusNode(),
              autoFocus: false,
              readOnly: false,
              placeholder: 'Add content',
              expands: false,
              padding: EdgeInsets.zero,
            );
   return  Column(
       mainAxisAlignment: MainAxisAlignment.spaceBetween,
       children: <Widget>[
         Container(child: toolbar,),
         Expanded(
           flex: 15,
           child: Container(
             color: Colors.white,
             padding: const EdgeInsets.all(10),
             child: quillEditor,
           ),
         ),
       ],
   );
  }

  // Future<String?> openFileSystemPickerForDesktop(BuildContext context) async {
  //   print('----------------------openFileSystemPickerForDesktop');
  //   return await FilesystemPicker.open(
  //     context: context,
  //     rootDirectory: await getApplicationDocumentsDirectory(),
  //     fsType: FilesystemType.file,
  //     fileTileSelectMode: FileTileSelectMode.wholeTile,
  //   );
  // }


  Future<String> _onImagePickCallback(File file) async {
    // Copies the picked file from temporary cache to applications directory
    // final appDocDir = await getApplicationDocumentsDirectory();
    // final copiedFile =
    // await file.copy('${appDocDir.path}/${path.basename(file.path)}');
    File newfile = await file.copy('이거 안해도됨');
    return newfile.path.toString();
  }


  Future<String?> _webImagePickImpl(
      OnImagePickCallback onImagePickCallback) async {
    final result = await FilePicker.platform.pickFiles();
    if (result == null) {
      return null;
    }

    Uint8List? fileBytes = result.files.first.bytes;
    String fileName = result.files.first.name;

    final ref = await FirebaseStorage.instance.ref('uploads/$fileName');
    UploadTask uploadTask = ref.putData(fileBytes!);
    final snapshot = await uploadTask.whenComplete(() => null);
    final urlDownload = await snapshot.ref.getDownloadURL();
    print('Download Link : $urlDownload');

    //File file2 = File.fromRawPath(fileBytes);
         // MissingPluginException(No implementation found for method getApplicationDocumentsDirectory on channel plugins
    //File file3 = File.fromUri(Uri.parse(urlDownload)); //Unsupported operation: Cannot extract a file path from a https URI
    //File file4 = await toFile(urlDownload);     //웹에서는사용불가
    //return onImagePickCallback(file2);
    return urlDownload;
  }
}






//
// pickedFile = result.files.first;
// final path = 'quill_editor2/${pickedFile!.name}';
// print('------------------------------------');
// File file = File(pickedFile!.path!);
// print('------------------------------------');
//
// final ref = FirebaseStorage.instance.ref().child(path);//.child('picked_image')
// UploadTask uploadTask = ref.putFile(file);
// final snapshot = await uploadTask.whenComplete(() => null);
// final urlDownload = await snapshot.ref.getDownloadURL();
// print('Download Link : $urlDownload');
//
//
// return onImagePickCallback(file);

// Renders the image picked by imagePicker from local file storage
// You can also upload the picked image to any server (eg : AWS s3
// or Firebase) and then return the uploaded image URL.

//.replaceAll('\n', '⏎')



