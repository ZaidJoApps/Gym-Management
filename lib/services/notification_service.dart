import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/member.dart';

class NotificationService {
  // You'll need to sign up at fast2sms.com and get your API key
  static const String _fast2smsApiKey = 'YOUR_FAST2SMS_API_KEY';
  static const String _fast2smsApiUrl = 'https://www.fast2sms.com/dev/bulkV2';

  Future<void> sendExpiryReminder(Member member) async {
    try {
      // Format the phone number (remove any spaces, dashes, etc.)
      final phoneNumber = member.phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
      
      // Remove the '+' from the phone number as Fast2SMS doesn't need it
      final cleanPhoneNumber = phoneNumber.startsWith('+') 
          ? phoneNumber.substring(1) 
          : phoneNumber;

      final message = 'Hi ${member.name}, your gym membership has expired. Please renew your membership to continue using our facilities.';

      final response = await http.post(
        Uri.parse(_fast2smsApiUrl),
        headers: {
          'authorization': _fast2smsApiKey,
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'route': 'dlt', // Use DLT route for international SMS
          'numbers': cleanPhoneNumber,
          'message': message,
          'flash': 0,
        }),
      );

      final responseData = json.decode(response.body);
      
      if (responseData['return'] != true) {
        throw Exception('Failed to send SMS: ${responseData['message']}');
      }

      print('SMS sent successfully to $phoneNumber');
      
    } catch (e) {
      print('Error sending SMS: $e');
      rethrow;
    }
  }

  Future<void> sendBulkExpiryReminders(List<Member> expiredMembers) async {
    List<String> failedMembers = [];

    for (var member in expiredMembers) {
      try {
        await sendExpiryReminder(member);
        // Add a delay between messages to stay within rate limits
        await Future.delayed(const Duration(seconds: 1));
      } catch (e) {
        failedMembers.add('${member.name} (${member.phoneNumber})');
        print('Failed to send reminder to ${member.name}: $e');
      }
    }

    if (failedMembers.isNotEmpty) {
      throw Exception(
        'Failed to send reminders to the following members:\n${failedMembers.join("\n")}'
      );
    }
  }
} 