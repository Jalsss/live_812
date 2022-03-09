class DeliveryProvider {
  final String _id;
  final String _name;

  String get id => _id;
  String get name => _name;

  DeliveryProvider.fromJson(obj)
    : this._id = obj['id'].toString()
    , this._name = obj['name'];
}
