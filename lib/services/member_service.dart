import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/member.dart';

class MemberService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'members';

  // Add a new member
  Future<void> addMember(Member member) async {
    await _firestore.collection(_collection).doc(member.id).set(member.toJson());
  }

  // Get all members
  Stream<List<Member>> getAllMembers() {
    return _firestore
        .collection(_collection)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Member.fromJson(doc.data()))
            .toList());
  }

  // Get expired members
  Stream<List<Member>> getExpiredMembers() {
    final now = DateTime.now();
    return _firestore
        .collection(_collection)
        .where('membershipEndDate',
            isLessThan: now.toIso8601String())
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Member.fromJson(doc.data()))
            .toList());
  }

  // Update member
  Future<void> updateMember(Member member) async {
    await _firestore
        .collection(_collection)
        .doc(member.id)
        .update(member.toJson());
  }

  // Delete member
  Future<void> deleteMember(String memberId) async {
    await _firestore.collection(_collection).doc(memberId).delete();
  }
} 