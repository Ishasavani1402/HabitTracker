import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../database/DB_helper.dart';
import 'HomeScreen.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginnState();
}

class _LoginnState extends State<Login> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;
  DB_helper? dbref;


  @override
  void initState(){
    super.initState();
    dbref = DB_helper.getInstance;
  }


  Future<void> loginuser()async{
    String email =  _emailController.text.trim();
    String password =  _passwordController.text.trim();

    if(email.isEmpty || password.isEmpty){
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Please fill all the fields")));
      return;
    }

    List<Map<String, dynamic>>? user = await dbref!.getuser(email);

    if (user != null ) {
      // Store email in SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_email', email);

      print("sharepref email : ${prefs.getString('user_email')}");

      // Navigate to Homescreen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Homescreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Invalid email or password")),
      );
    }
    // bool success = await
    // dbref!.adduser(email: email, password: password);
    // print("email : $email");
    // print("password : $password");
    //
    // if(success){
    //   Navigator.pushReplacement(context, MaterialPageRoute(builder:
    //       (context)=> Homescreen()));
    // }else{
    //   ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to register user")));
    // }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: loginuser,
              child: const Text('Register'),
            ),
          ],
        ),
      ),
    );
  }
}
