import 'package:flutter/material.dart';
class NavBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        // Remove padding
        padding: EdgeInsets.zero,
        children: [
          Container(color: Colors.black,
              child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Image.asset('images/funktionsbild.png'),
          )),
          ListTile(
            leading: Icon(Icons.star),
            title: Text('Favoriter'),
            onTap: () {
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text('Settings'),
            onTap: () => null,
          ),
          ListTile(
            leading: Icon(Icons.person),
            title: Text('Kontaktinformation'),
            onTap: () => null,
          ),
          Divider(),
          ListTile(
            title: Text('Exit'),
            leading: Icon(Icons.exit_to_app),
            onTap: () => null,
          ),
        ],
      ),
    );
  }
}
// Image.asset('images/funktionsbild.png'),