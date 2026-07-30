import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter/cupertino.dart';

class FileUtils {
  static String getFileIdSync(String path) {
    final file = File(path);
    if (!file.existsSync()) {
      throw Exception('[VideoUtils:getFileIdSync]: File Not Found!');
    }

    final fileSize = file.lengthSync();
    final chunk = 1024 * 2; // 2 KB
    final chunkLength = chunk * 3; // 6 KB
    final allBytes = <int>[];

    if (fileSize <= chunkLength) {
      // File သေးရင် တစ်ခုလုံး ဖတ်မယ်
      allBytes.addAll(file.readAsBytesSync());
    } else {
      final raf = file.openSync(mode: FileMode.read);
      try {
        // ၁။ ခေါင်းပိုင်း (Beginning)
        allBytes.addAll(raf.readSync(chunk));

        // ၂။ အလယ်ပိုင်း (Middle)
        final middlePosition = (fileSize ~/ 2) - (chunk ~/ 2);
        raf.setPositionSync(middlePosition);
        allBytes.addAll(raf.readSync(chunk));

        // ၃။ အမြီးပိုင်း (End)
        final endPosition = fileSize - chunk;
        raf.setPositionSync(endPosition);
        allBytes.addAll(raf.readSync(chunk));
      } finally {
        // Error တက်ခဲ့ရင်တောင် File Handle ကို မပျက်မကွက် ပိတ်ပေးမည်
        raf.closeSync();
      }
    }

    // SHA1 Hash တွက်ခြင်း
    final dig = sha1.convert(allBytes);

    // Hash + File Size ကို ပေါင်းပြီး ဒုတိယအကြိမ် Hash ပြုလုပ်ခြင်း
    return sha1.convert(utf8.encode('${dig.toString()}-$fileSize')).toString();
  }

  static Future<String> getFileId(String path) async {
    final file = File(path);
    if (!file.existsSync()) {
      // throw Exception('File Not Found!');
      debugPrint('[VideoUtils:getFileId]: File Not Found!');
      return '';
    }

    final fileSize = file.lengthSync();
    final chunk = 1024 * 2; // 2 KB
    final chunkLength = chunk * 3; // 6 KB
    final allBytes = <int>[];

    if (fileSize <= chunkLength) {
      // File သေးရင် တစ်ခုလုံး ဖတ်မယ်
      allBytes.addAll(await file.readAsBytes());
    } else {
      final raf = await file.open(mode: FileMode.read);
      try {
        // ၁။ ခေါင်းပိုင်း (Beginning)
        allBytes.addAll(await raf.read(chunk));

        // ၂။ အလယ်ပိုင်း (Middle)
        final middlePosition = (fileSize ~/ 2) - (chunk ~/ 2);
        raf.setPositionSync(middlePosition);
        allBytes.addAll(await raf.read(chunk));

        // ၃။ အမြီးပိုင်း (End)
        final endPosition = fileSize - chunk;
        raf.setPositionSync(endPosition);
        allBytes.addAll(await raf.read(chunk));
      } finally {
        // Error တက်ခဲ့ရင်တောင် File Handle ကို မပျက်မကွက် ပိတ်ပေးမည်
        raf.closeSync();
      }
    }

    // SHA1 Hash တွက်ခြင်း
    final dig = sha1.convert(allBytes);

    // Hash + File Size ကို ပေါင်းပြီး ဒုတိယအကြိမ် Hash ပြုလုပ်ခြင်း
    return sha1.convert(utf8.encode('${dig.toString()}-$fileSize')).toString();
  }

  
}
