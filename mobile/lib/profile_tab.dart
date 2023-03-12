import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:mobile/model/user_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobile/login_page.dart';

import 'model/app_state_model.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() {
    return _ProfileTabState();
  }
}

class _ProfileTabState extends State<ProfileTab> {
  late String? bearer;

  void initState() {
    super.initState();
    userData();
  }
  void userData() async {
    final prefs = await SharedPreferences.getInstance();
    String? prefsBearer = prefs.getString('bearerToken');
    if (prefsBearer != null) {
      bearer = prefsBearer;
    } else {
      bearer = '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text("Profile"),
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: ListView(
            children: [
              bearer == '' ?
              CupertinoButton.filled(
                child: Text("Log in"), 
                onPressed: () {
                  Navigator.push(
                    context,
                    CupertinoPageRoute(
                      builder: (context) => LoginPage()
                    )
                  );
                })
              : CupertinoButton.filled(
                child: Text("Log out"), 
                onPressed: () {
                  UserRepository.logoutUser(); 
                  setState((){});
                  }
              )
            ],
          ),
        
        ),
      )
    );
  }
}
