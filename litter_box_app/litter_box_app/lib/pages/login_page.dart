import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_page.dart';

class LoginPage extends StatefulWidget {
  final String type;

  LoginPage({super.key, required this.type});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Local state variable to manage the type
  late String currentType;

  // text controller
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    currentType = widget.type;
    _checkLoginStatus();
  }

  // Check if the user is already logged in
  void _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    if (isLoggedIn && mounted) {
      // Navigate to the home screen or wherever you want
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    }
  }

  // login or register method
  void loginOrRegister() {
    // show a loading circle
    showDialog(
      context: context,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    if (currentType == "LOGIN") {
      login(); // LOGIN
    } else {
      register(); // REGISTER
    }
  }

  void login() async {
    // try sign in
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailController.text, password: passwordController.text);

      //pop loading circle
      if (mounted) Navigator.pop(context);

      // On successful login, save the login state
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setBool('isLoggedIn', true);

      // Navigate to the home screen or wherever you want
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
      }
    } on FirebaseAuthException catch (e) {
      // pop loading circle
      if (mounted) Navigator.pop(context);
      displayMessageToUser(e.code);
    }
  }

  void register() async {
    // make sure password match
    if (passwordController.text != confirmPasswordController.text) {
      // pop loading circle
      if (mounted) Navigator.pop(context);

      // show error message to user
      displayMessageToUser("Passwords don't match");
    } else {
      // try creating the user
      try {
        // create the user
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: emailController.text, password: passwordController.text);

        // pop loading circle
        if (mounted) Navigator.pop(context);

        // login after successfully created
        login();
      } on FirebaseAuthException catch (e) {
        // pop loading circle
        if (mounted) Navigator.pop(context);

        // display error message to the user
        displayMessageToUser(e.code);
      }
    }
  }

  void displayMessageToUser(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(message),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(25),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 150),
              // logo
              Icon(
                Icons.pets,
                size: 80,
                color: Theme.of(context).colorScheme.inversePrimary,
              ),
              const SizedBox(height: 25),
              // App name
              Text(
                "L I T T E R  B O X",
                style: TextStyle(fontSize: 20),
              ),
              const SizedBox(height: 50),
              // email
              MyTextField(
                hintText: "Email",
                obsecureText: false,
                controller: emailController,
              ),
              const SizedBox(height: 10),
              // password
              MyTextField(
                hintText: "Password",
                obsecureText: true,
                controller: passwordController,
              ),
              const SizedBox(height: 10),
              if (currentType == "REGISTER")
                MyTextField(
                  hintText: "Confirm Password",
                  obsecureText: true,
                  controller: confirmPasswordController,
                ),
              const SizedBox(height: 10),
              // forgot password
              if (currentType == "LOGIN")
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      "Forgot password",
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.secondary),
                    ),
                  ],
                ),
              const SizedBox(height: 25),
              // sign in button
              MyButton(onTap: loginOrRegister, text: currentType),
              const SizedBox(height: 20),
              // register
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        currentType = currentType == "REGISTER" ? "LOGIN" : "REGISTER";
                      });
                    },
                    child: Text(
                      currentType == "REGISTER"
                          ? "login to existing account"
                          : "register new account",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MyTextField extends StatelessWidget {
  final String hintText;
  final bool obsecureText;
  final TextEditingController controller;

  const MyTextField({
    super.key,
    required this.hintText,
    required this.obsecureText,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        hintText: hintText,
      ),
      obscureText: obsecureText,
    );
  }
}

class MyButton extends StatelessWidget {
  final String text;
  final void Function()? onTap;

  const MyButton({super.key, required this.onTap, required this.text});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(12),
        ),
        padding: EdgeInsets.all(25),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}
