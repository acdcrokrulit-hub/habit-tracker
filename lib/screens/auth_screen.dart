import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/habit_provider.dart';

class AuthScreen extends StatefulWidget {
  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLogin = true;
  String? _errorMessage;
  bool _emailSent = false;
  bool _isLoading = false;
  bool _showResendOption = false;

  Future<void> _handleAuth() async {
    if (_isLoading) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _showResendOption = false;
    });
    try {
      if (_isLogin) {
        await Provider.of<HabitProvider>(context, listen: false)
            .signIn(_emailController.text, _passwordController.text);
      } else {
        await Provider.of<HabitProvider>(context, listen: false)
            .signUp(_emailController.text, _passwordController.text);
        setState(() => _emailSent = true);
      }
    } catch (e) {
      final errorStr = e.toString();
      setState(() {
        _errorMessage = errorStr;
        // Show resend option if email not confirmed
        _showResendOption = errorStr.contains('Email не подтвержден') ||
            errorStr.contains('Email not confirmed') ||
            errorStr.contains('not been confirmed');
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _resendEmail() async {
    try {
      await Provider.of<HabitProvider>(context, listen: false)
          .resendConfirmation(_emailController.text);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Письмо подтверждения отправлено повторно')),
      );
      setState(() => _errorMessage = null);
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isLogin ? 'Вход' : 'Регистрация')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_emailSent)
              Column(
                children: [
                  Text(
                      'Письмо подтверждения отправлено на ${_emailController.text}',
                      textAlign: TextAlign.center),
                  TextButton(
                    onPressed: _resendEmail,
                    child: Text('Отправить повторно'),
                  ),
                  SizedBox(height: 20),
                ],
              ),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Пароль'),
              obscureText: true,
            ),
            if (_errorMessage != null)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red.withOpacity(0.3)),
                ),
                child: Column(
                  children: [
                    Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                    if (_showResendOption && _isLogin) ...[
                      const SizedBox(height: 8),
                      TextButton.icon(
                        onPressed: _resendEmail,
                        icon: const Icon(Icons.email_outlined, size: 16),
                        label: const Text(
                            'Отправить письмо подтверждения повторно'),
                      ),
                    ],
                  ],
                ),
              ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _handleAuth,
              child: Text(_isLogin ? 'Войти' : 'Зарегистрироваться'),
            ),
            TextButton(
              onPressed: () => setState(() {
                _isLogin = !_isLogin;
                _errorMessage = null;
                _emailSent = false;
              }),
              child: Text(_isLogin ? 'Создать аккаунт' : 'Уже есть аккаунт?'),
            ),
          ],
        ),
      ),
    );
  }
}
