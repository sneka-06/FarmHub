import 'package:farm_hub/log_in.dart';
import 'package:flutter/material.dart';
import 'log_in_farmer.dart';

class SelectionPage extends StatelessWidget {
  const SelectionPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned(
            left: -68,
            top: -87,
            child: CircleAvatar(
              radius: 150,
              backgroundColor: Color(0xBFA8DF6E),
            ),
          ),
          Positioned(
            left: -68,
            top: 119,
            child: CircleAvatar(
              radius: 100,
              backgroundColor: Color(0xBFEAE86C),
            ),
          ),
          Positioned(
            left: 143,
            top: 814,
            child: CircleAvatar(
              radius: 104,
              backgroundColor: Color(0xBFA8DF6E),
            ),
          ),
          Positioned(
            left: 275,
            top: 670,
            child: CircleAvatar(
              radius: 130,
              backgroundColor: Color(0xBFEAE86C),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => LogIn()),
                    );
                  },
                  child: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xBFA8DF6E), // Green background
                        ),
                        padding: EdgeInsets.all(10),
                        child: CircleAvatar(
                          radius: 60,
                          backgroundImage: AssetImage(
                            'assets/images/consumer.png',
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'CONSUMER',
                        style: TextStyle(
                          fontSize: 32,
                          fontFamily: 'Fredoka',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 50),
                GestureDetector(
                  // onTap: () {
                  //   // Navigator.push(
                  //   //   context,
                  //   //   MaterialPageRoute(
                  //   //     builder: (context) => LoginPage(userType: 'Farmer'),
                  //   //   ),
                  //   );
                  // },
                  child: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xBFA8DF6E), // Green background
                        ),
                        padding: EdgeInsets.all(10),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const LogInFarmer(),
                              ),
                            );
                          },
                          child: CircleAvatar(
                            radius: 60,
                            backgroundImage: AssetImage(
                              'assets/images/farmer.png',
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'FARMER',
                        style: TextStyle(
                          fontSize: 32,
                          fontFamily: 'Fredoka',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
// import 'package:flutter/material.dart';
// import 'log_in.dart';
// import 'sign_in.dart';
// import 'sign_in_farmer.dart';

// class SelectionPage extends StatelessWidget {
//   const SelectionPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Select User Type')),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             ElevatedButton(
//               onPressed: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) => LoginPage(userType: 'Consumer'),
//                   ),
//                 );
//               },
//               child: Text('Login as Consumer'),
//             ),
//             ElevatedButton(
//               onPressed: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) => LoginPage(userType: 'Farmer'),
//                   ),
//                 );
//               },
//               child: Text('Login as Farmer'),
//             ),
//             SizedBox(height: 20),
//             Text('Or Sign Up as'),
//             ElevatedButton(
//               onPressed: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(builder: (context) => SignUpConsumer()),
//                 );
//               },
//               child: Text('Sign Up as Consumer'),
//             ),
//             ElevatedButton(
//               onPressed: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(builder: (context) => SignUpFarmer()),
//                 );
//               },
//               child: Text('Sign Up as Farmer'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
