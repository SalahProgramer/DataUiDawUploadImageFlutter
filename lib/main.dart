import 'dart:io';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // List users = [];
  CollectionReference col1 = FirebaseFirestore.instance.collection("users");
  DocumentReference coldoc = FirebaseFirestore.instance
      .collection("users")
      .doc("xbdRPYxf9s9wCxI5MJAR");

  //
  // getData() async {
  //   var responce = await col.get();
  //   responce.docs.forEach((element) {
  //     setState(() {
  //       users.add(element.data());
  //     });
  //   });
  //   // print(users);
  // }
  // List users = [];
  // DocumentReference col = FirebaseFirestore.instance
  //     .collection("users")
  //     .doc("xbdRPYxf9s9wCxI5MJAR");
  //
  // getData() async {
  //   var responce = await col.get();
  //
  //   setState(() {
  //     users.add(responce.data());
  //   });
  //
  //   // print(users);
  // }
  File? file;
  var imagrpicker = ImagePicker();

  getImages() async {
    var refStore = await FirebaseStorage.instance.ref().list();

    refStore.items.forEach((element) {
      print("name : " + element.name);
    });
    print("===================================");
    refStore.prefixes.forEach((elemen2t) {
      print("name : " + elemen2t.name);
    });
  }

  uploadImage() async {
    var imagepicked = await imagrpicker.pickImage(source: ImageSource.gallery);
    if (imagepicked != null) {
      file = File(imagepicked.path);
      print(file);
      print(
          "======================================================================\n  " +
              imagepicked.name);
//start upload
      var random=Random().nextInt(10000000);
      var rand="$random${imagepicked.name}";
      var refStore = FirebaseStorage.instance.ref("images/${rand}");
      await refStore.putFile(file!);
      var url = await refStore.getDownloadURL();
      print(
          "======================================================================\n  " +
              url.toString()+"");
    } else {
      print("null");
    }
  }
  Future<ListResult>? dawnload;
Map<int, double> dawnloadProgress={};
  @override
  void initState() {
    // getData();
    dawnload = FirebaseStorage.instance.ref('images/').list();
    getImages();
  }
  Future  dawnloadFile(int index,Reference ref) async{
    final url= await ref.getDownloadURL();
final dir =await getTemporaryDirectory();
final file=('${dir.path}/${ref.name}');
await Dio().download(url, file,onReceiveProgress: (count, total) {
  double progress=count/total;
setState(() {

  dawnloadProgress[index]=progress;
});
},);
if(url.contains('.mp4')){


  await GallerySaver.saveVideo(file,toDcim: true);

}
    else if(url.contains('.jpg')){


      await GallerySaver.saveImage(file,toDcim: true);

    }


    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Dawnloaded ${ref.name}")));


  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        // backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text("Task"),
          centerTitle: true,
        ),
        body: SafeArea(
          child: Center(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () async {
                  await uploadImage();
                },
                child: Text("upload file"),
              ),
              FutureBuilder(
                future: dawnload,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    final files = snapshot.data!.items;

                    return Container(
                      height: 500,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(),
                      child: ListView.builder(
                        itemCount: files.length,
                        itemBuilder: (context, index) {
                          double? progress=dawnloadProgress[index];
                          return ListTile(
                            titleAlignment: ListTileTitleAlignment.center,

                            subtitle: progress!=null ? LinearProgressIndicator(
                              value: progress,
                              backgroundColor: Colors.black26,
                            ): null,
                            trailing: IconButton(
                                icon: Icon(Icons.download), onPressed: () {dawnloadFile(index,files[index]);}),
                            title: Text(files[index].name),
                          );
                        },
                      ),
                    );
                  }
                  if (snapshot.hasError) {
                    return Text("error");
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator(
                      backgroundColor: Colors.green,
                      strokeWidth: 2,
                    );
                  } else {
                    return Text("data");
                  }
                },
              )
            ],
          )
              // StreamBuilder(stream: coldoc.snapshots(),builder: (context, snapshot) {  //do show data and change if you change in firebase
              //   if (snapshot.hasData) {
              //     return ListView.builder(
              //         itemCount: 1,
              //         itemBuilder: (context, i) {
              //           return ListTile(
              //             title: Text(snapshot.data!.get("username").toString()+""),
              //                             subtitle: Text(snapshot.data!.get("age").toString()+""),
              //           );
              //         });
              //   }
              //   if (snapshot.hasError) {
              //     return Text("error");
              //   }
              //   if (snapshot.connectionState == ConnectionState.waiting) {
              //     return CircularProgressIndicator(
              //       backgroundColor: Colors.green,
              //       strokeWidth: 2,
              //     );
              //   } else {
              //     return Text("data");
              //   }
              // },)

              //   StreamBuilder(stream: col1.snapshots(),builder: (context, snapshot) {  //do show data and change if you change in firebase
              //     if (snapshot.hasData) {
              //     return ListView.builder(
              //         itemCount: snapshot.data?.size,
              //         itemBuilder: (context, i) {
              //           return ListTile(
              //             title: Text(
              //                 snapshot.data!.docs[i].get("username").toString() +
              //                     ""),
              //             subtitle: Text(
              //                 snapshot.data!.docs[i].get("age").toString() + ""),
              //           );
              //         });
              //   }
              //   if (snapshot.hasError) {
              //     return Text("error");
              //   }
              //   if (snapshot.connectionState == ConnectionState.waiting) {
              //     return CircularProgressIndicator(
              //       backgroundColor: Colors.green,
              //       strokeWidth: 2,
              //     );
              //   } else {
              //     return Text("data");
              //   }
              // },)
              // FutureBuilder(future: coldoc.get(),
              //   builder: (context, snapshot) {
              //     if (snapshot.hasData) {
              //       return ListView.builder(
              //           itemCount: 1,
              //           itemBuilder: (context, i) {
              //             return
              //               ListTile(
              //                 title: Text(snapshot.data!.get("username").toString()+""),
              //                 subtitle: Text(snapshot.data!.get("age").toString()+""),
              //
              //               );
              //           });
              //     }
              //     if (snapshot.hasError) {
              //       return Text("error");
              //     }
              //     if (snapshot.connectionState == ConnectionState.waiting) {
              //       return CircularProgressIndicator(
              //         backgroundColor: Colors.green,
              //         strokeWidth: 2,
              //       );
              //     }
              //     else{
              //       return Text("data");
              //     }
              //   },
              //
              // )

              //     FutureBuilder(future: col1.get(),
              //   builder: (context, snapshot) {
              //     if (snapshot.hasData) {
              //       return ListView.builder(
              //           itemCount: snapshot.data?.size,
              //           itemBuilder: (context, i) {
              //             return
              //               ListTile(
              //                 title: Text(snapshot.data!.docs[i].get("username").toString()+""),
              //                 subtitle: Text(snapshot.data!.docs[i].get("age").toString()+""),
              //
              //               );
              //     });
              //     }
              //     if (snapshot.hasError) {
              //       return Text("error");
              //     }
              //     if (snapshot.connectionState == ConnectionState.waiting) {
              //       return CircularProgressIndicator(
              //         backgroundColor: Colors.green,
              //         strokeWidth: 2,
              //       );
              //     }
              //     else{
              //       return Text("data");
              //     }
              //   },
              //
              // )

              // users.isEmpty || users==null ?  CircularProgressIndicator(backgroundColor: Colors.green,strokeWidth: 2,) : ListView.builder(
              //   itemCount: users.length,
              //   itemBuilder: (context, i) {
              //     return
              //       ListTile(
              //         title: Text(users[i]['username'].toString()+""),
              //         subtitle: Text(users[i]['age'].toString()+""),
              //
              //       );
              //       Text(
              //       users[i]['username'].toString()+"",
              //       style: TextStyle(),
              //     );
              //   },
              // ), // child: Container(

              ),
        ));
  }
}
