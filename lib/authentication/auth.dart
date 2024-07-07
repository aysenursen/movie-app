import 'package:flutter/material.dart';
import '../utilities/constants.dart';
import 'login_page.dart';
import 'signup_page.dart';

class Auth extends StatefulWidget {
  const Auth({super.key});

  @override
  State<Auth> createState() => _AuthState();
}

class _AuthState extends State<Auth> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Color(0xff31373D),
        appBar: AppBar(
          elevation: 0,
          toolbarHeight: 140,
          backgroundColor: Color(0xffFFD233),
          title: Column(
            children: [
              Center(
                child: Text(
                  'MOVIE BOX',
                  style: ConstantsStyle.headingBoldBlack,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 60, left: 60, top: 20),
                child: Divider(
                  color: Colors.black,
                  thickness: 1,
                ),
              )
            ],
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(30),
            ),
          ),
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: Colors.black,
            dividerColor: ConstantsColor.backgroundColor,
            tabs: [
              Tab(
                child: Text(
                  'Giriş Yap',
                  style: ConstantsStyle.primaryStyle,
                ),
              ),
              Tab(
                child: Text(
                  'Üye Ol',
                  style: ConstantsStyle.primaryStyle,
                ),
              ),
            ],
          ),
        ),
        body: Padding(
          padding: EdgeInsets.all(12),
          child: Column(
            children: [
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    Giris(),
                    Kayit(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
