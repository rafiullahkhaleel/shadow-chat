import 'package:cached_network_image/cached_network_image.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shadow_chat/core/contants/constants.dart';
import 'package:shadow_chat/core/model/user_model.dart';
import 'package:shadow_chat/view/widgets/message_card.dart';

import '../../core/provider/messages_provider.dart';

class UserChatScreen extends ConsumerWidget {
  final UserModel userData;
  const UserChatScreen({super.key, required this.userData});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    String time = DateFormat('hh:mm a').format(userData.lastActive!);
    final messageState = ref.watch(messagesProvider(userData.uid));
    final messageNotifier = ref.read(messagesProvider(userData.uid).notifier);
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        leadingWidth: 32,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: ListTile(
          contentPadding: EdgeInsets.zero,
          leading: CircleAvatar(
            radius: 23,
            backgroundImage: CachedNetworkImageProvider(userData.imageUrl),
          ),
          title: Text(
            userData.name,
            style: TextStyle(color: AppColors.white, fontSize: 17),
          ),
          subtitle: Text(
            userData.isOnline ? 'online' : 'last seen today at $time',
            style: TextStyle(color: AppColors.white, fontSize: 13),
          ),
        ),
      ),
      body: Column(
        children: [
          messageState.data.when(
            data: (data) {
              if (data.isEmpty) {
                return Expanded(
                  child: Text(
                    'No Messages',
                    style: TextStyle(color: Colors.white),
                  ),
                );
              }
              return Expanded(
                child: ListView.builder(
                  reverse: true,
                  itemCount: data.length,
                  itemBuilder: (context, index) {
                    return MessageCard(data: data[index]);
                  },
                ),
              );
            },
            error:
                (error, stack) => Center(child: Text('ERROR OCCURRED $error')),
            loading:
                () =>
                    Expanded(child: Center(child: CircularProgressIndicator())),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Row(
              children: [
                Expanded(
                  child: Card(
                    margin: EdgeInsets.only(left: 8, bottom: 8, top: 0),
                    color: Colors.white,
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            messageNotifier.toggleEmoji(context);
                          },
                          icon: Icon(
                            messageState.showEmoji
                                ? Icons.keyboard_alt
                                : Icons.emoji_emotions,
                          ),
                        ),
                        Expanded(
                          child: TextFormField(
                            focusNode: messageNotifier.focusNode,
                            controller: messageNotifier.messageController,
                            decoration: InputDecoration(
                              hintText: 'Type a message',
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            messageNotifier.sendImage(ImageSource.gallery);
                          },
                          icon: Icon(Icons.photo),
                        ),
                        IconButton(
                          onPressed: () {
                            messageNotifier.sendImage(ImageSource.camera);
                          },
                          icon: Icon(Icons.camera_alt),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: MaterialButton(
                    minWidth: 0,
                    padding: EdgeInsets.all(8),
                    onPressed: () {
                      messageNotifier.sendMessage(userData.uid);
                    },
                    shape: CircleBorder(),
                    color: AppColors.mainColor,
                    child: Icon(Icons.send, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          Offstage(
            offstage: !messageState.showEmoji,
            child: SizedBox(
              height: 260,
              child: EmojiPicker(
                onEmojiSelected: (category, emoji) {
                  messageNotifier.messageController.text += emoji.emoji;
                },
                config: Config(
                  height: 256,
                  emojiViewConfig: EmojiViewConfig(emojiSizeMax: 28),
                  categoryViewConfig: const CategoryViewConfig(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
