// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account_type.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AccountTypeAdapter extends TypeAdapter<AccountType> {
  @override
  final int typeId = 4;

  @override
  AccountType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return AccountType.PEA;
      case 1:
        return AccountType.CTO;
      case 2:
        return AccountType.AssuranceVie;
      case 3:
        return AccountType.PER;
      case 4:
        return AccountType.Crypto;
      case 5:
        return AccountType.Autre;
      default:
        return AccountType.PEA;
    }
  }

  @override
  void write(BinaryWriter writer, AccountType obj) {
    switch (obj) {
      case AccountType.PEA:
        writer.writeByte(0);
        break;
      case AccountType.CTO:
        writer.writeByte(1);
        break;
      case AccountType.AssuranceVie:
        writer.writeByte(2);
        break;
      case AccountType.PER:
        writer.writeByte(3);
        break;
      case AccountType.Crypto:
        writer.writeByte(4);
        break;
      case AccountType.Autre:
        writer.writeByte(5);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AccountTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
