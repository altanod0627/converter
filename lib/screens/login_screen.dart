import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:converter/core/core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

enum AuthMode { login, register }

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  String error = '';
  String verificationId = '';
  bool isLoading = false;
  AuthMode mode = AuthMode.login;
  bool obscure = true;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: FocusScope.of(context).unfocus,
      child: Scaffold(
        body: Form(
          key: formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(child: Text(mode == AuthMode.login ? 'Нэвтрэх' : 'Бүртгүүлэх', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 30))),
                Visibility(
                  visible: error.isNotEmpty,
                  child: MaterialBanner(
                    backgroundColor: Theme.of(context).colorScheme.error,
                    content: SelectableText(error),
                    actions: [
                      TextButton(
                        onPressed: () {
                          setState(() {
                            error = '';
                          });
                        },
                        child: const Text(
                          'Хаах',
                          style: TextStyle(color: Colors.white),
                        ),
                      )
                    ],
                    contentTextStyle: const TextStyle(color: Colors.white),
                    padding: const EdgeInsets.all(10),
                  ),
                ),
                const SizedBox(height: 20),
                Column(
                  children: [
                    if (mode == AuthMode.register) ...[
                      TextFormField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          hintText: 'Нэр',
                          border: OutlineInputBorder(),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                        ),
                        onChanged: (val) => setState(() {}),
                        validator: (value) {
                          if (value != null && value.isEmpty) {
                            return 'Заавал оруулах';
                          }

                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                    ],
                    TextFormField(
                      controller: emailController,
                      decoration: const InputDecoration(
                        hintText: 'И-мэйл',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 10),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      autofillHints: const [AutofillHints.email],
                      validator: (value) {
                        if (value != null && value.isEmpty) {
                          return 'Заавал оруулах';
                        } else if (!RegExp(r'^.+@[a-zA-Z]+\.[a-zA-Z]+(\.?[a-zA-Z]+)$').hasMatch(value!)) {
                          return 'Имэйл хаяг буруу байна';
                        }

                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: passwordController,
                      obscureText: obscure,
                      decoration: InputDecoration(
                        hintText: 'Нууц үг',
                        border: const OutlineInputBorder(),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                        suffixIcon: passwordController.text.isNotEmpty
                            ? IconButton(
                                onPressed: () {
                                  setState(() {
                                    obscure = !obscure;
                                  });
                                },
                                icon: Icon(Icons.remove_red_eye, color: obscure ? Colors.black : color.primaryColor),
                              )
                            : null,
                      ),
                      onChanged: (val) => setState(() {}),
                      validator: (value) {
                        if (value != null && value.isEmpty) {
                          return 'Заавал оруулах';
                        } else if (value!.length < 6) {
                          return 'Нууц үг багадаа 6 тэмдэгт байх ёстой';
                        }

                        return null;
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: isLoading ? 50 : double.infinity,
                  height: 50,
                  child: isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : ElevatedButton(
                          onPressed: () async {
                            if (formKey.currentState?.validate() ?? false) {
                              setState(() {
                                isLoading = true;
                              });
                              try {
                                if (mode == AuthMode.login) {
                                  await auth.signInWithEmailAndPassword(
                                    email: emailController.text,
                                    password: passwordController.text,
                                  );
                                } else if (mode == AuthMode.register) {
                                  var res = await auth.createUserWithEmailAndPassword(
                                    email: emailController.text,
                                    password: passwordController.text,
                                  );

                                  if (res.user != null) {
                                    res.user!.updateDisplayName(nameController.text);

                                    FirebaseFirestore.instance.collection('users').doc(res.user!.uid).set({
                                      'name': nameController.text,
                                      'email': emailController.text,
                                      'uid': res.user!.uid,
                                    });
                                  }
                                }
                              } on FirebaseAuthException catch (e) {
                                setState(() {
                                  error = '${e.message}';
                                });
                              } catch (e) {
                                setState(() {
                                  error = '$e';
                                });
                              } finally {
                                if (mounted) {
                                  setState(() {
                                    isLoading = false;
                                  });
                                }
                              }
                            }
                          },
                          child: Text(
                            mode == AuthMode.login ? 'Нэвтрэх' : 'Бүртгүүлэх',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton(
                    onPressed: () {
                      if (mode == AuthMode.register) {
                        mode = AuthMode.login;
                      } else {
                        mode = AuthMode.register;
                      }
                      error = '';
                      setState(() {});
                    },
                    child: Text(mode == AuthMode.login ? 'Бүртгүүлэх' : 'Нэвтрэх'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
