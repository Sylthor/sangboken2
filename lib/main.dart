// ignore_for_file: prefer_interpolation_to_compose_strings, library_private_types_in_public_api

import "dart:io";
import 'package:flutter/material.dart';
import 'dart:async' show Future;
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import './custom_icon_picker.dart';

// Lägg till en på version
// flutter build apk --no-tree-shake-icons
// flutter build appbundle --no-tree-shake-icons
//https://medium.com/ariel-mejia-dev/sign-and-build-a-flutter-app-in-windows-c1810119df03
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sångboken - Fysikteknologsektionen',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: MyHomePage(title: 'Sångboken - F & TM', storage: CounterStorage()),
    );
  }
}

class CounterStorage {
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/data.txt');
  }

  Future<String> readCounter() async {
    try {
      final file = await _localFile;
      String contents = await file.readAsString();
      return contents;
    } catch (e) {
      return "";
    }
  }

  Future<File> writeCounter(String s) async {
    final file = await _localFile;
    return file.writeAsString(s);
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title, required this.storage}) : super(key: key);
  final String title;
  final CounterStorage storage;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class Page2 extends StatefulWidget {
  const Page2({key, this.title = "Title", required this.storage}) : super(key: key);
  final String title;
  final CounterStorage storage;

  @override
  _Page2 createState() => _Page2();
}

String select1 = "";
List<String> options = [];
List<String> songs = [];
List<String> songsdual = [];
List<bool> filtersongsBool = [];
bool showsearchbar = true;
bool showtext = false;
String source = "";
int number = 0;
bool adding = false;
bool rename = false;
String originalCategory = "";
List<String> categories = [];
final FocusNode focusNode = FocusNode();
String selectedCategory = "Alla sånger";
//TODO Fixa
// final Map<String, IconData> myIconCollection = {
//   'Folder': Icons.folder,
//   'Favorite': Icons.favorite,
//   'Home': Icons.home,
//   'Tree': Icons.park,
//   'Android': Icons.android,
//   'Beer': Icons.sports_bar,
//   'Beer': Icons.wine_bar,
//   'Martini': Icons.local_bar,
//   'Cold': Icons.ac_unit,
// };
IconData _selectedIcon = Icons.folder;

class _MyHomePageState extends State<MyHomePage> {
  String stl = "";
  String s = "";
  final tc = TextEditingController();
  final tc2 = TextEditingController();
  bool _validate = false;
  bool empty = false;

  @override
  void initState() {
    super.initState();
    widget.storage.readCounter().then((String value) {
      setState(() {
        source = value;
        //Reset source
        if (source == "") {
          source = "{[Favoriter]:[]}";
          widget.storage.writeCounter(source);
        }
        number = '{['.allMatches(source).length - 1;
        for (int i = 0; i < number + 1; i++) {
          categories.add(getElement(source.split("{")[i + 1], "[", "]"));
        }
      });
    });

    listAssets().then((String value) {
      setState(() {
        String allAssets = value;
        int clippedindex = allAssets.indexOf("[\"assets/");
        while (clippedindex > 0) {
          stl += getElement(allAssets, "[\"assets/", ".tex\"]") + "|";
          allAssets = allAssets.substring(clippedindex + 1);
          clippedindex = allAssets.indexOf("[\"assets/");
        }
        stl = stl.substring(0, stl.length - 1);
        if (stl.contains("%C3%85")) {
          stl = stl.replaceAll("%C3%85", "Å");
        }
        if (stl.contains("%C3%A5")) {
          stl = stl.replaceAll("%C3%A5", "å");
        }
        if (stl.contains("%C3%84")) {
          stl = stl.replaceAll("%C3%84", "Ä");
        }
        if (stl.contains("%C3%A4")) {
          stl = stl.replaceAll("%C3%A4", "ä");
        }
        if (stl.contains("%C3%96")) {
          stl = stl.replaceAll("%C3%96", "Ö");
        }
        if (stl.contains("%C3%B6")) {
          stl = stl.replaceAll("%C3%B6", "ö");
        }
        if (stl.contains("%20")) {
          stl = stl.replaceAll("%20", " ");
        }
        if (stl.contains("%CE%94")) {
          stl = stl.replaceAll("%CE%94", "Δ");
        }
        options = stl.split("|");
        for (int i = 0; i < options.length; i++) {
          loadAsset(options[i]).then((String value) {
            setState(() {
              String song = getElement(value.substring(value.indexOf("\\begin{song}{") + 12), "{", "}{");
              songsdual.add(song + "|" + options[i]);
              songs.add(song);
              if (i == options.length - 1) {
                songsdual.sort();
                songs.sort();

                int firstofeh = -1; //Första förekomsten av en sång som börjar på Ä
                List<int> alloh = []; //Alla förekomster av sånger som börjar på Å
                for (int k = 0; k < songs.length; k++) { //Loopar alla låtar
                  if (songs[k][0] == "Ä" && firstofeh == -1) {
                    firstofeh = k; //Första förekomsten av en sång som börjar på Ä
                  }
                  if (songs[k][0] == "Å") {
                    alloh.add(k); //Lägg till alla sånger som börjar på Å (i alphabetisk ordning)
                  }
                }
                for (int k = 0; k < alloh.length; k++) {
                  songs.insert(firstofeh + k, songs[alloh[k]]); //Lägger in alla sånger på Å innan sångerna på Ä
                  songs.removeAt(alloh[k] + 1); //Tar bort dem från senare i listan
                  songsdual.insert(firstofeh + k, songsdual[alloh[k]]);
                  songsdual.removeAt(alloh[k] + 1);
                }
              }
              filtersongsBool.add(true);
            });
          });
        }
      });
    });
  }
  String temp = "";
  @override
  Widget build(BuildContext context) {
    text(index) {
      if (!adding || index != number - 1) {
        if (rename && originalCategory == categories[index + 1]) {
          return TextField(
            textCapitalization: TextCapitalization.sentences,
            controller: tc2,
            autofocus: true,
            focusNode: focusNode,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.deny(RegExp(r'[{}\[\]\|+]')),
            ],
            onChanged: (s) {
              setState(() {
                if ((categories.contains(tc2.text) && tc2.text != originalCategory) || tc2.text == "Alla sånger") {
                  _validate = true;
                } else {
                  _validate = false;
                }
              });
            },
            onSubmitted: (b) {
              setState(() {
                if (!_validate) {
                  source = replace(source, "{[" + originalCategory, "{[" + tc2.text);
                  widget.storage.writeCounter(source);
                  //TODO Fix Categories
                  categories[categories.indexOf(originalCategory)] = tc2.text;
                  // categories.replaceRange(start, end, replacements)
                  rename = false;
                  tc2.clear();
                  tc2.text = "";
                }
              });
            },
            decoration: InputDecoration(
              labelText: "Namn på ny lista",
              errorText: _validate ? 'Namn på lista finns redan' : null,
              suffixIcon: IconButton(
                onPressed: () {
                  setState(() {
                    tc2.clear();
                    tc2.text = "";
                    rename = false;
                    _validate = false;
                  });
                },
                icon: const Icon(Icons.clear),
              ),
            ),
          );
        } else {
          return Text(getElement(source.split("{")[index + 2], "[", "]"));
        }
      }
      if (adding && index == number - 1) {
        return TextField(
          textCapitalization: TextCapitalization.sentences,
          controller: tc2,
          autofocus: true,
          focusNode: focusNode,
          inputFormatters: <TextInputFormatter>[
            FilteringTextInputFormatter.deny(RegExp(r'[{}\[\]\|+]')),
          ],
          onChanged: (s) {
            setState(() {
              if (categories.contains(tc2.text) || tc2.text == "Alla sånger") {
                _validate = true;
              } else {
                _validate = false;
              }
            });
          },
          onSubmitted: (b) {
            setState(() {
              if (!_validate) {
                source = source + ",{[" + tc2.text + "]:[]:[IconData(U+0E2A3)]}";
                widget.storage.writeCounter(source);
                categories.add(tc2.text);
                adding = false;
                tc2.clear();
                tc2.text = "";
              }
            });
          },
          decoration: InputDecoration(
            labelText: "Namn på ny lista",
            errorText: _validate ? 'Namn på lista finns redan' : null,
            suffixIcon: IconButton(
              onPressed: () {
                setState(() {
                  tc2.clear();
                  tc2.text = "";
                  number--;
                  adding = false;
                  _validate = false;
                });
              },
              icon: const Icon(Icons.clear),
            ),
          ),
        );
      }
    }
    // Future<void> _showIconPickerDialog() async {
    //   IconData iconPicked = await showDialog(
    //     context: context,
    //     builder: (BuildContext context) {
    //       return AlertDialog(
    //         title: const Text(
    //           'Pick an icon',
    //           style: TextStyle(fontWeight: FontWeight.bold),
    //         ),
    //         content: IconPicker(
    //           initialValue: "Folder",
    //           icon: const Icon(Icons.add),
    //           iconCollection: myIconCollection,
    //           context: context,
    //           onChanged: (val){
    //             print("Beta:"+val);
    //           },
    //           onSaved: (val){
    //             print("Gamma:"+val.toString());
    //           },
    //           onFieldSubmitted: (val){
    //             print("Alpha:"+val);
    //           },
    //         ),
    //       );
    //     },
    //   );
    //
    //   if (iconPicked != null) {
    //     debugPrint('Icon changed to $iconPicked');
    //     setState(() {
    //       print(iconPicked);
    //     });
    //   }
    // }
    showsettings(index) {
      if (!adding || index != number - 1) {
        return IconButton(
          // padding: const EdgeInsets.only(right: 10,bottom: 10),
          onPressed: () {
            setState(() {
              //TODO Lägg till individuella inställningar för varje kategori
            });
          },
          icon: PopupMenuButton<String>(
            icon: const Icon(Icons.settings),
            itemBuilder: (BuildContext bc) {
              return [
                PopupMenuItem(
                  value: 'Delete',
                  child: Row(
                    children: const [
                      Padding(
                        padding: EdgeInsets.only(right:4.0),
                        child: Icon(Icons.delete),
                      ),
                      Text("Radera lista"),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'Edit',
                  child: Row(
                    children: const [
                      Padding(
                        padding: EdgeInsets.only(right:4.0),
                        child: Icon(Icons.edit),
                      ),
                      Text("Ändra namn"),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: "Icon",
                  child: Row(
                    children: const [
                      Padding(
                        padding: EdgeInsets.only(right:4.0),
                        child: Icon(Icons.tag_faces),
                      ),
                      Text("Ändra ikon"),
                    ],
                  ),
                ),
              ];
            },
            onSelected: (value) async {
                if (value == "Delete") {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text(
                          "Är du säker på att du vill radera listan \"" + categories[index + 1] + "\"?",
                          style: const TextStyle(fontSize: 20),
                        ),
                        actions: [
                          TextButton(
                            child: const Text("Ja"),
                            onPressed: () {
                              setState(() {
                                if (selectedCategory == categories[index + 1]) {
                                  for (int i = 0; i < filtersongsBool.length; i++) {
                                    filtersongsBool[i] = true;
                                    selectedCategory = "Alla sånger";
                                    empty = false;
                                  }
                                  showsearchbar = false;
                                }
                                source = replace(source, ",{[" + categories[index + 1] + getElement(source, ",{[" + categories[index + 1], "}") + "}", "");
                                categories.removeAt(index + 1);
                                widget.storage.writeCounter(source);
                                number--;
                              });
                              Navigator.of(context).pop();
                            },
                          ),
                          TextButton(
                            child: const Text("Nej"),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      );
                    },
                  );
                }
                if (value == "Edit") {
                  setState(() {
                    rename = true;
                    tc2.text = categories[index + 1];
                    originalCategory = categories[index + 1];
                  });
                }
                if (value == "Icon") {
                  String s = "";
                  int output = int.parse("0E2A3".padLeft(5, '0'), radix: 16);
                  if(source.split("},{").length>1 && (!adding || index != number - 1)) {
                    s = getElement(source.split("},{")[index + 1], ":[IconData(U+", ")]");
                    output = int.parse(s.padLeft(5, '0'), radix: 16);
                  }
                    final IconData? result = await showIconPicker(
                        context: context, defalutIcon: IconData(output,fontFamily: "MaterialIcons"),);
                    setState(() {
                      _selectedIcon = result!;
                      String s2 = getElement(_selectedIcon.toString(), "IconData(U+", ")");
                      String s3 = getElement(source.split("},{")[index + 1], ":[IconData(U+", ")]");
                      source = replace(source, source.split("},{")[index+1], replace(source.split("},{")[index+1],s3,s2));
                      widget.storage.writeCounter(source);
                    });
                }
            },
          ),
        );
      }
    }

    var list = ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      itemCount: number,
      itemBuilder: (context, index) {
        String s = "";
        int output = 0;
        if(source.split("},{").length>1 && (!adding || index != number - 1)) {
          s = getElement(source.split("},{")[index + 1], ":[IconData(U+", ")]");
          output = int.parse(s.padLeft(5, '0'), radix: 16);
        } else{
          output = int.parse("0E2A3".padLeft(5, '0'), radix: 16);
        }
        return Column(
          children: <Widget>[
            ListTile(
              leading: Icon(IconData(output,fontFamily: "MaterialIcons")),
              title: text(index),
              trailing: showsettings(index),
              onTap: () {
                setState(() {
                  selectedCategory = categories[index + 1];
                  widget.storage.readCounter().then((String value) {
                    setState(() {
                      empty = true;
                      List<String> listofsongs = getElement(source, "{[" + categories[index + 1] + "]:[", "]").split("|");
                      for (int i = 0; i < filtersongsBool.length; i++) {
                        filtersongsBool[i] = false;
                      }
                      if (listofsongs[0] != "") {
                        for (int k = 0; k < listofsongs.length; k++) {
                          empty = false;
                          filtersongsBool[songs.indexOf(listofsongs[k])] = true;
                        }
                      }
                      showsearchbar = false;
                      Navigator.of(context).pop();
                    });
                  });
                });
              },
            ),
          ],
        );
      },
    );
    return GestureDetector(
      onTap: () {
        final FocusScopeNode currentScope = FocusScope.of(context);
        if (!currentScope.hasPrimaryFocus && currentScope.hasFocus) {
          FocusManager.instance.primaryFocus!.unfocus();
          if (adding) {
            number--;
            adding = false;
            tc2.clear();
            tc2.text = "";
            setState(() {
              _validate = false;
            });
          }
        }
      },
      child: Scaffold(
        onDrawerChanged: (b) {
          setState(() {
            if (!b) {
              FocusScope.of(context).unfocus();
              final FocusScopeNode currentScope = FocusScope.of(context);
              if (!currentScope.hasPrimaryFocus && currentScope.hasFocus) {
                FocusManager.instance.primaryFocus!.unfocus();
              }
            }
            if (adding && !b) {
              tc2.clear();
              tc2.text = "";
              number = number - 1;
              adding = false;
              _validate = false;
            }
            if (rename && !b) {
              rename = false;
            }
          });
        },
        drawer: Drawer(
          child: ListView(
            // Remove padding
            padding: EdgeInsets.zero,
            children: [
              Container(
                  color: Colors.black,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Image.asset('images/funktionsbild.png'),
                  )),
              ListTile(
                leading: const Icon(Icons.format_align_left),
                title: const Text('Alla sånger'),
                onTap: () {
                  setState(() {
                    selectedCategory = "Alla sånger";
                    showsearchbar = true;
                    empty = false;
                    for (int i = 0; i < filtersongsBool.length; i++) {
                      filtersongsBool[i] = true;
                      tc.text = "";
                      tc.clear();
                    }
                    Navigator.of(context).pop();
                  });
                },
              ),
              //Load the list of "Favoriter"
              ListTile(
                leading: const Icon(Icons.star),
                title: const Text('Favoriter'),
                onTap: () {
                  setState(() {
                    selectedCategory = "Favoriter";
                    widget.storage.readCounter().then((String value) {
                      setState(() {
                        empty = true;
                        List<String> favorites = getElement(source, "{[Favoriter]:[", "]").split("|");
                        for (int i = 0; i < filtersongsBool.length; i++) {
                          filtersongsBool[i] = false;
                        }
                        if (favorites[0] != "") {
                          for (int k = 0; k < favorites.length; k++) {
                            filtersongsBool[songs.indexOf(favorites[k])] = true;
                            empty = false;
                          }
                        }
                        showsearchbar = false;
                        Navigator.of(context).pop();
                      });
                    });
                  });
                },
              ),
              list,
              ListTile(
                leading: const Icon(Icons.add),
                title: const Text('Lägg till lista'),
                onTap: () {
                  setState(() {
                    if (!adding) {
                      adding = true;
                      number++;
                    }
                  });
                },
              ),
              const Divider(),
              //TODO
              // ListTile(
              //   leading: const Icon(Icons.settings),
              //   title: const Text('Inställningar'),
              //   onTap: () {
              //     setState(() {
              //       widget.storage.readCounter().then((String value) {
              //         setState(() {
              //           //TODO Font
              //           //TODO Färger
              //           Navigator.of(context).pop();
              //         });
              //       });
              //     });
              //   },
              // ),
              // ListTile(
              //   leading: const Icon(Icons.bug_report),
              //   title: const Text('Rapportera buggar'),
              //   onTap: () {
              //     setState(() {
              //       widget.storage.readCounter().then((String value) {
              //         setState(() {
              //           Navigator.of(context).pop();
              //         });
              //       });
              //     });
              //   },
              // ),
              // ListTile(
              //   leading: const Icon(Icons.person),
              //   title: const Text('Kontakta sångförmän'),
              //   onTap: () {
              //     setState(() {
              //       widget.storage.readCounter().then((String value) {
              //         setState(() {
              //           Navigator.of(context).pop();
              //         });
              //       });
              //     });
              //   },
              // ),
            ],
          ),
        ),
        appBar: AppBar(
          centerTitle: true,
          title: RichText(
            textAlign: TextAlign.center,
            text: const TextSpan(children: <TextSpan>[
              TextSpan(
                text: "Sångboken - F & ",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontFamily: "EBGaramond",
                ),
              ),
              TextSpan(
                  text: "TM",
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 24,
                    fontFamily: "EBGaramond",
                  ))
            ]),
          ),
          backgroundColor: Colors.black,
        ),
        body: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Text(source),
              Visibility(
                visible: showsearchbar,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: TextField(
                    textCapitalization: TextCapitalization.sentences,
                    controller: tc,
                    focusNode: focusNode,
                    inputFormatters: [
                      FilteringTextInputFormatter.deny(RegExp('[|]')),
                    ],
                    onChanged: (b) {
                      setState(() {
                        if (tc.text.isNotEmpty) {
                          for (int i = 0; i < songs.length; i++) {
                            if (songs[i].toLowerCase().contains(tc.text.toLowerCase())) {
                              filtersongsBool[i] = true;
                            } else {
                              filtersongsBool[i] = false;
                            }
                          }
                        } else {
                          for (int i = 0; i < filtersongsBool.length; i++) {
                            filtersongsBool[i] = true;
                          }
                        }
                        // for(int i = 0; i<filtersongsBool.length; i++){
                        //   filtersongsBool[i] = true;
                        // }
                      });
                    },
                    style: const TextStyle(
                      fontSize: 18,
                      height: 1.0,
                      color: Colors.black,
                    ),
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      labelText: "Sök efter en sång",
                      focusColor: Colors.blue,
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            for (int i = 0; i < songs.length; i++) {
                              filtersongsBool[i] = true;
                            }
                            tc.clear;
                            tc.text = "";
                            FocusScope.of(context).unfocus();
                          });
                          final FocusScopeNode currentScope = FocusScope.of(context);
                          if (!currentScope.hasPrimaryFocus && currentScope.hasFocus) {
                            FocusManager.instance.primaryFocus!.unfocus();
                          }
                        },
                        icon: const Icon(Icons.clear),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue),
                      ),
                    ),
                  ),
                ),
              ),
              ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: filtersongsBool.length,
                itemBuilder: (context, index) {
                  return Visibility(
                    visible: filtersongsBool[index],
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
                      child: Card(
                        color: Colors.redAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: <Widget>[
                            ListTile(
                              title: Text(
                                songs[index],
                                style: const TextStyle(color: Colors.white, fontSize: 20),
                              ),
                              onTap: () {
                                FocusScope.of(context).unfocus();
                                Navigator.of(context).push(_createRoute());
                                select1 = songs[index];
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
              Visibility(
                visible: empty,
                child: const Padding(
                  padding: EdgeInsets.all(18.0),
                  child: Text(
                    "Här var det tomt!",
                    style: TextStyle(fontSize: 20, color: Color.fromRGBO(0, 0, 0, 100)),
                  ),
                ),
              ),
              Visibility(
                visible: empty,
                child: const Padding(
                  padding: EdgeInsets.all(18.0),
                  child: Text(
                    "För att lägga till sånger till en lista, välj en sång och klicka på plustecknet i hörnet (eller stjärnan för \"Favoriter\").",
                    style: TextStyle(fontSize: 20, color: Color.fromRGBO(0, 0, 0, 100)),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

Future<String> loadAsset(file) async {
  try {
    String s = await rootBundle.loadString('assets/' + file + '.tex');
    return s;
  } on Exception catch (_) {
    return "";
  }
}

Future<String> listAssets() async {
  var assets = await rootBundle.loadString('AssetManifest.json');
  return assets;
}

String getElement(String data, String startString, String stopString) {
  String output = "";
  try {
    String alternative = startString.substring(0, startString.length - 1) + " " + startString.substring(startString.length - 1, startString.length);

    int startIndex = data.indexOf(alternative);
    int l = alternative.length;
    if (startIndex == -1) {
      startIndex = data.indexOf(startString);
      l = startString.length;
    }

    int stopIndex = data.indexOf(stopString, startIndex + l);
    output = data.substring(startIndex, stopIndex);
    output = output.substring(l);
  } catch (e) {
    output = "";
  }
  return output;
}

String replace(String data, String finder, String replacer) {
  String output = "";
  output = data.substring(0, data.indexOf(finder)) + replacer + data.substring(data.indexOf(finder) + finder.length, data.length);

  return output;
}

class _Page2 extends State<Page2> {
  String s = "";
  Text lyrics = const Text("", style: TextStyle(fontSize: 20, fontFamily: "EBGaramond"));
  Text melody = const Text("", style: TextStyle(fontSize: 20, fontFamily: "EBGaramond", fontStyle: FontStyle.italic));
  bool favorite = false;

  Icon star = const Icon(Icons.star_border, color: Colors.white);

  @override
  void initState() {
    super.initState();
    String asset = "";
    for (int i = 0; i < songs.length; i++) {
      if (songsdual[i].split("|")[0] == select1) {
        asset = songsdual[i].split("|")[1];
      }
    }
    loadAsset(asset).then((String value) {
      setState(() {
        s = value;
        s = s.replaceAll("\n", "§");
        String tempstring = "";
        List<int> freq = [];
        for (int index = s.indexOf("§"); index >= 0; index = s.indexOf("§", index + 1)) {
          freq.add(index);
        }
        int displace = 0;
        for (int i = 0; i < freq.length - 1; i++) {
          if (freq[i] == freq[i + 1] - 2) {
            s = s.substring(0, freq[i] - displace) + s.substring(freq[i + 1] - displace);
            displace += 2;
          }
          if (freq[i] == freq[i + 1] - 1) {
            s = s.substring(0, freq[i] - displace) + s.substring(freq[i + 1] - displace);
            displace += 1;
          }
        }
        s = s.replaceAll("§", "\n");
        s = s.replaceAll("\\\\", "");
        s = s.replaceAll("    ", "");
        s = s.replaceAll("\\repopen", "𝄆 ");
        s = s.replaceAll("\\repclose", " 𝄇");
        s = s.replaceAll("\$", "");
        s = s.replaceAll("\\varepsilon", "ε");
        s = s.replaceAll("\\iota", "ι");
        s = s.replaceAll("\\tau", "τ");
        s = s.replaceAll("\\nu", "ν");
        s = s.replaceAll("\\xi", "ξ");
        s = s.replaceAll("\\upsilon", "υ");
        s = s.replaceAll("\\delta", "δ");
        s = s.replaceAll("\\mu", "μ");
        s = s.replaceAll("\\theta", "θ");
        s = s.replaceAll("\\kappa", "κ");
        s = s.replaceAll("\\pi", "π");
        s = s.replaceAll("\\rho", "ρ");
        s = s.replaceAll("\\varphi", "φ");
        // s = s.replaceAll("\\varphi", "ϕ");
        s = s.replaceAll("\\omega", "ω");
        s = s.replaceAll("\\Omega", "Ω");
        s = s.replaceAll("\\circ", "°");
        s = s.replaceAll("\\ldots", "...");
        if (s.contains("\\kom{")) {
          int index = s.indexOf(getElement(s, "\\kom{", "}"));
          s = s.substring(0, index) + s.substring(index + getElement(s, "\\kom{", "}").length);
        }
        List<String> splitter = s.split("\n");
        for (int i = 0; i < splitter.length; i++) {
          if (!splitter[i].contains("\\begin") &&
              !splitter[i].contains("\\end") &&
              !splitter[i].contains("\\textit") &&
              !splitter[i].contains("\\kom") &&
              !splitter[i].contains("\\av") &&
              !splitter[i].contains("%") &&
              !splitter[i].contains("\\newp") &&
              !splitter[i].contains("\\iffalse") &&
              !splitter[i].contains("\\fi")) {
            tempstring += splitter[i] + "\n";
          }
          if (splitter[i].contains("\\end{vers}")) {
            tempstring += " \n";
          }
          if (splitter[i].contains("\\textit")) {
            tempstring += "--" + getElement(splitter[i], "\\textit{", "}") + "--\n";
          }
          if (splitter[i].contains("%")) {
            if (!splitter[i].contains("\\%")) {
              if (splitter[i].substring(0, splitter[i].indexOf("%")).length > 2) {
                tempstring += splitter[i].substring(0, splitter[i].indexOf("%")) + "\n";
              }
            } else {
              tempstring += splitter[i].replaceAll("\\%", "%") + "\n";
            }
          }
        }
        s = tempstring;
        if (s.contains("\\mel{")) {
          melody = Text("Mel: " + getElement(s, "\\mel{", "}"), style: const TextStyle(fontSize: 20, fontFamily: "EBGaramond", fontStyle: FontStyle.italic));
          String wonky = s.substring(s.indexOf(getElement(s, "\\mel{", "}")) + getElement(s, "\\mel{", "}").length + 2,
              s.indexOf(getElement(s, "\\mel{", "}")) + getElement(s, "\\mel{", "}").length + 3);
          if (wonky == "\n") {
            s = s.substring(s.indexOf(getElement(s, "\\mel{", "}")) + getElement(s, "\\mel{", "}").length + 3);
          } else {
            s = s.substring(s.indexOf(getElement(s, "\\mel{", "}")) + getElement(s, "\\mel{", "}").length + 2);
          }
        } else {
          melody = Text("Mel: " + select1, style: const TextStyle(fontSize: 20, fontFamily: "EBGaramond", fontStyle: FontStyle.italic));
        }
        lyrics = Text(s, style: const TextStyle(fontSize: 20, fontFamily: "EBGaramond"));
        widget.storage.readCounter().then((String value) {
          setState(() {
            source = value;
            if (getElement(source, "{[Favoriter]:[", "]") != "") {
              List<String> favorites = getElement(source, "{[Favoriter]:[", "]").split("|");
              if (favorites.contains(select1)) {
                favorite = true;
                star = const Icon(Icons.star, color: Colors.white);
              }
            }
          });
        });
        categories = [];
        for (int i = 0; i < number + 1; i++) {
          categories.add(getElement(source.split("{")[i + 1], "[", "]"));
        }
        // if(filtersongsBool[songs.indexOf(select1)]){
        //   favorite = false;
        // }
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(240, 240, 240, 1),
      appBar: AppBar(
        centerTitle: true,
        title: Text(select1),
        backgroundColor: Colors.black,
        actions: <Widget>[
          PopupMenuButton<String>(
            icon: const Icon(Icons.add),
            itemBuilder: (context) => categories
                .map((item) => PopupMenuItem<String>(
                      value: item,
                      child: Text(
                        item,
                      ),
                    ))
                .toList(),
            //TODO Add button
            onSelected: (selectedvalue) {
              widget.storage.readCounter().then((String value) {
                setState(() {
                  source = value;
                  String insert = "";
                  // print(getElement(source, "{[" + selectedvalue + "]:[", "]"));
                  print(select1);
                  if (!getElement(source, "{[" + selectedvalue + "]:[", "]").split("|").contains(select1)) {
                    if (getElement(source, "{[" + selectedvalue + "]:[", "]") == "") {
                      insert = select1;
                      source = replace(source, "{[" + selectedvalue + "]:[]", "{[" + selectedvalue + "]:[" + insert + "]");
                    } else {
                      insert = "{[" + selectedvalue + "]:["+getElement(source, "{[" + selectedvalue + "]:[", "]") + "|" + select1;
                      print(insert);
                      source = replace(source, "{[" + selectedvalue + "]:["+getElement(source, "{[" + selectedvalue + "]:[", "]"), insert);
                    }
                    // source = source.substring(0,source.indexOf("{[Favoriter]:["))+"{[Favoriter]:["+insert+"]}"+source.substring(source.indexOf(getElement(source, "{[Favoriter]:","}"))+("{[Favoriter]:[").length+getElement(source, "{[Favoriter]:[","]}").length);
                    // source = replace(source, getElement(source, "{[Favoriter]:[","]}"), insert);
                    widget.storage.writeCounter(source);
                    if (selectedvalue == "Favoriter") {
                      star = const Icon(Icons.star, color: Colors.white);
                      favorite = true;
                    }
                  }
                });
              });
            },
          ),
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: IconButton(
                icon: star,
                onPressed: () {
                  setState(() {
                    if (favorite) {
                      star = const Icon(Icons.star_border, color: Colors.white);
                      if (source.contains("|" + select1 + "|")) {
                        source = replace(source, "|" + select1 + "|", "|");
                      } else {
                        if (source.contains(select1 + "|")) {
                          source = replace(source, select1 + "|", "");
                        } else {
                          if (source.contains("|" + select1)) {
                            source = replace(source, "|" + select1, "");
                          } else {
                            source = replace(source, select1, "");
                          }
                        }
                      }
                      if (source.contains("||")) {
                        source = replace(source, "||", "|");
                      }
                      if (source.contains("[|")) {
                        source = replace(source, "[|", "[");
                      }
                      if (source.contains("|]")) {
                        source = replace(source, "|]", "]");
                      }
                      widget.storage.writeCounter(source);
                      favorite = false;
                    } else {
                      widget.storage.readCounter().then((String value) {
                        setState(() {
                          source = value;
                          String insert = "";
                          if (getElement(source, "{[Favoriter]:[", "]") == "") {
                            insert = select1;
                            source = replace(source, "{[Favoriter]:[]", "{[Favoriter]:[" + insert + "]");
                          } else {
                            insert = getElement(source, "{[Favoriter]:[", "]") + "|" + select1;
                            source = replace(source, getElement(source, "{[Favoriter]:[", "]"), insert);
                          }
                          // source = source.substring(0,source.indexOf("{[Favoriter]:["))+"{[Favoriter]:["+insert+"]}"+source.substring(source.indexOf(getElement(source, "{[Favoriter]:","}"))+("{[Favoriter]:[").length+getElement(source, "{[Favoriter]:[","]}").length);
                          // source = replace(source, getElement(source, "{[Favoriter]:[","]}"), insert);
                          widget.storage.writeCounter(source);
                          favorite = true;
                          star = const Icon(Icons.star, color: Colors.white);
                        });
                      });
                    }
                  });
                }),
          ),
        ],
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: melody,
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: lyrics,
            )
          ],
        ),
      ),
    );
  }
}

Route _createRoute() {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => Page2(storage: CounterStorage()),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      var begin = const Offset(1.0, 0.0);
      var end = Offset.zero;
      var curve = Curves.ease;
      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
      return SlideTransition(
        position: animation.drive(tween),
        child: child,
      );
    },
  );
}
