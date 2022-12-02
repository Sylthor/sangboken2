// custom_icon_picker.dart
// by KindaCode.com
import 'package:flutter/material.dart';
// https://www.kindacode.com/article/flutter-how-to-create-a-custom-icon-picker-from-scratch/
Future<IconData?> showIconPicker(
    {required BuildContext context, IconData? defalutIcon}) async {
  // these are the selectable icons
  // they will be displayed in a grid view
  // you can specify the icons you need
  //   'Folder': Icons.folder,
//   'Favorite': Icons.favorite,
//   'Home': Icons.home,
//   'Tree': Icons.park,
//   'Android': Icons.android,
//   'Beer': Icons.sports_bar,
//   'Beer': Icons.wine_bar,
//   'Martini': Icons.local_bar,
//   'Cold': Icons.ac_unit,
//   https://fontawesomeicons.com/materialdesign/icons?search=cup
  final List<IconData> allIcons = [
    Icons.folder,
    Icons.home,
    Icons.park,
    Icons.sports_bar,
    Icons.wine_bar,
    Icons.local_bar,
    Icons.music_note,
    Icons.queue_music,
    Icons.wb_sunny,
    Icons.flight,
    Icons.train,
    Icons.pets,
    Icons.public,
    Icons.stars,
    Icons.folder_special,
    Icons.sports_tennis,
    Icons.engineering,
    Icons.functions,
    Icons.favorite,
    Icons.delete,
    Icons.group
    // Icons.sports_rugby_rounded,
    // Icons.alarm,
    // Icons.call,
    // Icons.snowing,
    // Icons.hearing,
    // Icons.music_note,
    // Icons.edit,
    // Icons.sunny,
    // Icons.radar,

    // add more icons here if you want
  ];

  // selected icon
  // the selected icon is highlighed
  // so it looks different from the others
  IconData? selectedIcon = defalutIcon;

  await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Välj en ny ikon'),
        content: Container(
          width: 320,
          height: 400,
          alignment: Alignment.center,
          // This grid view displays all selectable icons
          child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 60,
                  childAspectRatio: 1 / 1,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10),
              itemCount: allIcons.length,
              itemBuilder: (_, index) => Container(
                key: ValueKey(allIcons[index].codePoint),
                padding: const EdgeInsets.only(right: 10,bottom: 10),
                child: Center(
                  child: IconButton(
                    // give the selected icon a different color
                    color: selectedIcon == allIcons[index]
                        ? Colors.red
                        : Colors.black54,
                    iconSize: 30,
                    icon: Icon(
                      allIcons[index],
                    ),
                    onPressed: () {
                      selectedIcon = allIcons[index];
                      Navigator.of(context).pop();
                    },
                  ),
                ),
              )),
        ),
        actions: [
          ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Stäng'))
        ],
      ));

  return selectedIcon;
}