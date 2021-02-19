import 'package:dommer/services/database.dart';

class Delivery {
  final int id, price;
  final List<String> points, descriptions;
  final List<int> transactions;
  final String userId, userName, dommerId, dommerName, status;
  final DateTime date;

  Delivery(
      {this.id,
      this.price,
      this.points,
      this.descriptions,
      this.transactions,
      this.userId,
      this.userName,
      this.dommerId,
      this.dommerName,
      this.status,
      this.date});
  int get step {
    return _status.indexOf(this.status);
  }

  String get nextStep {
    return this.status == 'Entregado'
        ? this.status
        : _status[_status.indexOf(status) + 1];
  }

  String get backStep {
    return this.status == 'En espera'
        ? this.status
        : _status[_status.indexOf(status) - 1];
  }

  String get toDo {
    return [
      'Dirígete hacia ${this.points.first}',
      (this.transactions.first > 0 ? 'Cobra ' : 'Deberás pagar ') +
          '${this.transactions.first}',
      (this.transactions.last > 0 ? 'Cobra ' : 'Deberás pagar ') +
          '${this.transactions.last}',
      ''
    ][step];
  }

  String get shortDate {
    DateTime _now = DateTime.now();
    return date.month == _now.month && date.day == _now.day
        ? 'Hoy a las ${date.hour}:${date.minute}'
        : '${date.day} / ${date.month} / ${date.year}';
  }

  List<String> _status = ['En espera', 'Recogiendo', 'Entregando', 'Entregado'];
  void toStep(bool next) {
    DatabaseService db = DatabaseService(uid: dommerId);
    if (next && step < 3) db.toStep(this.id, _status[step + 1]);
    if (!next && step > 0) db.toStep(this.id, _status[step - 1]);
    if (step == 2) db.addEarning(price);
  }
}
