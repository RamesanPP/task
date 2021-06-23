import 'package:google_sign_in/google_sign_in.dart';
import '../keys.dart';

class GoogleSignInApi {
  static final _clientIDWeb = gwebkey; //enter web auth id
  static final _googleSignIn = GoogleSignIn(clientId: _clientIDWeb);
  static Future<GoogleSignInAccount?> login() => _googleSignIn.signIn();
  static Future<GoogleSignInAccount?> logout() => _googleSignIn.signOut();
}
