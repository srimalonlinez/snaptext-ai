import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

enum ApiServiceMethodType { get, post }

const baseUrl = "https://api.stripe.com/v1";

// ⚠️ Hardcoded secret key for testing ONLY.
// 🔐 NEVER push this to public repos or use in production.
const secretKey =
    "sk_test_51RJMXI2NsikHabpo6fjuwxWI4HoZa4It9WywZN573y85d7xqNMMpUUy1oKvAZri9CYAnZCv3K9j10UPGTKr3apmd00Jb7O79tc";

Future<Map<String, dynamic>> stripeApiService({
  required ApiServiceMethodType requestMethod,
  Map<String, dynamic>? requestBody,
  required String endpoint,
}) async {
  if (secretKey.isEmpty) {
    debugPrint('ERROR: STRIPE_SECRET_KEY is empty');
    throw Exception("Stripe secret key is missing.");
  }

  // Redacted key preview
  debugPrint('Using Stripe key: ${secretKey.substring(0, 8)}...');

  final Map<String, String> requestHeaders = {
    'Content-Type': 'application/x-www-form-urlencoded',
    'Authorization': 'Bearer $secretKey',
  };

  final requestUrl = "$baseUrl/$endpoint";
  debugPrint(
    'Stripe API Request: ${requestMethod.name.toUpperCase()} $requestUrl',
  );

  try {
    http.Response requestResponse;

    if (requestMethod == ApiServiceMethodType.get) {
      debugPrint('Sending GET request to Stripe');
      requestResponse = await http.get(
        Uri.parse(requestUrl),
        headers: requestHeaders,
      );
    } else {
      // POST: Encode body as x-www-form-urlencoded
      String formBody = '';
      if (requestBody != null) {
        formBody = requestBody.entries
            .map(
              (e) =>
                  '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value.toString())}',
            )
            .join('&');
      }

      debugPrint('Sending POST request to Stripe with body: $formBody');
      requestResponse = await http.post(
        Uri.parse(requestUrl),
        headers: requestHeaders,
        body: formBody,
      );
    }

    debugPrint('Stripe response status: ${requestResponse.statusCode}');
    String truncatedBody =
        requestResponse.body.length > 500
            ? '${requestResponse.body.substring(0, 500)}...(truncated)'
            : requestResponse.body;
    debugPrint('Stripe response body: $truncatedBody');

    final Map<String, dynamic> responseData = json.decode(requestResponse.body);

    if (requestResponse.statusCode >= 200 && requestResponse.statusCode < 300) {
      return responseData;
    } else {
      String errorMessage = 'Unknown error';
      if (responseData.containsKey('error')) {
        if (responseData['error'] is Map) {
          errorMessage = responseData['error']['message'] ?? 'Unknown error';
          String errorType = responseData['error']['type'] ?? 'unknown_type';
          String errorCode = responseData['error']['code'] ?? 'unknown_code';
          debugPrint(
            'Stripe API Error: $errorType - $errorCode - $errorMessage',
          );
        } else {
          errorMessage = responseData['error'].toString();
          debugPrint('Stripe API Error: $errorMessage');
        }
      }
      throw Exception("Stripe API Error: $errorMessage");
    }
  } catch (error) {
    debugPrint('Exception in Stripe API call: $error');
    throw Exception("Stripe API request failed: $error");
  }
}
