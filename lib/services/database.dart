import 'package:dommer/models/user.dart';
import 'package:dommer/models/delivery.dart';
import 'package:dommer/shared/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  final String uid;
  DatabaseService({this.uid});
  //Collection reference
  final CollectionReference dommersCollection =
          Firestore.instance.collection('dommers'),
      usersCollection = Firestore.instance.collection('users'),
      deliveriesCollection = Firestore.instance.collection('deliveries');

  //DOMMER FUNCTIONS
  Future updateDommerData(
      String name,
      String lastName,
      String phone,
      String role,
      String store,
      String address,
      int balance,
      bool active,
      String token) async {
    return await dommersCollection.document(uid).setData({
      'name': format(name),
      'lastName': format(lastName) ?? '',
      'phone': phone,
      'role': role,
      'store': store,
      'address': address,
      'balance': balance,
      'active': active,
      'token': token,
    }, merge: true);
  }

  Future updateClientData(String name, String phone, String address,
      String store, String role, String token) async {
    return await usersCollection.document(uid).setData({
      'name': format(name),
      'phone': phone,
      'address': format(address),
      'store': store,
      'role': role,
      'token': token
    }, merge: true);
  }

  Future<List<PersonalInfo>> get dommersInfo async {
    return (await dommersCollection.getDocuments())
        .documents
        .where((d) => d.data['role'] == 'Repartidor')
        .map((p) => PersonalInfo(
            uid: p.documentID,
            name: p.data['name'],
            lastName: p.data['lastName'],
            phone: p.data['phone'],
            role: p.data['role'],
            store: p.data['store'],
            address: p.data['address'] ?? '',
            active: p.data['active'] ?? '',
            balance: p.data['balance'] ?? '',
            token: p.data['token'] ?? ''))
        .toList();
  }

  Future<List<PersonalInfo>> get usersInfo async {
    return (await dommersCollection.getDocuments())
        .documents
        .where((d) => d.data['role'] == 'Cliente')
        .map((p) => PersonalInfo(
            uid: p.documentID,
            name: p.data['name'],
            lastName: p.data['lastName'] ?? '',
            phone: p.data['phone'],
            role: p.data['role'],
            store: p.data['store'],
            address: p.data['address'] ?? '',
            active: p.data['active'] ?? '',
            balance: p.data['balance'] ?? '',
            token: p.data['token'] ?? ''))
        .toList();
  }

  Future setActive(bool active) async {
    return await dommersCollection
        .document(uid)
        .setData({'active': active}, merge: true);
  }

  Future setDommerLocation(double lat, double lng) async {
    return await dommersCollection
        .document(uid)
        .setData({'location': GeoPoint(lat, lng)}, merge: true);
  }

  Future setToken(Future token) async {
    return await dommersCollection
        .document(uid)
        .setData({'token': await token}, merge: true);
  }

  Future addEarning(int price) async {
    return await dommersCollection.document(uid).setData({
      'balance': (await dommersCollection.document(uid).snapshots().first)
              .data['balance'] -
          price
    }, merge: true);
  }

  //DELIVERIES FUNCTIONS
  Future addDelivery(List<String> points, List<String> descriptions,
      List<int> transactions, String user, String dommer, DateTime date) async {
    int _id = await getOrderID(), price = 0;
    transactions.forEach((t) => price = price + (t * 0.7).ceil());
    DocumentSnapshot _snap =
        await dommersCollection.document(user).snapshots().first;
    print(user);
    String _userName = '', _dommerName = '';
    if (dommer != '') {
      _userName = _snap.data['name'] + ' ';
      _snap = await dommersCollection.document(dommer).snapshots().first;
      _dommerName = _snap.data['name'] + ' ' + _snap.data['lastName'];
    }
    return await deliveriesCollection.document(_id.toString()).setData({
      'price': price,
      'points': points,
      'descriptions': descriptions,
      'transactions': transactions,
      'user': user,
      'userName': _userName,
      'dommer': dommer,
      'dommerName': _dommerName,
      'date': date,
      'status': 'En espera'
    }, merge: true);
  }

  Future assignToDommer(int orderId, String dommer) async {
    DocumentSnapshot _snap =
        await dommersCollection.document(dommer).snapshots().first;
    return await deliveriesCollection.document(orderId.toString()).setData({
      'dommer': dommer,
      'dommerName': _snap.data['name'] + ' ' + _snap.data['lastName']
    }, merge: true);
  }

  Future<int> getOrderID() async {
    List<DocumentSnapshot> _docs =
        await deliveriesCollection.getDocuments().then((d) => d.documents);
    return _docs.length;
  }

  Future toStep(int id, String status) async {
    return await deliveriesCollection
        .document(id.toString())
        .setData({'status': status}, merge: true);
  }

  //PersonalInfo from snapshot
  PersonalInfo _personalInfoFromSnapshot(DocumentSnapshot snapshot) {
    return PersonalInfo(
        uid: uid,
        name: snapshot.data['name'],
        lastName: snapshot.data['lastName'] ?? '',
        phone: snapshot.data['phone'],
        role: snapshot.data['role'],
        store: snapshot.data['store'],
        address: snapshot.data['address'] ?? '',
        active: snapshot.data['active'] ?? '',
        balance: snapshot.data['balance'] ?? '',
        token: snapshot.data['token'] ?? '');
  }

  //Get user doc stream
  Stream<PersonalInfo> get personalInfo {
    return dommersCollection
        .document(uid)
        .snapshots()
        .map(_personalInfoFromSnapshot);
  }

  //Delivery list from snapshot
  List<Delivery> _deliveryListFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.documents.map((doc) {
      List<String> _p = [], _d = [];
      List<int> _t = [];
      doc.data['points'].forEach((e) => _p.add(e.toString()));
      doc.data['descriptions'].forEach((e) => _d.add(e.toString()));
      doc.data['transactions'].forEach((e) => _t.add(int.parse(e.toString())));
      return Delivery(
          id: int.parse(doc.documentID),
          price: doc.data['price'],
          points: _p,
          descriptions: _d,
          transactions: _t,
          userId: doc.data['user'],
          userName: doc.data['userName'],
          dommerId: doc.data['dommer'],
          dommerName: doc.data['dommerName'],
          status: doc.data['status'],
          date: DateTime.fromMillisecondsSinceEpoch(
              doc.data['date'].millisecondsSinceEpoch));
    }).toList();
  }

  Stream<List<Delivery>> get deliveries {
    return deliveriesCollection.snapshots().map(_deliveryListFromSnapshot);
  }
}
