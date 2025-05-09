import 'package:flutter/material.dart';
import 'package:dialogflow_grpc/dialogflow_grpc.dart';
import 'package:dialogflow_grpc/generated/google/cloud/dialogflow/v2beta1/session.pb.dart';
import 'package:flutter/services.dart' show rootBundle;

class ChatBotScreen extends StatefulWidget {
  @override
  _ChatBotScreenState createState() => _ChatBotScreenState();
}

class _ChatBotScreenState extends State<ChatBotScreen> {
  final List<ChatMessage> _messages = [];
  final TextEditingController _controller = TextEditingController();

  // Configuração do Dialogflow
  Future<DialogflowGrpcV2Beta1> _setupDialogflow() async {
    final jsonString = await rootBundle.loadString(
      'assets/positive-leaf-459218-i6-fcae8cbf1016.json',
    );
    final serviceAccount = ServiceAccount.fromString(jsonString);
    return DialogflowGrpcV2Beta1.viaServiceAccount(serviceAccount);
  }

  void _sendMessage(String text) async {
    _controller.clear();
    final df = await _setupDialogflow();
    final response = await df.detectIntent(text, 'pt-BR');

    setState(() {
      _messages.add(ChatMessage(text: text, isUser: true));
      _messages.add(ChatMessage(text: response.text, isUser: false));
    });
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
      margin: EdgeInsets.symmetric(vertical: 5),
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isUser ? Colors.blue[100] : Colors.grey[200],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(text),
      ),
    );
  }
}
