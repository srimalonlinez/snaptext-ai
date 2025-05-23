import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:snaptext_ai/services/Stripe/stripe_api_service.dart';
import 'package:snaptext_ai/services/Stripe/stripe_storage.dart';

//STRIPE PAYMENT INITIALIZATION

Future<void> init({required String name, required String email}) async {
  print("called");

  // Create a new customer
  Map<String, dynamic>? customer = await createCustomer(
    name: name,
    email: email,
  );

  if (customer == null || customer['id'] == null) {
    throw Exception('Failed to create customer.');
  }

  // Create a payment intent
  Map<String, dynamic>? paymentIntent = await createPaymentIntent(
    customer['id'],
  );

  if (paymentIntent == null || paymentIntent['client_secret'] == null) {
    throw Exception('Failed to create payment intent.');
  }

  // Create a credit card
  await createCreditCard(customer['id'], paymentIntent['client_secret']);

  // Retrieve customer payment methods
  Map<String, dynamic>? customerPaymentMethods =
      await getCustomerPaymentMethods(customer['id']);
  if (customerPaymentMethods == null ||
      customerPaymentMethods['data'].isEmpty) {
    throw Exception('Failed to get customer payment methods.');
  }

  // Create a subscription
  Map<String, dynamic>? subscription = await createSubscription(
    customer['id'],
    customerPaymentMethods['data'][0]['id'],
  );

  if (subscription == null || subscription['id'] == null) {
    throw Exception('Failed to create subscription.');
  }

  // Store subscription details
  StripeStorage().storeSubscriptionDetails(
    customerId: customer['id'],
    email: email,
    userName: name,
    subscriptionId: subscription['id'],
    paymentStatus: 'active',
    startDate: DateTime.now(),
    endDate: DateTime.now().add(const Duration(days: 30)),
    planId: 'price_1PtWVREdYSPMuFSGos2c0D1G',
    amountPaid: 4.99,
    currency: 'USD',
    paymentMethod: 'Credit Card',
  );
}

//create customer

Future<Map<String, dynamic>?> createCustomer({
  required String name,
  required String email,
}) async {
  final customerCreationResponse = await stripeApiService(
    endpoint: 'customers',
    requestMethod: ApiServiceMethodType.post,
    requestBody: {
      'name': name,
      'email': email,
      'description': 'Text Extractor Pro Plan',
    },
  );

  return customerCreationResponse;
}

//create payment intent

Future<Map<String, dynamic>?> createPaymentIntent(String customerId) async {
  final paymentIntentCreationResponse = await stripeApiService(
    requestMethod: ApiServiceMethodType.post,
    endpoint: 'setup_intents',
    requestBody: {
      'customer': customerId,
      'automatic_payment_methods[enabled]': 'true',
    },
  );

  return paymentIntentCreationResponse;
}

//create credit card

Future<void> createCreditCard(
  String customerId,
  String paymentIntentClientSecret,
) async {
  await Stripe.instance.initPaymentSheet(
    paymentSheetParameters: SetupPaymentSheetParameters(
      primaryButtonLabel: 'Subscribe \$4.99 monthly',
      style: ThemeMode.light,
      merchantDisplayName: 'Text Extractor Pro Plan',
      customerId: customerId,
      setupIntentClientSecret: paymentIntentClientSecret,
    ),
  );

  await Stripe.instance.presentPaymentSheet();
}

//get customer payment methods

Future<Map<String, dynamic>?> getCustomerPaymentMethods(
  String customerId,
) async {
  final customerPaymentMethodsResponse = await stripeApiService(
    endpoint: 'customers/$customerId/payment_methods',
    requestMethod: ApiServiceMethodType.get,
  );

  return customerPaymentMethodsResponse;
}

//create subscription

Future<Map<String, dynamic>?> createSubscription(
  String customerId,
  String paymentId,
) async {
  final subscriptionCreationResponse = await stripeApiService(
    endpoint: 'subscriptions',
    requestMethod: ApiServiceMethodType.post,
    requestBody: {
      'customer': customerId,
      'items[0][price]': 'price_1RM8Gb2NsikHabpol8THzOqo',
      'default_payment_method': paymentId,
    },
  );

  return subscriptionCreationResponse;
}
