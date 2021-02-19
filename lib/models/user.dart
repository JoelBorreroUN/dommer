class User {
  final String uid;
  User({this.uid});
}

class PersonalInfo {
  final String uid, name, lastName, phone, role, store, address, token;
  final int balance;
  final bool active;
  PersonalInfo(
      {this.uid,
      this.name,
      this.lastName,
      this.phone,
      this.role,
      this.store,
      this.address,
      this.balance,
      this.active,
      this.token});
  set active(bool a) => this.active = a;
}
