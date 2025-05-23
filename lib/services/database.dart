import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseMethods {
  Future<void> addUserDetail(
    Map<String, dynamic> userInfoMap,
    String id,
  ) async {
    return await FirebaseFirestore.instance
        .collection("users") // Fixed typo: 'Zollection' -> 'collection'
        .doc(id)
        .set(userInfoMap);
  }
  Future<void> addEvent(
      Map<String, dynamic> userInfoMap,
      String id,
      ) async {
    return await FirebaseFirestore.instance
        .collection("Event") // Fixed typo: 'Zollection' -> 'collection'
        .doc(id)
        .set(userInfoMap);
  }
Future<Stream<QuerySnapshot>> getallEvents()async{
    return await FirebaseFirestore.instance.collection("Event").snapshots();

}
  Future<DocumentReference<Map<String, dynamic>>> addUserBooking(
      Map<String, dynamic> userInfoMap,
      String id,
      ) async {
    return await FirebaseFirestore.instance
        .collection("Event") // Fixed typo: 'Zollection' -> 'collection'
        .doc(id).collection("Booking")
        .add(userInfoMap);
  }

  Future<DocumentReference<Map<String, dynamic>>> addAdminTickets(
      Map<String, dynamic> userInfoMap
      ) async {
    return await FirebaseFirestore.instance
        .collection("Tickets") // Fixed typo: 'Zollection' -> 'collection'
        .add(userInfoMap);
  }
}
// Future<Stream<QuerySnapshot>> getEventCategory(String id,String category)async{
//   return await FirebaseFirestore.instance.collection("Users")
//       .where("Category",isEqualTo: category)
//       .snapshots();
// }

Future<Stream<QuerySnapshot>> getTickets(String id,String category)async{
  return await FirebaseFirestore.instance.collection("Tickets")
      .snapshots();
}

