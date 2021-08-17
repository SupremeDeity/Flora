// import 'package:draw/draw.dart';
// import 'package:flora/PostScreen.dart';
// import 'package:flora/Types/postType.dart';
// import 'package:flora/Widgets/commentBranch.dart';
// import 'package:flora/Widgets/postCard.dart';
// import 'package:flutter/material.dart';

// class MoreCommentsScreen extends StatefulWidget {
//   MoreCommentsScreen(this.comment, {Key? key, this.type = FilterType.Best})
//       : super(key: key);

//   Comment comment;

//   @override
//   _CommentsScreenState createState() => _CommentsScreenState();
// }

// class _CommentsScreenState extends State<MoreCommentsScreen> {
//   bool loaded = false;
//   int _numComments = 0;

//   @override
//   void initState() {
//     super.initState();
//     fetchComments();
//   }

//   fetchComments() async {
//     // If we want to look at all comments.
//     if (widget.post.runtimeType != Comment) {
//       await widget.post.parse();
//       await widget.post.submission
//           .refreshComments()
//           .then((value) => setState(() {
//                 loaded = true;
//                 _numComments = value.length;
//               }));
//     } else {
//       // if we want to look at a singular comment forest.
//       setState(() {
//         loaded = true;
//         _numComments = 1;
//       });
//     }
//   }

//   Widget _generateBranches() {
//     if (widget.post.runtimeType == Comment) {
//       print('called');
//       return CommentBranch(widget.post);
//     }

//     return ListView.builder(
//       itemCount: _numComments + 1,
//       itemBuilder: (ctx, index) {
//         if (index == 0 && widget.post.runtimeType != Comment) {
//           return PostCard();
//         }
//         if (widget.post.submission.comments?[index - 1].runtimeType ==
//             Comment) {
//           return CommentBranch(
//             widget.post.submission.comments?[index - 1],
//           );
//         } else {
//           return ElevatedButton(
//             onPressed: () {},
//             child: Text("More"),
//           );
//         }
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       child: Scaffold(
//         appBar: AppBar(
//           automaticallyImplyLeading: false,
//           leading: IconButton(
//               icon: Icon(Icons.arrow_back),
//               onPressed: () => {Navigator.pop(context)}),
//           title: Text("Comments"),
//         ),
//         body: loaded
//             ? _generateBranches()
//             : Center(
//                 child: CircularProgressIndicator(
//                 color: Colors.blue,
//               )),
//       ),
//     );
//   }
// }
