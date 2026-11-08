import 'package:flutter/foundation.dart';

@immutable
class PartCollection {
  const PartCollection(this.name, this.title);

  static const herri = PartCollection('herri', 'Herri');
  static const gyuru = PartCollection('gyuru', 'Gyűrű');
  static const srekk = PartCollection('srekk', 'Srekk');
  static const karib = PartCollection('karib', 'Karib');
  static const pom = PartCollection('pom', '2Pom');
  static const values = [herri, gyuru, srekk, karib, pom];

  final String name;
  final String title;

  @override
  bool operator ==(Object other) =>
      other is PartCollection && name == other.name;

  @override
  int get hashCode => name.hashCode;
}
