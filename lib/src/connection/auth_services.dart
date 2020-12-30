import 'package:app_stories/src/model/authModel.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final _auth = FirebaseAuth.instance;
  Future<AuthModel> createUser({email: String, password: String}) async {
    AuthModel result = new AuthModel();
    try {
      var user = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      result.state = true;
    } catch (e) {
      result.state = false;
      result.showMsg = true;
      result.msgError = e.code;
    }
    return result;
  }

  Future<AuthModel> loginUser({email: String, password: String}) async {
    AuthModel result = new AuthModel();
    try {
      var user = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      result.state = true;
    } catch (e) {
      result.state = false;
      result.showMsg = true;
      result.msgError = e.code;
    }
    return result;
  }
}
