import 'package:demo_tester/testing/model/mysql.dart';
import 'package:demo_tester/testing/view/auth/signin_screen.dart';
import 'package:flutter/material.dart';
import 'package:mysql1/mysql1.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  bool _isPasswordVisible = false;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  //registration functionality
  Future<String> register(
      String userName, String password, String address) async {
    try {
      MySqlConnection connection = await Mysql().connection;

      await connection.query(
          'insert into hallo.DEMO(fname,lname,address) values (?,?,?)',
          [userName, password, address]);
      return 'Registered Sucessfull';
    } catch (e) {
      print('Error with registration: $e');
      return 'Error registering';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: _formKey,
        child: Center(
          child: Card(
            elevation: 8,
            child: Container(
              padding: const EdgeInsets.all(32.0),
              constraints: const BoxConstraints(maxWidth: 350),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const FlutterLogo(size: 100),
                    _gap(),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        "Welcome to Grupee!",
                        style: Theme.of(context).textTheme.headline5,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        "Enter your information to continue.",
                        style: Theme.of(context).textTheme.caption,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    _gap(),
                    TextFormField(
                      controller: _emailController,
                      // validator: (value){
                      //   //add email validation
                      //   if(value == null || value.isEmpty){
                      //     return 'Please enter some text';
                      //   }
                      //   bool emailValid =  RegExp(
                      //                 r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(value);
                      //   if(!emailValid){
                      //     return 'Please enter a valid email';
                      //   }
                      //   return null;
                      // },
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        hintText: 'Enter your email',
                        prefixIcon: Icon(Icons.email_outlined),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    _gap(),
                    TextFormField(
                      controller: _passwordController,
                      // validator: (value) {
                      //   if (value == null || value.isEmpty) {
                      //     return 'Please enter some text';
                      //   }
                      //
                      //   if (value.length < 6) {
                      //     return 'Password must be at least 6 characters';
                      //   }
                      //   return null;
                      // },
                      obscureText: !_isPasswordVisible,
                      decoration: InputDecoration(
                          labelText: 'Password',
                          hintText: 'Enter your password',
                          prefixIcon: const Icon(Icons.lock_outline_rounded),
                          border: const OutlineInputBorder(),
                          suffixIcon: IconButton(
                            icon: Icon(_isPasswordVisible
                                ? Icons.visibility_off
                                : Icons.visibility),
                            onPressed: () {
                              setState(() {
                                _isPasswordVisible = !_isPasswordVisible;
                              });
                            },
                          )),
                    ),
                    _gap(),
                    TextFormField(
                      controller: _addressController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter some text';
                        }
                        bool countryValid =
                            RegExp("^[A-Za-z]+").hasMatch(value);
                        if (!countryValid) {
                          return 'Please enter correct country';
                        }
                        return null;
                      },
                      decoration: const InputDecoration(
                        labelText: 'Country',
                        hintText: 'Enter your country',
                        prefixIcon: Icon(Icons.add_location_alt_rounded),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    _gap(),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        )),
                        child: const Padding(
                          padding: EdgeInsets.all(10.0),
                          child: Text(
                            'Register',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        onPressed: () async {
                          if (_formKey.currentState?.validate() ?? false) {
                            String result = await register(
                                _emailController.text,
                                _passwordController.text,
                                _addressController.text);
                            _emailController.clear();
                            _passwordController.clear();
                            _addressController.clear();
                            showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                      title: const Text('Success'),
                                      content: Text(result),
                                      actions: [
                                        TextButton(
                                            onPressed: () =>
                                                Navigator.of(context).pop(),
                                            child: const Text('OK'))
                                      ],
                                    ));
                            // Navigator.pushReplacement(context,
                            //     MaterialPageRoute(builder: ((context) {
                            //   return const SigninScreen();
                            // })));
                          } else {
                            showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                      title: const Text('Registration Failed'),
                                      content: const Text(
                                          'Invalid username or password'),
                                      actions: [
                                        TextButton(
                                            onPressed: () =>
                                                Navigator.of(context).pop(),
                                            child: const Text('OK'))
                                      ],
                                    ));
                          }
                        },
                      ),
                    ),
                    _gap(),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        )),
                        child: const Padding(
                          padding: EdgeInsets.all(10.0),
                          child: Text(
                            'Back to Login',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        onPressed: () {
                          Navigator.pushReplacement(context,
                              MaterialPageRoute(builder: ((context) {
                            return const SigninScreen();
                          })));
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _gap() => const SizedBox(height: 16);
}
