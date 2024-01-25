import 'package:flutter/material.dart';

Image logoWidget(String imageName) {
  return Image.asset(
    imageName,
    fit: BoxFit.fitWidth,
    width: 240,
    height: 240,
  );
}

TextField adminTextField(String text, TextEditingController controller) {
  return TextField(
    controller: controller,
    cursorColor: Colors.white,
    style: TextStyle(
      color: Colors.white.withOpacity(0.9),
    ),
    decoration: InputDecoration(
      labelText: text,
      labelStyle: const TextStyle(
        color: Color(0xFF9B9B9B),
      ),
      // Define the appearance of the underline when the TextField is in focus
      focusedBorder: const UnderlineInputBorder(
        borderSide: BorderSide(
          color: Color(0xFF9B9B9B),
        ),
      ),
      // Define the appearance of the underline when the TextField is enabled but not in focus
      enabledBorder: const UnderlineInputBorder(
        borderSide: BorderSide(
          color: Color(0xFF9B9B9B),
        ),
      ),
      // Define the appearance of the underline when the TextField is disabled
      border: const UnderlineInputBorder(
        borderSide: BorderSide(
          color: Color(0xFF9B9B9B),
        ),
      ),
      // Add padding to the top and bottom of the content inside the TextField
      contentPadding: const EdgeInsets.symmetric(vertical: 5.0),
    ),
    keyboardType: TextInputType.emailAddress,
  );
}

TextField numberTextField(String text, TextEditingController controller) {
  return TextField(
    controller: controller,
    cursorColor: Colors.white,
    style: TextStyle(
      color: Colors.white.withOpacity(0.9),
    ),
    decoration: InputDecoration(
      labelText: text,
      labelStyle: const TextStyle(
        color: Color(0xFF9B9B9B),
      ),
      // Define the appearance of the underline when the TextField is in focus
      focusedBorder: const UnderlineInputBorder(
        borderSide: BorderSide(
          color: Color(0xFF9B9B9B),
        ),
      ),
      // Define the appearance of the underline when the TextField is enabled but not in focus
      enabledBorder: const UnderlineInputBorder(
        borderSide: BorderSide(
          color: Color(0xFF9B9B9B),
        ),
      ),
      // Define the appearance of the underline when the TextField is disabled
      border: const UnderlineInputBorder(
        borderSide: BorderSide(
          color: Color(0xFF9B9B9B),
        ),
      ),
      // Add padding to the top and bottom of the content inside the TextField
      contentPadding: const EdgeInsets.symmetric(vertical: 5.0),
    ),
    keyboardType: TextInputType.number,
  );
}

TextField reusableTextField(String text, IconData icon, bool isPasswordType,
    TextEditingController controller) {
  return TextField(
    controller: controller,
    obscureText: isPasswordType,
    enableSuggestions: !isPasswordType,
    autocorrect: !isPasswordType,
    cursorColor: Colors.white,
    style: TextStyle(
      color: Colors.white.withOpacity(0.9),
    ),
    decoration: InputDecoration(
      prefixIcon: Icon(
        icon,
        color: Colors.white70,
      ),
      labelText: text,
      labelStyle: const TextStyle(
        color: Color(0xFF9B9B9B),
      ),
      // Define the appearance of the underline when the TextField is in focus
      focusedBorder: const UnderlineInputBorder(
        borderSide: BorderSide(
          color: Color(0xFF9B9B9B),
        ),
      ),
      // Define the appearance of the underline when the TextField is enabled but not in focus
      enabledBorder: const UnderlineInputBorder(
        borderSide: BorderSide(
          color: Color(0xFF9B9B9B),
        ),
      ),
      // Define the appearance of the underline when the TextField is disabled
      border: const UnderlineInputBorder(
        borderSide: BorderSide(
          color: Color(0xFF9B9B9B),
        ),
      ),
      // Add padding to the top and bottom of the content inside the TextField
      contentPadding: const EdgeInsets.symmetric(vertical: 5.0),
    ),
    keyboardType: isPasswordType
        ? TextInputType.visiblePassword
        : TextInputType.emailAddress,
  );
}

Container firebaseButton(BuildContext context, String title, Function onTap) {
  return Container(
    width: MediaQuery.of(context).size.width,
    height: 50,
    margin: const EdgeInsets.fromLTRB(0, 10, 0, 20),
    decoration: BoxDecoration(borderRadius: BorderRadius.circular(90)),
    child: ElevatedButton(
      onPressed: () {
        onTap();
      },
      style: ButtonStyle(
          backgroundColor: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.pressed)) {
              return Colors.black26;
            }
            return Colors.grey[300];
          }),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)))),
      child: Text(
        title,
        style: const TextStyle(
            color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 16),
      ),
    ),
  );
}
