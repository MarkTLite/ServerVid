import 'package:shelf_static/shelf_static.dart';
import 'dart:io'; //for Platform
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart';
import 'package:vid_api_server/vid_api_server.dart';
import 'package:firebase_dart/firebase_dart.dart';

Future main(List<String> arguments) async {
  //create router app
  final app = Router();
  //initialize the pure dart firebase implementation.
  FirebaseDart.setup();

  // If PORT and address env variables are set, listen to it. Otherwise, the default 8080
  final port = int.parse(Platform.environment['PORT'] ?? '8080');
  final address = Platform.environment['BASE_ADDRESS'] ?? 'localhost';

  //Routes
  app.mount('/premiered/', PremVideoApi().router); //video api
  //app.get('/assets/<file|.*>', createStaticHandler('public')); //files
  //app.get('/<name|.*>', _homeHandler); //home

  //add Middleware Pipeline for server
  final handler = Pipeline()
      .addMiddleware(logRequests())
      .addMiddleware(handleCors())
      .addHandler(app);

  //start server
  final server = await shelf_io.serve(handler, address, port);
  print('Serving at http://${server.address.host}:${server.port}');
}

Response _homeHandler(Request request, String name) {
  final indexFile = File('public/index.html').readAsStringSync();
  return Response.ok(indexFile, headers: {'content-type': 'text/html'});
}
