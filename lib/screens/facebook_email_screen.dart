

import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:googleapis/admob/v1.dart';


import '../utils/constants.dart';

class FacebookEmailScreen extends StatelessWidget {
   FacebookEmailScreen({super.key});
  final emailController=TextEditingController();
   final nameController=TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Facebook Email Screen',style: TextStyle(fontSize: 20),),


      ),
      body: Padding(
        padding: const EdgeInsets.all(27.0),
        child: Column(children:[
          SizedBox(height: 11,),
          TextField(
            controller: nameController,
            keyboardType: TextInputType.emailAddress,
            decoration: textFieldDecoration("Name", false),
          ),
          SizedBox(height: 11,),
          TextField(
            
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: textFieldDecoration("Email", false),
          ),
          SizedBox(height: 50,),
          SizedBox(
            width: double.infinity,
            height: 50.0,
            child: Container(
              decoration: BoxDecoration(boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: const Offset(
                      0, 3), // changes position of shadow
                )
              ]),
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).clearSnackBars();
                  // _validateFields();
                  if(nameController.text.trim().isEmpty){
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please provide a name!')));
                  return;
                  }else if(emailController.text.trim().isEmpty){
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please provide an email!')));
                  return;
                  }else if(!EmailValidator.validate(emailController.text.trim())){
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please provide a valid email!')));
                  }







               //   String uEmail = emailText.text;
                //  String uPassword = passwordText.text;

                  if (true) {
                //    mockProgressBar();
                //    callLoginApi(uEmail, uPassword);
                  } else {
                    showSnackbar(context, "Please input valid data.");
                  }
                },
                style: ButtonStyle(
                  backgroundColor:
                  MaterialStateProperty.all<Color>(Colors.blue),
                  shape: MaterialStateProperty.all<
                      RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                ),
                child: const Text("Submit",
                    style: TextStyle(
                      color: Colors.white,
                    )),
              ),
            ),
          ),
        ],),
      ),
    );
  }
}
