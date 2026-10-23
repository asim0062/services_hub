import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart'; // Model import kiya

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // 1. Login function
  Future<User?> loginWithEmail(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    } catch (e) {
      throw 'An unknown error occurred.';
    }
  }

  // 2. Naya account banane ka function (Signup)
  Future<User?> signUpWithEmail({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String role,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        final uid = credential.user!.uid;
        await credential.user!.updateDisplayName(name);

        await FirebaseFirestore.instance.collection('users').doc(uid).set({
          'name': name,
          'email': email,
          'phone': phone,
          'role': role,
          'photoUrl': '',
          'isBlocked': false,
          'createdAt': FieldValue.serverTimestamp(),
        });

        return credential.user;
      }
      return null;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    } catch (e) {
      throw 'Error saving data: ${e.toString()}';
    }
  }

  // 3. User ka data Model ki form mein nikalne ke liye
  Future<UserModel?> getUserModel(String uid) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      throw 'Error fetching user data.';
    }
  }

  // 4. Blocked user check karne ke liye
  Future<bool> isUserBlocked(String uid) async {
    final data = await getUserModel(uid);
    if (data != null && data.isBlocked == true) {
      return true;
    }
    return false;
  }

  // 5. Logout function
  Future<void> logout() async {
    await _auth.signOut();
  }

  // 6. Errors handle karna
  String _handleAuthError(FirebaseAuthException e) {
    if (e.code == 'user-not-found') return 'No user found with this email.';
    if (e.code == 'wrong-password') return 'Incorrect password. Please try again.';
    if (e.code == 'invalid-email') return 'The email address is not valid.';
    if (e.code == 'user-disabled') return 'This user account has been disabled.';
    if (e.code == 'network-request-failed') return 'Internet connection problem.';
    if (e.code == 'email-already-in-use') return 'This email is already registered.';
    if (e.code == 'weak-password') return 'Password is too weak.';

    return 'An error occurred. Please try again.';
  }
}