import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;

  Future<void> updateProfile({
    required String fullname,
    required String address,
    required String phone,
  }) async {
    final user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection('users').doc(user.uid).set({
        'fullname': fullname,
        'address': address,
        'phone': phone,
        'email': user.email,
      }, SetOptions(merge: true));
    }
  }

  Future<Map<String, dynamic>?> getUserData() async {
    final user = _auth.currentUser;
    if (user != null) {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      return doc.data();
    }
    return null;
  }
}
