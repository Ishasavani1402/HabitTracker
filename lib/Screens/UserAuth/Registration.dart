  import 'package:flutter/material.dart';
import 'package:habittracker/Screens/UserAuth/Login.dart';
  import 'package:shared_preferences/shared_preferences.dart';

  import '../../database/DB_helper.dart';
  import '../BottomNavbar/HomeScreen.dart';

  class Registration extends StatefulWidget {
    const Registration({super.key});

    @override
    State<Registration> createState() => _RegistationState();
  }

  class _RegistationState extends State<Registration> {
    final TextEditingController _usernameController = TextEditingController();
    final TextEditingController _emailController = TextEditingController();
    final TextEditingController _passwordController = TextEditingController();
    bool _obscurePassword = false;
    DB_helper? dbref;


    @override
    void initState(){
      super.initState();
      dbref = DB_helper.getInstance;
    }


    Future<void> registeruser()async{
      String username =  _usernameController.text.trim();
      String email =  _emailController.text.trim();
      String password =  _passwordController.text.trim();

      if(username.isEmpty || email.isEmpty || password.isEmpty){
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Please fill all the fields")));
        return;
      }

      try {
        List<Map<String, dynamic>>? user = await dbref!.getuser(email);

        if (user.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text("User with this email already exists")),
          );
          return;
        }

        //add user in databse
        bool success = await dbref!.adduser(username : username , email: email, password: password);
        if (success) {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('user_email', email);
          await prefs.setString("username", username);

          print("sharepref email : ${prefs.getString('user_email')}");
          print("sharepref username : ${prefs.getString('username')}");

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const Homescreen()),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Failed to register user")),
          );
        }
      }catch(e){
        print("register Error : $e");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to register user")),
        );
      }


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
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
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
                onPressed: registeruser,
                child: const Text('Register'),
              ),
              const SizedBox(height: 8),

              TextButton(onPressed: (){
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> Login()));
              }, child: Text("Already have an account ? Login"))

                ],
          ),
        )
      );
    }
  }
