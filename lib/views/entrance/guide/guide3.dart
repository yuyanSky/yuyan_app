import 'package:flutter/material.dart';
import 'package:yuyan_app/util/styles/app_ui.dart';

class Guide3 extends StatefulWidget {
  Guide3({Key? key}) : super(key: key);

  @override
  _Guide3State createState() => _Guide3State();
}

class _Guide3State extends State<Guide3> {
  int? onPressedTimes;

  @override
  void initState() {
    super.initState();
    onPressedTimes = 0;
  }

  goLogin() {
    print(onPressedTimes);
    setState(() {
      onPressedTimes = onPressedTimes! + 1;
    });
    if (onPressedTimes! <= 2) {
      Navigator.of(context).pushNamed("/login");
    } else {
      return () {};
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.pink,
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      child: Stack(
        children: <Widget>[
          Positioned(
            child: Container(
              decoration: BoxDecoration(
                color: Color.fromRGBO(235, 169, 209, 1),
              ),
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
              ),
            ),
          ),
          Positioned(
            child: Center(
              child: Container(
                margin: EdgeInsets.only(bottom: 120),
                width: MediaQuery.of(context).size.width * 0.6,
                child: Image.asset(
                  'assets/images/guide/guide3.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Positioned(
            child: Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: EdgeInsets.only(left: 40, top: 90),
                child: Text(
                  "梦想".split("").join("\n"),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontFamily: "Silom",
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            child: Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: EdgeInsets.only(right: 40, bottom: 90),
                child: Text(
                  "一起-飞往-梦想".split("").join("\n"),
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: "Silom",
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            child: Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: EdgeInsets.only(right: 60, bottom: 90),
                child: Text(
                  "╹╹✈·2021".split("").join("\n"),
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: "Silom",
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: MediaQuery.of(context).size.height * 0.21,
            child: Container(
              margin: EdgeInsets.only(
                  left: MediaQuery.of(context).size.width * 0.25),
              width: MediaQuery.of(context).size.width * 0.50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.yellow.withOpacity(0.8),
                borderRadius: BorderRadius.all(Radius.circular(30)),
              ),
              child: TextButton(
                onPressed: goLogin,
                child: Text(
                  "使用语雀登录",
                  style: TextStyle(
                    color: AppColors.accentText,
                    fontFamily: "sans_bold",
                    fontWeight: FontWeight.w500,
                    fontSize: 15,
                    letterSpacing: 2,
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
