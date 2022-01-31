import 'dart:convert';

import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:firebase_dart/core.dart';
import 'package:firebase_dart/database.dart';
import 'package:vid_api_server/vid_api_server.dart';

class PremVideoApi {
  final firebaseConfig = Configurations.firebaseConfig;

  // initialize the Firebase App.
  Future<FirebaseApp> initApp() async {
    late FirebaseApp app;

    try {
      app = Firebase.app();
    } catch (e) {
      app = await Firebase.initializeApp(
          options: FirebaseOptions.fromMap(firebaseConfig));
    }

    return app;
  }

  //Router for video requests
  Router get router {
    final router = Router();

    //routes
    router.get('/all', _allVideosGetHandler);
    router.post('/add', _allVideosPostHandler);

    return router;
  }

  Future<Response> _allVideosGetHandler(Request req) async {
    //init Firebase App
    final app = await initApp();
    //access rt_db and desired location
    final db = FirebaseDatabase(
        app: app, databaseURL: firebaseConfig['rt_database_uri']);
    final ref = db.reference().child('serverVid');

    //listen for the location once get the data, then return the JSON
    var responseData;
    await ref.once().then((value) {
      responseData = value.value;
    });
    return Response.ok(json.encode(responseData),
        headers: {'content-type': 'application/json'});
  }

  Future<Response> _allVideosPostHandler(Request req) async {
    //get the data from the request as string
    var vidData = await req.readAsString();
    if (vidData.isEmpty) {
      return Response.notFound(
          jsonEncode({'success': false, 'error': 'No data found'}),
          headers: {'Content-Type': 'application/json'});
    }
    //Access Video details
    final payload = jsonDecode(vidData);
    final vidName = payload['vid_name'];
    final vidThumbnailLink = payload['thumbnail_link'];
    final vidLink = payload['vid_link'];

    //write to the rt_db
    final app = await initApp();
    final db = FirebaseDatabase(
        app: app, databaseURL: firebaseConfig['rt_database_uri']);
    final ref = db.reference().child('Premiered_Videos');
    await ref.set({
      'vid_name': vidName,
      'thumbnail_link': vidThumbnailLink,
      'vid_link': vidLink
    });

    //inform
    return Response.ok(jsonEncode({'success': true}),
        headers: {'Content-Type': 'application/json'});
  }
}
