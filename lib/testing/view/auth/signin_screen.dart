import 'package:demo_tester/central_screen.dart';
import 'package:demo_tester/testing/controller/provider/user_provider.dart';
import 'package:demo_tester/testing/model/mysql.dart';
import 'package:demo_tester/testing/view/auth/registration_screen.dart';
import 'package:demo_tester/testing/view/display_screen.dart';
import 'package:flutter/material.dart';
import 'package:mysql1/mysql1.dart';
import 'package:provider/provider.dart';

class SigninScreen extends StatefulWidget {
  const SigninScreen({Key? key}) : super(key: key);

  @override
  State<SigninScreen> createState() => _SigninScreenState();
}

class _SigninScreenState extends State<SigninScreen> {
  bool _isPasswordVisible = false;
  bool _rememberMe = false;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  //login function
  Future<int?> login(String userName, String password) async {
    try {
      MySqlConnection connection = await Mysql().connection;

      var results = await connection.query(
          'select id from hallo.DEMO where fname = ? and lname = ?',
          [userName, password]);
      if (results.isNotEmpty) {
        return results.first['id'] as int;
      } else {
        return null;
      }
    } catch (e) {
      print('Error logging in: $e');
      return null;
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
                        "Enter your email and password to continue.",
                        style: Theme.of(context).textTheme.caption,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    _gap(),
                    TextFormField(
                      controller: _emailController,
                      // validator: (value) {
                      //   // add email validation
                      //   if (value == null || value.isEmpty) {
                      //     return 'Please enter some text';
                      //   }
                      //
                      //   bool emailValid = RegExp(
                      //           r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                      //       .hasMatch(value);
                      //   if (!emailValid) {
                      //     return 'Please enter a valid email';
                      //   }
                      //
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
                    CheckboxListTile(
                      value: _rememberMe,
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() {
                          _rememberMe = value;
                        });
                      },
                      title: const Text('Remember me'),
                      controlAffinity: ListTileControlAffinity.leading,
                      dense: true,
                      contentPadding: const EdgeInsets.all(0),
                    ),
                    _gap(),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4)),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.all(10.0),
                          child: Text(
                            'Sign in',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                        onPressed: () async {
                          if (_formKey.currentState?.validate() ?? false) {
                            int? userId = await login(_emailController.text,
                                _passwordController.text);
                            if (userId != null) {
                              ///store userid in provider
                              Provider.of<UserProvider>(context, listen: false)
                                  .setUserId(userId);

                              /// do something
                              /// navigate to next screen
                              Navigator.pushReplacement(context,
                                  MaterialPageRoute(builder: ((context) {
                                return const CentralScreen();
                              })));
                            } else {
                              showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                        title: const Text('Login Failed'),
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
                            'Back to Register',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        onPressed: () {
                          Navigator.pushReplacement(context,
                              MaterialPageRoute(builder: ((context) {
                            return const RegistrationScreen();
                          })));
                        },
                      ),
                    )
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
