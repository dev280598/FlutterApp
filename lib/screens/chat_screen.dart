import 'package:flutter/material.dart';
import 'package:flutter_app/controller/main_controller.dart';
import 'package:flutter_app/screens/widget/chat_message_widget.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _name = 'Dai Lee';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State createState() => ChatScreenState();
}

class ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  late Future<List<ChatMessage>> _messages;

  final TextEditingController _textController = TextEditingController();

  late ScrollController _controller;
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  late MainController mainController;

  @override
  void initState() {
    super.initState();

    mainController = Get.find();
    _messages = _prefs.then((msg) {
      final messageCached = msg.getStringList('message_prefs') ?? [];

      debugPrint('messageCached $messageCached');

      if (messageCached.isNotEmpty) {
        mainController.listMess.value = messageCached.map((e) {
          final message = ChatMessage(
            text: e,
            animationController: AnimationController(
              duration: const Duration(milliseconds: 700),
              vsync: this,
            ),
          );
          message.animationController.forward();
          return message;
        }).toList();
      } else {
        final message = ChatMessage(
          text: 'i_can_help_u'.tr,
          animationController: AnimationController(
            duration: const Duration(milliseconds: 700),
            vsync: this,
          ),
        );
        message.animationController.forward();
        mainController.listMess.clear();
        mainController.listMess.add(message);
      }
      return mainController.listMess;
    });
    _controller = ScrollController();
    _controller.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _messages.then((value) {
      for (ChatMessage message in value) {
        message.animationController.dispose();
      }
    });
    super.dispose();
  }

  void _scrollListener() {
    if (_controller.offset >= _controller.position.maxScrollExtent &&
        !_controller.position.outOfRange) {
      //"reach the bottom"
      // setState(() {});
    }
    if (_controller.offset <= _controller.position.minScrollExtent &&
        !_controller.position.outOfRange) {
      // "reach the top";
      // setState(() {});
    }
  }

  BoxDecoration myBoxDecoration() {
    return BoxDecoration(
      border: Border.all(width: 1.0, color: Colors.black38),
      borderRadius: const BorderRadius.all(Radius.circular(10.0)),
    );
  }

  Widget _buildTextInput() => Container(
        margin: const EdgeInsets.all(8.0),
        padding: const EdgeInsets.only(left: 8.0),
        decoration: myBoxDecoration(),
        child: Row(
          children: <Widget>[
            Flexible(
              child: TextField(
                controller: _textController,
                onChanged: (String text) {
                  mainController.isComposing.value = text.isNotEmpty;
                },
                keyboardType: TextInputType.multiline,
                maxLines: 10,
                minLines: 1,
                decoration:
                    InputDecoration.collapsed(hintText: 'send_message'.tr),
              ),
            ),
            Obx(
              () => IconButton(
                icon: const Icon(Icons.send),
                onPressed: mainController.isComposing.value
                    ? () => _handleSubmitted(_textController.text)
                    : null,
              ),
            ),
          ],
        ),
      );

  Widget _buildTextComposer() {
    return IconTheme(
      data: IconThemeData(color: Theme.of(context).primaryColor),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          Container(
            margin: const EdgeInsets.only(bottom: 8.0),
            child: IconButton(
              icon: const Icon(Icons.photo_camera),
              onPressed: () => _handleTouchOnCamera(),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(bottom: 8.0),
            child: IconButton(
              icon: const Icon(Icons.photo_library),
              onPressed: () => _handleTouchOnGalleryPhoto(),
            ),
          ),
          Expanded(
            child: _buildTextInput(),
          ),
        ],
      ),
    );
  }

  void _handleSubmitted(String text) async {
    final SharedPreferences prefs = await _prefs;
    _textController.clear();
    mainController.isComposing.value = false;
    if (text.isNotEmpty) {
      ChatMessage message = ChatMessage(
        text: text,
        animationController: AnimationController(
          duration: const Duration(milliseconds: 700),
          vsync: this,
        ),
      );
      mainController.listMess.insert(0, message);
      _messages = prefs
          .setStringList(
        'message_prefs',
        mainController.listMess.map((e) => e.text).toList(),
      )
          .then((value) {
        return mainController.listMess;
      });
      message.animationController.forward();
    }
  }

  void _handleTouchOnCamera() {}

  void _handleTouchOnGalleryPhoto() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('chat_with_me'.trParams({'name': _name}))),
      body: Builder(
        builder: (context) {
          return Column(
            children: <Widget>[
              Flexible(
                child: FutureBuilder(
                  future: _messages,
                  builder: (context, snapShot) {
                    if (snapShot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    return GetX<MainController>(
                      builder: (ctrl) {
                        return ListView.builder(
                          controller: _controller,
                          padding: const EdgeInsets.all(8.0),
                          reverse: true,
                          itemBuilder: (_, int index) {
                            return ctrl.listMess[index];
                          },
                          itemCount: ctrl.listMess.length,
                        );
                      },
                    );
                  },
                ),
              ),
              // new Divider(height: 1.0),
              Container(
                decoration: BoxDecoration(color: Theme.of(context).cardColor),
                child: SafeArea(
                  bottom: true,
                  child: _buildTextComposer(),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
