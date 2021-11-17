import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/services.dart';
import 'home_view.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../authenticate.dart';
import '../driver.dart';
import 'register_view.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);
  @override
  State<LoginPage> createState() => _LoginState();
}

class _LoginState extends State<LoginPage> with WidgetsBindingObserver {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _emailController,
      _passwordController,
      _phoneNumberController;

  late String _link;

  get model => null;

  @override
  void initState() {
    WidgetsBinding.instance!.addObserver(this);

    super.initState();
    this.initDynamicLinks();

    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _phoneNumberController = TextEditingController();
  }

  void initDynamicLinks() async {
    FirebaseDynamicLinks.instance.onLink(
        onSuccess: (PendingDynamicLinkData? dynamicLink) async {
      final Uri? deepLink = dynamicLink?.link;

      if (deepLink != null) {
        print("dd${deepLink.toString()}");
        _signInWithEmailAndLink(deepLink.toString());
      }
    }, onError: (OnLinkErrorException e) async {
      print('onLinkError');
      print(e.message);
    });

    final PendingDynamicLinkData? data =
        await FirebaseDynamicLinks.instance.getInitialLink();
    final Uri? deepLink = data?.link;

    if (deepLink != null) {
      setState(() {
        print("dzzzd${deepLink.toString()}");

        _link = deepLink.toString();

        _signInWithEmailAndLink(deepLink.toString());
      });
      //  Navigator.pushNamed(context, deepLink.path);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      initDynamicLinks();
    }
  }

  Future<void> _signInWithEmailAndLink(String dd) async {
    print("ddddddddd$dd ");

    final FirebaseAuth user = FirebaseAuth.instance;
    bool validLink = await user.isSignInWithEmailLink(dd);
    if (validLink) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? mail = await prefs.getString("mail");
      try {
        print("link$dd ");
        print("email$mail ");

        final User =
            await user.signInWithEmailLink(email: mail!, emailLink: dd);
        if (User != null)
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => HomePage()));
      } catch (e) {
        print(e);
        print(e.toString());
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _phoneNumberController.dispose();
    super.dispose();
  }

  bool _loading = false;
  String _email = "";
  String _password = "";
  String _phone = "";

  @override
  Widget build(BuildContext context) {
    final emailInput = TextFormField(
      autocorrect: false,
      controller: _emailController,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter some text';
        }
        return null;
      },
      decoration: const InputDecoration(
          labelText: "Email Address",
          border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(10.0))),
          hintText: 'Enter Email'),
    );

    final passwordInput = TextFormField(
      autocorrect: false,
      controller: _passwordController,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Enter Password';
        }
        return null;
      },
      obscureText: true,
      decoration: const InputDecoration(
        labelText: "Password",
        border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10.0))),
        hintText: 'Enter Password',
        suffixIcon: Padding(
          padding: EdgeInsets.all(15), // add padding to adjust icon
          child: Icon(Icons.lock),
        ),
      ),
    );

    final submitButton = OutlinedButton(
      onPressed: () {
        if (_formKey.currentState!.validate()) {
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text('Processing Data')));
          _email = _emailController.text;
          _password = _passwordController.text;

          _emailController.clear();
          _passwordController.clear();

          setState(() {
            _loading = true;
            Authenticate()
                .signInWithEmailAndPassword(_email, _password, context);
          });
        }
      },
      child: const Text('Submit'),
    );

    final registerButton = Container(
        width: 250.0,
        child: OutlinedButton(
          onPressed: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (con) => const RegisterPage()));
          },
          child: const Text('Don\'t Have an Account? '),
        ));

    final google = CircleAvatar(
      radius: 27,
      backgroundColor: Colors.black,
      child: CircleAvatar(
        radius: 25,
        backgroundColor: Colors.white,
        child: IconButton(
            icon: Image.asset(
              'assets/googleicon.png',
              height: 20,
              width: 20,
            ),
            onPressed: () {
              Authenticate().googleSignIn(context);
            }),
      ),
    );

    final facebook = CircleAvatar(
      radius: 27,
      backgroundColor: Colors.black,
      child: CircleAvatar(
        radius: 25,
        backgroundColor: Colors.white,
        child: IconButton(
            icon: Image.asset(
              'assets/facebook.png',
              height: 20,
              width: 20,
            ),
            onPressed: () {
              Authenticate().facebookSignIn(context);
            }),
      ),
    );

    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Scaffold(
        appBar: AppBar(
          title: Text("Login"),
        ),
        body: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Form(
                    key: _formKey,
                    child: Column(
                      children: <Widget>[
                        emailInput,
                        passwordInput,
                        submitButton,
                        SizedBox(height: 15),
                        registerButton,
                      ],
                    ),
                  ),
                  Form(
                    child: Row(
                      children: <Widget>[
                        SizedBox(height: 100),
                        SizedBox(width: 115),
                        google,
                        SizedBox(width: 30),
                        facebook
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // This trailing comma makes auto-formatting nicer for build methods.
          ),
        ),
      ),
    );
  }

  Future<bool> _onBackPressed() async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Confirm'),
          content: Text('Do you want to exit the App'),
          actions: <Widget>[
            FlatButton(
              child: Text('No'),
              onPressed: () {
                Navigator.of(context).pop(false); //Will not exit the App
              },
            ),
            FlatButton(
              child: Text('Yes'),
              onPressed: () {
                SystemNavigator.pop(); //Will exit the App
              },
            )
          ],
        );
      },
    );
    return false;
  }
}
