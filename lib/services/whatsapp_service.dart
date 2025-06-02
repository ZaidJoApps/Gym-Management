import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/member.dart';

class WhatsAppService {
  // TODO: Replace these with your actual WhatsApp Business API credentials
  static const String _apiVersion = 'v17.0';
  static const String _phoneNumberId = 'YOUR_PHONE_NUMBER_ID'; // Get this from WhatsApp Business API Dashboard
  static const String _accessToken = 'YOUR_ACCESS_TOKEN'; // Get this from Meta Business Manager
  static const String _templateName = 'membership_expiry'; // Your approved template name

  String get _apiUrl => 'https://graph.facebook.com/$_apiVersion/$_phoneNumberId/messages';

  bool get isConfigured => 
      _phoneNumberId != 'YOUR_PHONE_NUMBER_ID' && 
      _accessToken != 'YOUR_ACCESS_TOKEN';

  Future<void> sendExpiryReminder(Member member) async {
    if (!isConfigured) {
      throw Exception(
        'WhatsApp Business API is not configured. Please update the credentials in WhatsAppService.'
        '\n\nTo configure WhatsApp Business API:'
        '\n1. Go to Meta Business Manager (business.facebook.com)'
        '\n2. Set up WhatsApp Business API'
        '\n3. Create a message template'
        '\n4. Get your Phone Number ID and Access Token'
        '\n5. Update the credentials in lib/services/whatsapp_service.dart'
      );
    }

    try {
      // Format the phone number to ensure it includes country code
      final formattedPhone = _formatPhoneNumber(member.phoneNumber);

      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          'Authorization': 'Bearer $_accessToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'messaging_product': 'whatsapp',
          'to': formattedPhone,
          'type': 'template',
          'template': {
            'name': _templateName,
            'language': {
              'code': 'en',
            },
            'components': [
              {
                'type': 'body',
                'parameters': [
                  {
                    'type': 'text',
                    'text': member.name,
                  },
                  {
                    'type': 'text',
                    'text': member.membershipEndDate.toString().split(' ')[0],
                  }
                ]
              }
            ]
          }
        }),
      );

      if (response.statusCode != 200) {
        print('WhatsApp API Response: ${response.body}');
        throw Exception(
          'Failed to send WhatsApp message. Status code: ${response.statusCode}'
          '\nResponse: ${response.body}'
        );
      }
    } catch (e) {
      print('Error sending WhatsApp message: $e');
      rethrow;
    }
  }

  String _formatPhoneNumber(String phone) {
    // Remove any non-digit characters
    String digits = phone.replaceAll(RegExp(r'[^\d+]'), '');
    
    // If number doesn't start with +, add it
    if (!digits.startsWith('+')) {
      digits = '+$digits';
    }
    
    return digits;
  }

  Future<void> sendBulkExpiryReminders(List<Member> expiredMembers) async {
    if (expiredMembers.isEmpty) return;

    List<String> failedMembers = [];
    
    for (var member in expiredMembers) {
      try {
        await sendExpiryReminder(member);
        // Add a small delay between messages to avoid rate limiting
        await Future.delayed(const Duration(seconds: 1));
      } catch (e) {
        failedMembers.add(member.name);
      }
    }

    if (failedMembers.isNotEmpty) {
      throw Exception(
        'Failed to send reminders to the following members: ${failedMembers.join(", ")}'
      );
    }
  }
} 