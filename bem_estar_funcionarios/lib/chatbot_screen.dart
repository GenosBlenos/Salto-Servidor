import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:googleapis_auth/auth_io.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:provider/provider.dart';

class ChatBotScreen extends StatefulWidget {
  const ChatBotScreen({super.key});

  @override
  _ChatBotScreenState createState() => _ChatBotScreenState();
}

class _ChatBotScreenState extends State<ChatBotScreen> {
  final List<ChatMessage> _messages = [];
  final TextEditingController _controller = TextEditingController();
  String? _accessToken;

  @override
  void initState() {
    super.initState();
    _initializeAuth();
  }

  // Carrega a chave JSON e obtém o token de acesso
  Future<void> _initializeAuth() async {
    final jsonString = await rootBundle.loadString('assets/positive-leaf-459218-i6-fcae8cbf1016.json');
    final jsonData = json.decode(jsonString);
    
    final credentials = ServiceAccountCredentials.fromJson(jsonData);
    final scopes = ['https://www.googleapis.com/auth/cloud-platform'];
    
    final authClient = await clientViaServiceAccount(credentials, scopes);
    setState(() {
      _accessToken = authClient.credentials.accessToken.data;
    });
  }
  // Envia mensagem para o Dialogflow
  Future<void> _sendMessage(String text) async {
    if (_accessToken == null || text.isEmpty) return;

    _controller.clear();
    setState(() {
      _messages.add(ChatMessage(text: text, isUser: true));
    });

    try {
      final response = await http.post(
        Uri.parse(
          'https://dialogflow.googleapis.com/v2/projects/positive-leaf-459218-i6/agent/sessions/123:detectIntent',
        ),
        headers: {
          'Authorization': 'Bearer $_accessToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'queryInput': {
            'text': {
              'text': text,
              'languageCode': 'pt-BR',
            }
          }
        }),
      );

      final responseData = json.decode(response.body);
      final botReply = responseData['queryResult']['fulfillmentText'] ?? 'Não entendi.';

      setState(() {
        _messages.add(ChatMessage(text: botReply, isUser: false));
      });
    } catch (e) {
      setState(() {
        _messages.add(ChatMessage(text: 'Erro ao conectar ao servidor.', isUser: false));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Assistente Virtual')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (ctx, i) => _messages[i],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Digite sua mensagem...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () => _sendMessage(_controller.text),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ChatMessage extends StatelessWidget {
  final String text;
  final bool isUser;

  ChatMessage({required this.text, required this.isUser});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isUser ? Colors.blue[100] : Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          text,
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}