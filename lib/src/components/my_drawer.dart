import 'package:app_stories/src/model/usuario_model.dart';
import 'package:app_stories/src/screens/home_page.dart';
import 'package:flutter/material.dart';

class MyDrawer extends StatelessWidget {
  final Usuario user;
  MyDrawer(this.user);

  @override
  Widget build(BuildContext context) {
    return new Drawer(
      child: Column(
        children: <Widget>[
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.black87, Colors.pink[300]],
              ),
            ),
            accountEmail: user != null
                ? Text(
                    user.user,
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18),
                  )
                : Text("Cargando..."),
            accountName: null,
            currentAccountPicture: CircleAvatar(
              backgroundImage: user != null
                  ? NetworkImage(user.urlImage)
                  : NetworkImage(
                      "https://e7.pngegg.com/pngimages/393/995/png-clipart-aspria-fitness-computer-icons-user-my-account-icon-miscellaneous-monochrome.png"),
            ),
          ),
          ListTile(
            title: Text(
              "Mis historias",
              style: new TextStyle(
                fontSize: 18,
              ),
            ),
            leading: Icon(
              Icons.book,
              color: Colors.purple,
            ),
            onTap: () {
              Navigator.pop(context);
              Navigator.of(context).pushNamed("/mystories",
                  arguments: UserArguments(user.user, ""));
            },
          ),
          ListTile(
            title: Text(
              "Cerrar Sesión",
              style: new TextStyle(
                fontSize: 18,
              ),
            ),
            leading: Icon(
              Icons.power_settings_new,
              color: Colors.cyan,
            ),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, "/");
            },
          ),
        ],
      ),
    );
  }
}
