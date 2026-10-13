import 'dart:async';

import 'package:http/http.dart' as http;

/// Supplies the signed-in user's Supabase access token (null if signed out).
typedef TokenProvider = FutureOr<String?> Function();

/// Client for gr0ve's Cloudflare Worker (see cors-proxy-worker.js).
///
/// The worker exposes named routes only ("absences", "lunch/2026/10/05"),
/// answers only browsers on allowed origins, and only for a valid @bergen.org
/// token. The upstream URLs, including the private Google Doc, live in the
/// worker's configuration and never in this package or the web build.
class Proxy {
  Proxy(this.base, {required this.token, http.Client? client})
    : _client = client ?? http.Client() {
    final local = base.host == 'localhost' || base.host == '127.0.0.1';
    if (base.scheme != 'https' && !(local && base.scheme == 'http')) {
      throw ArgumentError.value(base, 'base', 'Proxy must use https');
    }
  }

  final Uri base;
  final TokenProvider token;
  final http.Client _client;

  /// GET [route] (no leading slash) with the user's token attached.
  /// Returns a synthetic 401 if nobody is signed in.
  Future<http.Response> get(
    String route, {
    Duration timeout = const Duration(seconds: 10),
  }) async {
    final t = await token();
    if (t == null || t.isEmpty) return http.Response('Not signed in', 401);
    final root = base.path.endsWith('/') ? base.path : '${base.path}/';
    return _client
        .get(
          base.replace(path: '$root$route'),
          headers: {'Authorization': 'Bearer $t'},
        )
        .timeout(timeout);
  }
}
