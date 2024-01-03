// class GoogleLoginModel {
//   String? displayName;
//   String? email;
//   bool? isEmailVerified;
//   bool? isAnonymous;
//   UserMetadata? metadata;
//   String? phoneNumber;
//   String? photoURL;
//   List<UserInfo?>? providerData;
//   String? refreshToken;
//   String? tenantId;
//   String? uid;
//
//   GoogleLoginModel({
//     this.displayName,
//     this.email,
//     this.isEmailVerified,
//     this.isAnonymous,
//     this.metadata,
//     this.phoneNumber,
//     this.photoURL,
//     this.providerData,
//     this.refreshToken,
//     this.tenantId,
//     this.uid,
//   });
//
//   // Factory method to create a User object from a Map
//   factory GoogleLoginModel.fromMap(Map<String, dynamic> map) {
//     return GoogleLoginModel(
//       displayName: map['displayName'],
//       email: map['email'],
//       isEmailVerified: map['isEmailVerified'],
//       isAnonymous: map['isAnonymous'],
//       metadata: UserMetadata.fromMap(map['metadata']),
//       phoneNumber: map['phoneNumber'],
//       photoURL: map['photoURL'],
//       providerData: (map['providerData'] as List)
//           ?.map((item) => UserInfo.fromMap(item))
//           !.toList(),
//       refreshToken: map['refreshToken'],
//       tenantId: map['tenantId'],
//       uid: map['uid'],
//     );
//   }
// }
//
// class UserMetadata {
//   String? creationTime;
//   String? lastSignInTime;
//
//   UserMetadata({this.creationTime, this.lastSignInTime});
//
//   factory UserMetadata.fromMap(Map<String, dynamic> map) {
//     return UserMetadata(
//       creationTime: map['creationTime'],
//       lastSignInTime: map['lastSignInTime'],
//     );
//   }
// }
//
// class UserInfo {
//   String? displayName;
//   String? email;
//   String? phoneNumber;
//   String? photoURL;
//   String? providerId;
//   String? uid;
//
//   UserInfo({
//     this.displayName,
//     this.email,
//     this.phoneNumber,
//     this.photoURL,
//     this.providerId,
//     this.uid,
//   });
//
//   factory UserInfo.fromMap(Map<String, dynamic> map) {
//     return UserInfo(
//       displayName: map['displayName'],
//       email: map['email'],
//       phoneNumber: map['phoneNumber'],
//       photoURL: map['photoURL'],
//       providerId: map['providerId'],
//       uid: map['uid'],
//     );
//   }
// }
//
//
//
// Future<GoogleLoginModel> googleLoginResponse(
//     Map<String, dynamic> googleSignInResponse) async {
//   // Data
//   // String name = apiResponse['name'].toString();
//   // String id = apiResponse['id'].toString();
//   // int height = int.parse(apiResponse['picture']['data']['height'].toString());
//   // print('123:'  + apiResponse['picture']['data']['is_silhouette'].toString());
//   // bool isSilhouette =
//   // bool.parse(apiResponse['picture']['data']['is_silhouette'].toString());
//   // String url = apiResponse['picture']['data']['url'].toString();
//   // int width = int.parse(apiResponse['picture']['data']['height'].toString());
// // Assuming 'googleSignInResponse' is the response you receive from Google Sign-In
//
// // Accessing fields directly from the response
//   String name = googleSignInResponse.displayName ?? '';
//   String email = googleSignInResponse.email ?? '';
//   bool isEmailVerified = googleSignInResponse.isEmailVerified ?? false;
//   bool isAnonymous = googleSignInResponse.isAnonymous ?? false;
//   String creationTime = googleSignInResponse.metadata.creationTime ?? '';
//   String lastSignInTime = googleSignInResponse.metadata.lastSignInTime ?? '';
//   String photoURL = googleSignInResponse.photoURL ?? '';
//   String uid = googleSignInResponse.uid ?? '';
//
// // Accessing fields from nested maps or lists
// // In this example, I'm assuming there's only one element in providerData list
//   String providerId =
//       googleSignInResponse.providerData[0]?.providerId ?? '';
//   String userInfoDisplayName =
//       googleSignInResponse.providerData[0]?.displayName ?? '';
//   String userInfoEmail = googleSignInResponse.providerData[0]?.email ?? '';
//   String userInfoPhotoURL =
//       googleSignInResponse.providerData[0]?.photoURL ?? '';
//   String userInfoUid = googleSignInResponse.providerData[0]?.uid ?? '';
//
// // Print or use the extracted values as needed
//   print('Name: $name');
//   print('Email: $email');
//   print('Is Email Verified: $isEmailVerified');
//   print('Is Anonymous: $isAnonymous');
//   print('Creation Time: $creationTime');
//   print('Last Sign In Time: $lastSignInTime');
//   print('Photo URL: $photoURL');
//   print('UID: $uid');
//   print('Provider ID: $providerId');
//   print('UserInfo Display Name: $userInfoDisplayName');
//   print('UserInfo Email: $userInfoEmail');
//   print('UserInfo Photo URL: $userInfoPhotoURL');
//   print('UserInfo UID: $userInfoUid');
//
//   // Create Map
//   // User information
//   Map<String,dynamic> userMap = {
//     'displayName': 'Junaid Amir',
//     'email': 'junaid.amir077@gmail.com',
//     'isEmailVerified': true,
//     'isAnonymous': false,
//     'metadata': {
//       'creationTime': '2024-01-02 12:12:18.282Z',
//       'lastSignInTime': '2024-01-02 12:12:18.283Z',
//     },
//     'phoneNumber': null,
//     'photoURL':
//     'https://lh3.googleusercontent.com/a/ACg8ocLPgkujTCcjVQw33Tw8oxPnqoWguoLSW2_Adhb1xIQ-=s96-c',
//     'providerData': [
//       {
//         'displayName': 'Junaid Amir',
//         'email': 'junaid.amir077@gmail.com',
//         'phoneNumber': null,
//         'photoURL':
//         'https://lh3.googleusercontent.com/a/ACg8ocLPgkujTCcjVQw33Tw8oxPnqoWguoLSW2_Adhb1xIQ-=s96-c',
//         'providerId': 'google.com',
//         'uid': '114590762936534054643',
//       }
//     ],
//     'refreshToken': null,
//     'tenantId': null,
//     'uid': 'DWgPEKK5f4MsVBVGOTFXDtlo78r2',
//   };
//   print('JSON STRING:' + jsonData.toString());
//   final encodeDedJson=jsonEncode(jsonData);
//   print('json:'+ json.toString());
//   final decodeJson=jsonDecode(encodeDedJson);
//   return GoogleLoginModel.fromMap(decodeJson);
// }