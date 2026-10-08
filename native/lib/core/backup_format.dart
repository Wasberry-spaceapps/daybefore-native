import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:cryptography/cryptography.dart';

const _magic = [0x44, 0x42, 0x42, 0x4B]; // "DBBK"
const _version = [0x00, 0x01];
const _headerSize = 58;

Future<Uint8List> createBackup(
  String accountId,
  SecretKey encryptionKey,
  Map<String, dynamic> allData,
) async {
  final payload = utf8.encode(jsonEncode(allData));

  final aes = AesGcm.with256bits();
  final secretBox = await aes.encrypt(payload, secretKey: encryptionKey);
  final nonce = Uint8List.fromList(secretBox.nonce);
  final cipherText = Uint8List.fromList(secretBox.cipherText);
  final mac = Uint8List.fromList(secretBox.mac.bytes);

  final sha256 = Sha256();
  final accountHash = await sha256.hash(utf8.encode(accountId));
  final accountHashBytes = Uint8List.fromList(accountHash.bytes);

  final tsBytes = ByteData(8);
  tsBytes.setInt64(0, DateTime.now().millisecondsSinceEpoch);

  final header = Uint8List(_headerSize);
  header.setAll(0, _magic);
  header.setAll(4, _version);
  header.setAll(6, accountHashBytes);
  header.setAll(38, tsBytes.buffer.asUint8List());
  header.setAll(46, nonce);

  final result = Uint8List(_headerSize + cipherText.length + mac.length);
  result.setAll(0, header);
  result.setAll(_headerSize, cipherText);
  result.setAll(_headerSize + cipherText.length, mac);
  return result;
}

Future<Map<String, dynamic>> decryptBackup(
  Uint8List fileBytes,
  SecretKey encryptionKey,
) async {
  if (fileBytes.length < _headerSize + 16) {
    throw const FormatException('File too small to be a valid DBBK backup.');
  }
  if (fileBytes[0] != 0x44 ||
      fileBytes[1] != 0x42 ||
      fileBytes[2] != 0x42 ||
      fileBytes[3] != 0x4B) {
    throw const FormatException('Not a valid Day Before backup file.');
  }

  final nonce = fileBytes.sublist(46, 58);
  final cipherAndTag = fileBytes.sublist(_headerSize);
  final cipherText = cipherAndTag.sublist(0, cipherAndTag.length - 16);
  final macBytes = cipherAndTag.sublist(cipherAndTag.length - 16);

  final aes = AesGcm.with256bits();
  final secretBox = SecretBox(
    cipherText,
    nonce: nonce,
    mac: Mac(macBytes),
  );

  List<int> plainBytes;
  try {
    plainBytes = await aes.decrypt(secretBox, secretKey: encryptionKey);
  } catch (_) {
    throw const FormatException(
      'Backup could not be decrypted. Check that we are signed into the correct account.',
    );
  }

  return jsonDecode(utf8.decode(plainBytes)) as Map<String, dynamic>;
}

String backupChecksumHex(Uint8List fileBytes) {
  var h = 0x811c9dc5;
  for (final b in fileBytes) {
    h ^= b;
    h = (h * 0x01000193) & 0xFFFFFFFF;
  }
  return h.toRadixString(16).padLeft(8, '0');
}

Future<String> sha256Hex(Uint8List data) async {
  final sha = Sha256();
  final hash = await sha.hash(data);
  return hash.bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
}
