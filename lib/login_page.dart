import 'package:flutter/material.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Login Page"),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text("Login",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.orange
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 30),
            child: Form(child:
            Column(
              children: [
                TextFormField(
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: "Username",
                    hintText: 'Enter Username',
                    prefixIcon: Icon(Icons.person),
                    border: OutlineInputBorder()
                  ),
                  onChanged: (String value) {
                  },
                  validator: (value){
                    return value!.isEmpty ? 'Please Enter your username': null;
                  },
                ),
                SizedBox(height: 20,),
                TextFormField(
                  keyboardType: TextInputType.visiblePassword,
                  decoration: InputDecoration(
                      labelText: "Password",
                      hintText: 'Enter Password',
                      prefixIcon: Icon(Icons.password),
                      border: OutlineInputBorder()
                  ),
                  onChanged: (String value) {
                  },
                  validator: (value){
                    return value!.isEmpty ? 'Please Enter your Password': null;
                  },
                ),

                SizedBox(height: 30,),

                ElevatedButton(
                    onPressed: () {},
                    child: Text("Login",
                      style: TextStyle(color: Colors.black,
                      ),
                    ),
                ),
              ],
            ),
            ),
          ),
        ],
      ),
    );
  }
}
