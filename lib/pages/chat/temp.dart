// import 'dart:io';
// import 'package:file_picker/file_picker.dart';
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:audioplayers/audioplayers.dart';
// import 'package:dio/dio.dart';
// import 'package:doctor_panel/models/model_list.dart';
// import 'package:doctor_panel/models/user_model.dart';
// import 'package:doctor_panel/pages/place_holder.dart';
// import 'package:doctor_panel/providers/provider_list.dart';
// import 'package:doctor_panel/widgets/widgets.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:image_picker/image_picker.dart';
// // import 'package:intl/date_symbol_data_http_request.dart';
// import 'package:intl/intl.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:web_socket_channel/io.dart';
// import '../../utils/utils.dart';
// import 'package:web_socket_channel/web_socket_channel.dart';
// import 'dart:convert';
// import 'dart:async';
// import 'package:flutter_sound/flutter_sound.dart';
// import 'package:path/path.dart' as path;

// class ChatMessage extends StatefulWidget {
//   final String theToken;
//   final String myPhoneNumber;
//   final UserModel userModel;
//   ChatMessage({required this.theToken, required this.userModel, required this.myPhoneNumber});
//   @override
//   _ChatMessageState createState() => _ChatMessageState();
// }

// class _ChatMessageState extends State<ChatMessage> {
//   List<ChatModel> messageList = <ChatModel>[];
//   late WebSocketChannel channel;
//   @override
//   void initState() {
//     super.initState();
//     _getChatData();
//     channel = IOWebSocketChannel.connect(Uri.parse(
//         'ws://192.168.0.136:8000/ws/chat/${widget.userModel.phone}/?token=' + widget.theToken));

//     channel.stream.listen((event) {
//       print('isnde the listenter');
//       print(event);
//       if (event != null) {
//         Map<String, dynamic> theData = json.decode(event);
//         print('value of theData');
//         print(theData);
//         if (theData['message'] != '' || theData['message'] != null) {
//           bool isNotText = (theData['media_type'] == 'image' ||
//               theData['media_type'] == 'attachement' ||
//               theData['media_type'] == 'voice');

//           // images
//           List<ChatImageModel> chatImageList = <ChatImageModel>[];
//           if (theData['media_type'] == 'image') {
//             if (theData['images'] != null) {
//               theData['images'].forEach((val) {
//                 chatImageList.add(ChatImageModel(image: MEDIA_LINK_NO_SLASH + val));
//               });
//             }
//           }

//           // files
//           List<ChatAttachmentModel> chatFileList = <ChatAttachmentModel>[];
//           if (theData['media_type'] == 'attachement') {
//             if (theData['attachments'] != null) {
//               theData['attachments'].forEach((val) {
//                 print('value of val in attachment');
//                 print(val);
//                 chatFileList.add(ChatAttachmentModel(attachment: MEDIA_LINK_NO_SLASH + val));
//               });
//             }
//           }

//           print('added------');
//           setState(() {
//             messageList.insert(
//               0,
//               ChatModel(
//                   message: isNotText ? "" : theData['message'],
//                   userModel: UserModel(phone: theData['user_phone']),
//                   imageList: (theData['media_type'] == 'image' && chatImageList.length != 0)
//                       ? chatImageList
//                       : <ChatImageModel>[],
//                   attachmentList:
//                       (theData['media_type'] == 'attachement' && chatFileList.length != 0)
//                           ? chatFileList
//                           : <ChatAttachmentModel>[],
//                   voice: (theData['media_type'] == 'voice' && theData['voice'] != null)
//                       ? (MEDIA_LINK_NO_SLASH + theData['voice'])
//                       : null),
//             );
//           });
//         }
//       }
//     });
//   }

//   void _getChatData() async {
//     print('value of _getChatData');
//     final progressObject = await progressDialogue(context: context);
//     await progressObject.show();
//     var chatObjectList =
//         await HttpService().getRequest(endPoint: CHAT_GET_POST + '${widget.userModel.phone}/');

//     if (!chatObjectList.error) {
//       if (chatObjectList.data is List) {
//         // Chat
//         setState(() {
//           chatObjectList.data.forEach((response) {
//             final theObject = ChatModel.fromJson(response);
//             messageList.add(theObject);
//           });
//         });
//       }
//     } else {
//       infoNoOkDialogue(context, chatObjectList.errorMessage.toString(), 'Oops Error');
//     }

//     await progressObject.hide();
//   }

//   // close the websocket in dispose()
//   @override
//   void dispose() {
//     super.dispose();
//     print('disponse the channel ---====//////');
//     channel.sink.close();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final mQuery = MediaQuery.of(context).size;
//     return Scaffold(
//       appBar: AppBar(
//         automaticallyImplyLeading: false,
//         title: _appBarTitle(),
//         elevation: 0.0,
//         backgroundColor: Palette.blueAppBar,
//         actions: [
//           buildIcon(Icons.call),
//           SizedBox(width: 12),
//           buildIcon(Icons.videocam),
//           SizedBox(width: 12),
//         ],
//       ),
//       // extendBodyBehindAppBar: true,
//       backgroundColor: Palette.blueAppBar,
//       body: SafeArea(
//         child: Column(
//           children: [
//             SizedBox(
//               height: 8,
//             ),
//             Expanded(
//               child: Container(
//                   padding: EdgeInsets.all(8),
//                   decoration: BoxDecoration(
//                     color: Palette.scaffoldBackground,
//                     borderRadius: BorderRadius.only(
//                       topLeft: Radius.circular(25),
//                       topRight: Radius.circular(25),
//                     ),
//                   ),
//                   child: messageList.length == 0
//                       ? PlaceHolder(title: 'No Message', body: 'Send A Message To Get Started')
//                       : ListView.builder(
//                           physics: BouncingScrollPhysics(),
//                           reverse: true,
//                           itemCount: messageList.length,
//                           itemBuilder: (context, index) {
//                             return MessageWidget(
//                               chatModel: messageList[index],
//                               isMe: widget.userModel.phone != messageList[index].userModel!.phone,
//                             );
//                           },
//                         )),
//             ),
//             NewMessageWidget(
//               channel: channel,
//               myPhoneNumber: widget.myPhoneNumber,
//               otherUserPhone: widget.userModel.phone ?? 'no_phone',
//             )
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _appBarTitle() {
//     return Row(
//       children: [
//         IconButton(icon: Icon(Icons.arrow_back_ios), onPressed: () => Navigator.of(context).pop()),
//         CircleAvatar(
//           radius: 16,
//           backgroundImage: NetworkImage(
//               'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTs4OvEyp52o83bWY4o6zrteuayFSg8wsgvVA&usqp=CAU'),
//         ),
//         SizedBox(
//           width: 5.0,
//         ),
//         Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               'Arif Khan',
//               style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
//             ),
//             Text(
//               'Active 5h ago',
//               style: TextStyle(fontSize: 12),
//             ),
//           ],
//         )
//       ],
//     );
//   }

//   Widget buildIcon(IconData icon) => Container(
//         padding: EdgeInsets.all(5),
//         decoration: BoxDecoration(
//           shape: BoxShape.circle,
//           color: Colors.white54,
//         ),
//         child: Icon(icon, size: 23, color: Colors.white),
//       );
// }

// class MessageWidget extends StatelessWidget {
//   final ChatModel chatModel;
//   final bool isMe;

//   const MessageWidget({
//     required this.chatModel,
//     required this.isMe,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final radius = Radius.circular(15);
//     final borderRadius = BorderRadius.all(radius);
//     final user = chatModel.userModel;
//     final theMessage = chatModel.message;

//     return Row(
//       mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
//       children: <Widget>[
//         if (!isMe)
//           CircleAvatar(
//               radius: 16,
//               backgroundImage: (user!.avatar == null || user.avatar == '')
//                   ? AssetImage("assets/icons/male_icon.jpeg")
//                   : NetworkImage(user.avatar!) as ImageProvider),
//         Container(
//           padding: EdgeInsets.all(10),
//           margin: EdgeInsets.all(10),
//           constraints: BoxConstraints(maxWidth: 220),
//           decoration: BoxDecoration(
//             color: isMe ? Palette.blueAppBar : Palette.imageBackground,
//             borderRadius: isMe
//                 ? borderRadius.subtract(BorderRadius.only(bottomRight: radius))
//                 : borderRadius.subtract(BorderRadius.only(bottomLeft: radius)),
//           ),
//           child: Column(
//             crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
//             children: <Widget>[
//               // attachments
//               if (theMessage == '' &&
//                   (chatModel.attachmentList!.length != 0 && chatModel.attachmentList != null))
//                 _showAttach(chatModel.attachmentList ?? <ChatAttachmentModel>[], context),
//               // images
//               if (theMessage == '' &&
//                   (chatModel.imageList!.length != 0 && chatModel.imageList != null))
//                 _showImage(chatModel.imageList ?? <ChatImageModel>[], context),
//               // voice
//               if (theMessage == '' && chatModel.voice != null)
//                 VoiceMessagePlayer(
//                   voiceUrl: chatModel.voice ?? '',
//                   isLocal: false,
//                 ),
//               // only text
//               if ((theMessage != ''))
//                 Text(
//                   theMessage ?? '',
//                   style: TextStyle(color: isMe ? Colors.white : Colors.black, fontSize: 15),
//                 ),
//               //  end of content
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.end,
//                 children: [
//                   Text(
//                     chatModel.timestamp ??
//                         DateFormat.yMd().add_jm().format(DateTime.now()).toString(),
//                     style: TextStyle(color: isMe ? Colors.white70 : Colors.black54, fontSize: 13),
//                   ),
//                   SizedBox(
//                     width: 3.0,
//                   ),
//                   Icon(
//                     Icons.done_all,
//                     color: isMe ? Colors.white70 : Colors.black54,
//                     size: 18,
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }

//   Center _showAttach(List<ChatAttachmentModel> theFiles, BuildContext context) {
//     return Center(
//       child: Wrap(
//         spacing: 8.0,
//         runSpacing: 5.0,
//         // shrinkWrap: true,
//         // scrollDirection: Axis.horizontal,
//         children: theFiles.length == 0
//             ? [Text('Not Available')]
//             : theFiles
//                 .map(
//                   (e) => GestureDetector(
//                     onTap: () =>
//                         isPdf(e.attachment ?? '') ? showPdf(e.attachment ?? '', context) : null,
//                     child: Container(
//                       height: 60,
//                       width: 65,
//                       child: Container(
//                         decoration: BoxDecoration(
//                             border: Border.all(width: 2),
//                             color: Palette.imageBackground,
//                             borderRadius: BorderRadius.circular(5)),
//                         margin: EdgeInsets.only(right: 5.0),
//                         child: isPdf(e.attachment ?? '')
//                             ? Center(
//                                 child: Icon(
//                                   Icons.picture_as_pdf_outlined,
//                                   size: 40,
//                                 ),
//                               )
//                             : Text('File Error'),
//                       ),
//                     ),
//                   ),
//                 )
//                 .toList(),
//         // children: medicalNameOnlyList.map((e) => Text(e)).toList(),
//       ),
//     );
//   }

//   Center _showImage(List<ChatImageModel> theImages, BuildContext context) {
//     return Center(
//       child: Wrap(
//         spacing: 8.0,
//         runSpacing: 5.0,
//         // shrinkWrap: true,
//         // scrollDirection: Axis.horizontal,
//         children: theImages.length == 0
//             ? [Text('Images Not Available')]
//             : theImages
//                 .map(
//                   (e) => GestureDetector(
//                     onTap: () => Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                             builder: (context) => MedicalPhotoGallery(chatImageList: theImages))),
//                     child: Container(
//                       height: 90,
//                       width: 90,
//                       child: Container(
//                         decoration: BoxDecoration(
//                             color: Palette.imageBackground, borderRadius: BorderRadius.circular(5)),
//                         margin: EdgeInsets.only(right: 5.0),
//                         child: CachedNetworkImage(
//                           imageBuilder: (context, imageProvider) => Container(
//                             decoration: BoxDecoration(
//                               image: DecorationImage(
//                                   image: imageProvider,
//                                   fit: BoxFit.cover,
//                                   colorFilter: ColorFilter.mode(Colors.red, BlendMode.colorBurn)),
//                             ),
//                           ),
//                           placeholder: (context, url) => circularLoading(),
//                           errorWidget: (context, url, error) => Icon(
//                             Icons.error,
//                             color: Colors.white,
//                             size: 50,
//                           ),
//                           fit: BoxFit.cover,
//                           imageUrl: e.image ?? '',
//                         ),
//                       ),
//                     ),
//                   ),
//                 )
//                 .toList(),
//         // children: medicalNameOnlyList.map((e) => Text(e)).toList(),
//       ),
//     );
//   }
// }

// class VoiceMessagePlayer extends StatefulWidget {
//   final String voiceUrl;
//   final bool isLocal;
//   const VoiceMessagePlayer({
//     Key? key,
//     required this.voiceUrl,
//     required this.isLocal,
//   }) : super(key: key);

//   @override
//   _VoiceMessagePlayerState createState() => _VoiceMessagePlayerState();
// }

// class _VoiceMessagePlayerState extends State<VoiceMessagePlayer> {
//   // AudioPlayer audioPlayerObject = AudioPlayer();
//   late AudioPlayer audioPlayerObject;
//   Duration _duration = Duration();
//   Duration _position = Duration();
//   bool isPlaying = false;
//   bool isPaused = false;
//   bool isRepeat = false;
//   @override
//   void initState() {
//     super.initState();
//     initialization();
//   }

//   void initialization() async {
//     audioPlayerObject = new AudioPlayer();
//     audioPlayerObject.setUrl(widget.voiceUrl, isLocal: widget.isLocal);
//     audioPlayerObject.onDurationChanged.listen((theDuration) {
//       print('value of theDuration');
//       print(theDuration);
//       setState(() {
//         _duration = theDuration;
//       });
//     });
//     audioPlayerObject.onAudioPositionChanged.listen((thePosition) {
//       print('value of thePosition');
//       print(thePosition);
//       setState(() {
//         _position = thePosition;
//       });
//     });
//     audioPlayerObject.onPlayerCompletion.listen((event) {
//       setState(() {
//         _position = Duration(seconds: 0);
//         if (isRepeat) {
//           isPlaying = true;
//         } else {
//           isPlaying = false;
//           isRepeat = false;
//         }
//       });
//     });
//   }

//   void _playButton() {
//     print('value of _duration in player button');
//     print(_duration);
//     if (!isPlaying) {
//       audioPlayerObject.play(widget.voiceUrl);
//       setState(() {
//         isPlaying = true;
//       });
//     } else {
//       audioPlayerObject.pause();
//       setState(() {
//         isPlaying = false;
//       });
//     }
//   }

//   void _changeToSecond(int second) {
//     Duration newDuration = Duration(seconds: second);
//     audioPlayerObject.seek(newDuration);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       children: [
//         // Padding(
//         // padding: const EdgeInsets.all(5.0),
//         // child:
//         IconButton(
//             icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow_rounded),
//             onPressed: () =>
//                 widget.voiceUrl != '' ? _playButton() : toastSnackBar('Audio No Available')),
//         // ),
//         // the problem is with slider and duration and position value
//         Expanded(
//             child: Row(
//           mainAxisAlignment: MainAxisAlignment.end,
//           children: [
//             Text(_position.toString().split('.')[0].substring(2)),
//             Text('/'),
//             Text(_duration.toString().split('.')[0].substring(2)),
//           ],
//         )

//             // Slider(
//             //   activeColor: Colors.red,
//             //   inactiveColor: Colors.grey,
//             //   value: _position.inSeconds.toDouble(),
//             //   min: 0.0,
//             //   // max: _duration.inSeconds.toDouble(),
//             //   // max: (_position.inSeconds.toDouble()) > (_duration.inSeconds.toDouble())
//             //   //     ? _duration.inSeconds.toDouble()
//             //   //     : 1.0,
//             //   max: _duration.inSeconds.toDouble(),
//             //   onChanged: (double value) {
//             //     setState(() {
//             //       print('value of change');
//             //       print(value);
//             //       _changeToSecond(value.toInt());
//             //       // value = value;
//             //     });
//             //   },
//             // ),
//             ),
//       ],
//     );
//   }
// }

// class NewMessageWidget extends StatefulWidget {
//   final WebSocketChannel channel;
//   final String otherUserPhone;
//   final String myPhoneNumber;
//   NewMessageWidget(
//       {Key? key, required this.channel, required this.otherUserPhone, required this.myPhoneNumber})
//       : super(key: key);

//   @override
//   _NewMessageWidgetState createState() => _NewMessageWidgetState();
// }

// class _NewMessageWidgetState extends State<NewMessageWidget> {
//   final _controller = TextEditingController();
//   String message = '';
//   bool isAttachment = true;
//   bool isVoice = false;
//   FlutterSoundRecorder? _soundRecorder;
//   late String _filePath;
//   bool _play = false;
//   String _recordText = '00:00:00';

//   void _voiceRecorder() async {
//     setState(() {
//       isVoice = true;
//     });
//     // initialization part
//     // String theTime = DateTime.now().toString();
//     _filePath = 'sound_file.aac';
//     // _filePath = 'sdcard/Download/${theTime}_sound_file.wav';
//     _soundRecorder = FlutterSoundRecorder();
//     await _soundRecorder!.openAudioSession(
//         focus: AudioFocus.requestFocusAndStopOthers,
//         category: SessionCategory.playAndRecord,
//         mode: SessionMode.modeDefault,
//         device: AudioDevice.speaker);
//     await _soundRecorder!.setSubscriptionDuration(Duration(milliseconds: 10));
//     // await initializeDateFormatting(locale, url);
//     // await initializeDateFormatting();

//     await Permission.microphone.request();

//     // recording part
//     Directory dir = Directory(path.dirname(_filePath));
//     if (!dir.existsSync()) {
//       dir.createSync();
//     }
//     _soundRecorder!.openAudioSession();
//     await _soundRecorder!.startRecorder(toFile: _filePath, codec: Codec.pcm16WAV);

//     StreamSubscription _recordSubscription = _soundRecorder!.onProgress!.listen((event) {
//       var date = DateTime.fromMicrosecondsSinceEpoch(event.duration.inMilliseconds, isUtc: true);
//       var txt = DateFormat('mm:ss:SS', 'en_GB').format(date);
//       setState(() {
//         _recordText = txt.substring(0, 8);
//       });
//     });
//     _recordSubscription.cancel();
//   }

//   Future<void> _stopRecord() async {
//     _soundRecorder!.closeAudioSession();
//     final recorderStopResult = await _soundRecorder!.stopRecorder();
//     print('value of recorderStopResult ----------');
//     print(recorderStopResult);
//     print('value fo _filePath');
//     print(_filePath);
//     // print(dir.path);
//     // now play the music
//     // also add voice to the list of chat as well
//     // get the object of websocket and then send the voice to the server
//     // do a proper post like attachments
//     if (2 == 2) {
//       // avatarName == 'no_avatar'
//       //           ? 'no_avatar'
//       //           : await MultipartFile.fromFile(
//       //               _image.path,
//       //               filename: avatarName,
//       //             )
//       FormData fileBody = FormData.fromMap({
//         'audio': MultipartFile.fromFileSync(
//           _filePath,
//           // filename: _filePath,
//         ),
//       });
//       final progressObject = await progressDialogue(context: context);
//       await progressObject.show();
//       var voiceChatResponse = await HttpService().postRequest(
//         data: fileBody,
//         endPoint: CHAT_GET_POST + "${widget.otherUserPhone}/",
//       );

//       if (!voiceChatResponse.error) {
//         print('value of scheduleResponse.data');
//         print(voiceChatResponse.data);
//         if (voiceChatResponse.data['status'] == 'success') {
//           final fileBodyData = {
//             'message': 'voice-message',
//             'voice': voiceChatResponse.data['voice'],
//             'user_phone': widget.myPhoneNumber,
//           };
//           final jsonData = json.encode(fileBodyData);
//           widget.channel.sink.add(jsonData);
//         }
//         toastSnackBar('Saved Successfully');
//       } else {
//         infoNoOkDialogue(context, voiceChatResponse.errorMessage.toString(), 'Unknown Error');
//       }
//       await progressObject.hide();
//     }
//   }

//   // =============== // =================

//   Future<void> _getImageFile(String operation) async {
//     if (widget.otherUserPhone == 'no_phone') {
//       infoNoOkDialogue(context, 'Restart the app to get started', 'User Not Available');
//       return;
//     }
//     var pickedFile;
//     FilePickerResult? fileResult;
//     File? _image;
//     File? _file;
//     final picker = ImagePicker();
//     FormData? fileBody;
//     FormData? imageBody;
//     // get pdf or files

//     if (operation != 'image') {
//       fileResult = await FilePicker.platform.pickFiles(
//         type: FileType.custom,
//         allowMultiple: false,
//         allowedExtensions: ['pdf'],
//       );
//       String fileName = 'no_file';
//       if (fileResult != null) {
//         // if allowMultiple is true then we use List<File>
//         // List<File> files = fileResult.paths.map((path) => File(path)).toList();
//         _file = File(fileResult.files.single.path!);
//         print('value of _file');
//         print(_file);
//         fileName = _file.path.split('/').last;
//         // file body
//         fileBody = FormData.fromMap({
//           'file': [
//             fileName == 'no_file'
//                 ? 'no_file'
//                 : await MultipartFile.fromFile(
//                     _file.path,
//                     filename: fileName,
//                   )
//           ],
//         });
//       }
//     }

//     if (operation == 'image') {
//       // get image
//       pickedFile = await picker.getImage(
//           source: ImageSource.gallery,
//           imageQuality: 65, // <- Reduce Image quality
//           maxHeight: 300, // <- reduce the image size
//           maxWidth: 300);
//       String avatarName = 'no_avatar';
//       if (pickedFile != null) {
//         print('value of pickedFile');
//         print(pickedFile);
//         _image = File(pickedFile.path);
//         avatarName = _image.path.split('/').last;
//         // image body
//         imageBody = FormData.fromMap({
//           'image': [
//             avatarName == 'no_avatar'
//                 ? 'no_avatar'
//                 : await MultipartFile.fromFile(
//                     _image.path,
//                     filename: avatarName,
//                   )
//           ],
//         });
//       }
//     }

//     // sending request
//     if (pickedFile != null || fileResult != null) {
//       final progressObject = await progressDialogue(context: context);
//       await progressObject.show();
//       var chatResponse = await HttpService().postRequest(
//         data: operation == 'image' ? imageBody : fileBody,
//         endPoint: CHAT_GET_POST + "${widget.otherUserPhone}/",
//       );

//       if (!chatResponse.error) {
//         print('value of scheduleResponse.data');
//         print(chatResponse.data);
//         if (chatResponse.data['status'] == 'success') {
//           final imageBodyData = {
//             'message': 'image-files',
//             'images': chatResponse.data['imageNames'],
//             'user_phone': widget.myPhoneNumber,
//           };
//           final fileBodyData = {
//             'message': 'attachment-files',
//             'files': chatResponse.data['attachmentNames'],
//             'user_phone': widget.myPhoneNumber,
//           };
//           final jsonData = json.encode(operation == 'image' ? imageBodyData : fileBodyData);
//           widget.channel.sink.add(jsonData);
//         }
//         toastSnackBar('Saved Successfully');
//       } else {
//         infoNoOkDialogue(context, chatResponse.errorMessage.toString(), 'Unknown Error');
//       }
//       await progressObject.hide();
//     }
//   }

//   void sendMessage() async {
//     setState(() {
//       isAttachment = true;
//     });
//     FocusScope.of(context).unfocus();
//     print('messages got sent 9999999');
//     final theData = {
//       'message': _controller.text,
//       'user_phone': widget.myPhoneNumber,
//     };
//     final jsonData = json.encode(theData);
//     widget.channel.sink.add(jsonData);

//     _controller.clear();
//   }

//   @override
//   Widget build(BuildContext context) => Container(
//         color: Colors.white,
//         padding: EdgeInsets.all(8),
//         child: Row(
//           children: <Widget>[
//             if (isVoice)
//               Row(
//                 children: [
//                   GestureDetector(
//                     onTap: () {
//                       setState(() {
//                         isVoice = false;
//                       });
//                       FocusScope.of(context).unfocus();
//                     },
//                     child: Container(
//                       padding: EdgeInsets.all(10),
//                       decoration: BoxDecoration(
//                         shape: BoxShape.circle,
//                         color: Palette.blueAppBar,
//                       ),
//                       child: Icon(Icons.clear, color: Colors.white),
//                     ),
//                   ),
//                   SizedBox(width: 8),
//                 ],
//               ),
//             if (!isAttachment && !isVoice)
//               Row(
//                 children: [
//                   GestureDetector(
//                     onTap: () {
//                       setState(() {
//                         isAttachment = true;
//                       });
//                       FocusScope.of(context).unfocus();
//                     },
//                     child: Container(
//                       padding: EdgeInsets.all(10),
//                       decoration: BoxDecoration(
//                         shape: BoxShape.circle,
//                         color: Palette.blueAppBar,
//                       ),
//                       child: Icon(Icons.arrow_forward_ios_outlined, color: Colors.white),
//                     ),
//                   ),
//                   SizedBox(width: 8),
//                 ],
//               ),
//             if (isAttachment && !isVoice)
//               Row(
//                 children: [
//                   GestureDetector(
//                     onTap: () => _getImageFile('file'),
//                     child: Container(
//                       padding: EdgeInsets.all(10),
//                       decoration: BoxDecoration(
//                         shape: BoxShape.circle,
//                         color: Palette.blueAppBar,
//                       ),
//                       child: Icon(Icons.attach_file, color: Colors.white),
//                     ),
//                   ),
//                   SizedBox(width: 8),
//                   GestureDetector(
//                     onTap: () => _getImageFile('image'),
//                     child: Container(
//                       padding: EdgeInsets.all(10),
//                       decoration: BoxDecoration(
//                         shape: BoxShape.circle,
//                         color: Palette.blueAppBar,
//                       ),
//                       child: Icon(Icons.camera_alt_outlined, color: Colors.white),
//                     ),
//                   ),
//                   SizedBox(width: 8),
//                   GestureDetector(
//                     onTap: () => _voiceRecorder(),
//                     child: Container(
//                       padding: EdgeInsets.all(10),
//                       decoration: BoxDecoration(
//                         shape: BoxShape.circle,
//                         color: Palette.blueAppBar,
//                       ),
//                       child: Icon(CupertinoIcons.mic, color: Colors.white),
//                     ),
//                   ),
//                   SizedBox(width: 8),
//                 ],
//               ),
//             if (isVoice)
//               Row(
//                 children: [
//                   SizedBox(width: 8),
//                   GestureDetector(
//                     onTap: () {
//                       setState(() {
//                         isVoice = false;
//                       });
//                       _stopRecord();
//                     },
//                     child: Container(
//                       padding: EdgeInsets.all(10),
//                       decoration: BoxDecoration(
//                         shape: BoxShape.circle,
//                         color: Palette.blueAppBar,
//                       ),
//                       child: Icon(Icons.pause, color: Colors.white),
//                     ),
//                   ),
//                   SizedBox(width: 8),
//                 ],
//               ),
//             if (isVoice)
//               Expanded(
//                 child: Container(
//                   height: 50.0,
//                   // color: Colors.green,
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Icon(
//                         Icons.circle,
//                         color: Colors.red,
//                       ),
//                       SizedBox(
//                         width: 2,
//                       ),
//                       Text(
//                         _recordText,
//                         style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
//                       )
//                     ],
//                   ),
//                 ),
//               ),
//             if (!isVoice)
//               Expanded(
//                 child: Container(
//                   height: 50.0,
//                   child: TextFormField(
//                     controller: _controller,
//                     onTap: () {
//                       setState(() {
//                         isAttachment = false;
//                       });
//                     },
//                     onChanged: (value) => setState(() {
//                       message = value;
//                     }),
//                     decoration: textFieldDesign(context, 'Type Your Message'),
//                   ),
//                 ),
//               ),
//             SizedBox(width: 8),
//             GestureDetector(
//               onTap: message.trim().isEmpty ? null : sendMessage,
//               child: Container(
//                 padding: EdgeInsets.all(10),
//                 decoration: BoxDecoration(
//                   shape: BoxShape.circle,
//                   color: Palette.blueAppBar,
//                 ),
//                 child: Icon(Icons.send, color: Colors.white),
//               ),
//             ),
//           ],
//         ),
//       );
// }
