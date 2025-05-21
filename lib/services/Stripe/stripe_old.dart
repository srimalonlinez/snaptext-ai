import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:snaptext_ai/services/Stripe/stripe_api_service.dart';
import 'package:snaptext_ai/services/Stripe/stripe_storage.dart';

Future<void> init({required String name, required String email}) async {
  try {
    // Add debugging logs
    debugPrint('Starting Stripe initialization for user: $email');

    // Create a new customer with error handling and debugging
    debugPrint('Attempting to create customer...');
    Map<String, dynamic>? customer = await createCustomer(
      email: email,
      name: name,
    );

    // Validate customer response with better error handling
    if (customer == null) {
      throw Exception("Customer creation response was null");
    }

    if (customer['id'] == null) {
      // Log the actual response for debugging
      debugPrint('Customer creation failed. Response: $customer');
      throw Exception("Customer creation failed: Missing customer ID");
    }

    debugPrint('Customer created successfully with ID: ${customer["id"]}');

    // Create a new payment intent with error handling
    debugPrint('Creating payment intent...');
    Map<String, dynamic>? paymentIntent = await createPaymentIntent(
      customerId: customer["id"],
    );

    if (paymentIntent == null) {
      throw Exception("Payment intent creation response was null");
    }

    if (paymentIntent["client_secret"] == null) {
      debugPrint('Payment intent creation failed. Response: $paymentIntent');
      throw Exception("Payment intent creation failed: Missing client secret");
    }

    debugPrint('Payment intent created successfully');

    // Present the payment sheet to collect card details
    debugPrint('Presenting payment sheet for card details...');
    try {
      await createCreditCard(
        customerId: customer["id"],
        clientSecret: paymentIntent["client_secret"],
      );
      debugPrint('Credit card added successfully');
    } catch (e) {
      debugPrint('Error creating credit card: $e');
      throw Exception("Failed to add credit card: $e");
    }

    // Retrieve customer payment methods with error handling
    debugPrint('Retrieving customer payment methods...');
    Map<String, dynamic>? customerPaymentMethods =
        await getCustomerPaymentMethods(customerId: customer["id"]);

    if (customerPaymentMethods == null) {
      throw Exception("Customer payment methods response was null");
    }

    if (customerPaymentMethods['data'] == null ||
        customerPaymentMethods['data'].isEmpty) {
      debugPrint(
        'Payment methods retrieval failed. Response: $customerPaymentMethods',
      );
      throw Exception("No payment methods found for customer");
    }

    debugPrint('Payment methods retrieved successfully');

    // Create a subscription with error handling
    debugPrint('Creating subscription...');
    Map<String, dynamic>? subscription = await createSubscription(
      customerId: customer["id"],
      paymentId: customerPaymentMethods['data'][0]['id'],
    );

    if (subscription == null) {
      throw Exception("Subscription creation response was null");
    }

    if (subscription['id'] == null) {
      debugPrint('Subscription creation failed. Response: $subscription');
      throw Exception('Failed to create subscription: Missing subscription ID');
    }

    debugPrint(
      'Subscription created successfully with ID: ${subscription['id']}',
    );

    // Store subscription details in Firebase
    debugPrint('Storing subscription details...');
    await StripeStorage().storeSubscriptionDetails(
      customerId: customer['id'],
      email: email,
      userName: name,
      subscriptionId: subscription['id'],
      paymentStatus: 'active',
      startDate: DateTime.now(),
      endDate: DateTime.now().add(const Duration(days: 30)),
      planId: 'prod_SGfb30QJtnaWKK',
      amountPaid: 4.99,
      currency: 'USD',
      paymentMethod: 'Credit Card',
    );

    debugPrint('Stripe initialization completed successfully');
  } catch (e) {
    debugPrint('Stripe initialization error: $e');
    rethrow; // Rethrow the exception to be handled by the caller
  }
}

// Create customer with improved error handling
Future<Map<String, dynamic>?> createCustomer({
  required String email,
  required String name,
}) async {
  try {
    debugPrint('Making API request to create customer with email: $email');
    final customerCreatingResponse = await stripeApiService(
      requestMethod: ApiServiceMethodType.post,
      endpoint: "customers",
      requestBody: {
        "name": name,
        "email": email,
        "description": "SnapText AI Pro User",
      },
    );

    debugPrint('Customer creation API response: $customerCreatingResponse');
    return customerCreatingResponse;
  } catch (e) {
    debugPrint('Error creating customer: $e');
    return null;
  }
}

// Create payment intent with improved error handling
Future<Map<String, dynamic>?> createPaymentIntent({
  required String customerId,
}) async {
  try {
    debugPrint(
      'Making API request to create payment intent for customer: $customerId',
    );
    final paymentIntentCreationResponse = await stripeApiService(
      requestMethod: ApiServiceMethodType.post,
      endpoint: "setup_intents",
      requestBody: {
        "customer": customerId,
        "automatic_payment_methods[enabled]": true,
      },
    );

    debugPrint(
      'Payment intent creation API response: $paymentIntentCreationResponse',
    );
    return paymentIntentCreationResponse;
  } catch (e) {
    debugPrint('Error creating payment intent: $e');
    return null;
  }
}

// Create a credit card with improved error handling
Future<void> createCreditCard({
  required String customerId,
  required String clientSecret,
}) async {
  try {
    debugPrint('Initializing payment sheet for customer: $customerId');
    await Stripe.instance.initPaymentSheet(
      paymentSheetParameters: SetupPaymentSheetParameters(
        primaryButtonLabel: 'Subscribe \$4.99 monthly',
        style: ThemeMode.light,
        merchantDisplayName: 'SnapText AI Pro Plan',
        customerId: customerId,
        setupIntentClientSecret: clientSecret,
      ),
    );

    debugPrint('Presenting payment sheet to user');
    await Stripe.instance.presentPaymentSheet();
    debugPrint('Payment sheet completed successfully');
  } catch (e) {
    debugPrint('Error in payment sheet: $e');
    throw Exception("Payment sheet error: $e");
  }
}

// Get customer payment methods with improved error handling
Future<Map<String, dynamic>?> getCustomerPaymentMethods({
  required String customerId,
}) async {
  try {
    debugPrint('Retrieving payment methods for customer: $customerId');
    final customerPaymentMethodsResponse = await stripeApiService(
      requestMethod: ApiServiceMethodType.get,
      endpoint: 'customers/$customerId/payment_methods',
    );

    debugPrint('Payment methods API response: $customerPaymentMethodsResponse');
    return customerPaymentMethodsResponse;
  } catch (e) {
    debugPrint('Error retrieving payment methods: $e');
    return null;
  }
}

// Create subscription with improved error handling
Future<Map<String, dynamic>?> createSubscription({
  required String customerId,
  required String paymentId,
}) async {
  try {
    debugPrint(
      'Creating subscription for customer: $customerId with payment method: $paymentId',
    );
    final subscriptionResponse = await stripeApiService(
      requestMethod: ApiServiceMethodType.post,
      endpoint: 'subscriptions',
      requestBody: {
        "customer": customerId,
        "default_payment_method": paymentId,
        'items[0][price]': 'price_1RM8Gb2NsikHabpol8THzOqo',
      },
    );

    debugPrint('Subscription API response: $subscriptionResponse');
    return subscriptionResponse;
  } catch (e) {
    debugPrint('Error creating subscription: $e');
    return null;
  }
}
