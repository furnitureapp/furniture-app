// import 'package:flutter/material.dart';

// class AppbarProfile extends StatefulWidget {
//   const AppbarProfile({super.key});

//   @override
//   State<AppbarProfile> createState() => _AppbarProfileState();
// }

// class _AppbarProfileState extends State<AppbarProfile> {
//   @override
//   Widget build(BuildContext context) {
//     return  Scaffold(
//         appBar: AppBar(
//           backgroundColor: Colors.green,
//           centerTitle:  true,
//           title: Text("Your Profile", style: TextStyle(color: Colors.white, fontSize: 17, letterSpacing: 0.53),),
//           shape: const RoundedRectangleBorder(
//             borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
//           ),
//           leading: InkWell(
//             onTap: () {
              
//             },
//             child: const Icon(Icons.home_filled, color: Colors.white),
          
//           ),
//           actions: [
//             InkWell(
//               onTap: () {
                
//               },
//               child:  Padding(
//                 padding: EdgeInsets.all(8.0),
//                 child: Icon(
//                   Icons.notification_add_outlined,
//                   size: 20,
//                 ),
//               ),
//             )
//           ],
//           bottom: PreferredSize(
//             preferredSize: const Size.fromHeight(110.0),
//             child: Container(
//               padding: const EdgeInsets.only(left: 30,bottom: 20),
//               child: Row(
//                 children: [
//                   Stack(
//                     children: [
//                       const CircleAvatar(radius: 32, backgroundColor: Colors.white,child: Icon(Icons.person_outline_rounded),),
                      
//                     ],
//                   ),
//                   Container(
//                     margin: const EdgeInsets.only(left: 30),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text("Vasavi"),
//                         Text("vasavi.durai@gmail.com",),
//                         Text("9952292217")
//                       ],
//                     ),
//                   )
//                 ],
//               ),
//             )
//             ),
//         ),
//         body: Text("hellooooo"),
//     );
//   }
// }