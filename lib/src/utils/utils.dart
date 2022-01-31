import 'package:shelf/shelf.dart';

Middleware handleCors() {
  // Handle CORS Policy
  final corsHeader = {
    "Access-Control-Allow-Origin": "*",
    "Access-Control-Allow-Methods": "POST,GET,DELETE,PUT,OPTIONS"
  };

  return createMiddleware(
    requestHandler: (Request req) {
      if (req.method == 'OPTIONS') {
        return Response.ok('', headers: corsHeader);
      } else {
        return null;
      }
    },
    responseHandler: (Response res) {
      return res.change(headers: corsHeader);
    },
  );
}
