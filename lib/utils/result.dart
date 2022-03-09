// 成功または失敗を保持する型

import 'package:flutter/foundation.dart';

abstract class Result<OkType, ErrType> {
  Z match<Z>({@required Z Function(OkType) ok, @required Z Function(ErrType) err});

/// Returns true if this is a right, false otherwise.
//bool get isOk => fold((_) => true, (_) => false);

/// Returns true if this is a Left, false otherwise.
//bool get isErr => !isOk;

//OkType get ok;
//ErrType get err;
}

class Ok<OkType, ErrType> extends Result<OkType, ErrType> {
  final OkType value;

  Ok(this.value);

  @override
  Z match<Z>({@required Z Function(OkType) ok, @required Z Function(ErrType) err}) => ok(value);

//@override
//OkType get ok => value;

//@override
//ErrType get err => null;
}

class Err<OkType, ErrType> extends Result<OkType, ErrType> {
  final ErrType value;

  Err(this.value);

  @override
  Z match<Z>({@required Z Function(OkType) ok, @required Z Function(ErrType) err}) => err(value);

//@override
//OkType get ok => null;

//@override
//ErrType get err => value;
}
