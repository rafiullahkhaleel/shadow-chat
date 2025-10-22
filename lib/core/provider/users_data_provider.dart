import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../model/user_model.dart';

final userDataProvider =
    StateNotifierProvider<UsersDataNotifier, UserDataState>((ref) {
      return UsersDataNotifier();
    });

class UsersDataNotifier extends StateNotifier<UserDataState> {
  UsersDataNotifier() : super(UserDataState(users: AsyncValue.loading())) {
    fetchData();
  }
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _usersSubscription;

  Future<void> fetchData() async {
    final uid = _auth.currentUser?.uid;
    _usersSubscription = _firestore
        .collection('chatUsers')
        .where('uid', isNotEqualTo: uid)
        .snapshots()
        .listen(
          (snapshot) {
            final users =
                snapshot.docs
                    .map((doc) => UserModel.fromMap(doc.data()))
                    .toList();
            state = state.copyWith(users: AsyncValue.data(users));
          },
          onError: (error) {
            state = state.copyWith(
              users: AsyncValue.error(error, StackTrace.current),
            );
          },
        );
  }

  isSearch() {
    state = state.copyWith(isSearching: !state.isSearching, searchText: '');
  }

  void updateSearchText(String value) {
    state = state.copyWith(searchText: value);
  }

  List<UserModel> get filteredUsers {
    final allUsers = state.users.value ?? [];
    if (state.searchText.isEmpty) return allUsers;

    final searchLower = state.searchText.toLowerCase();
    return allUsers
        .where((u) => u.name.toLowerCase().contains(searchLower))
        .toList();
  }
}

class UserDataState {
  final AsyncValue<List<UserModel>> users;
  final bool isSearching;
  final String searchText;

  UserDataState({
    required this.users,
    this.isSearching = false,
    this.searchText = '',
  });

  UserDataState copyWith({
    AsyncValue<List<UserModel>>? users,
    bool? isSearching,
    String? searchText,
  }) {
    return UserDataState(
      users: users ?? this.users,
      isSearching: isSearching ?? this.isSearching,
      searchText: searchText ?? this.searchText,
    );
  }
}
