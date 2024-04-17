import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => LoginState();
}

class LoginState extends State<Login> {
  bool _rememberMe = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Image(
                image: const AssetImage('assets/LiTec_logo.webp'),
                width: MediaQuery.of(context).size.width / 2),
            const Spacer(),
            Text('Lires', style: Theme.of(context).textTheme.headlineLarge),
            const Text(
                "LiTec Raumreservierungs und Veranstaltungsverwaltungsystem"),
            const SizedBox(height: 20),
            ElevatedButton(
                onPressed: () {}, child: const Text('Login mit Microsoft')),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Checkbox(
                    value: _rememberMe,
                    onChanged: (value) {
                      setState(() {
                        _rememberMe = value!;
                      });
                    }),
                const Text('Login speichern'),
              ],
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
