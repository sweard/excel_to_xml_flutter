import 'dart:convert';
import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart';

// Define the C function signatures using Pointer<Int8> for C strings
typedef ExcelToXmlUpdateC = Int32 Function(
    Pointer<Int8> cfgJson, Pointer<Int8> excelPath, Pointer<Int8> xmlDirPath);
typedef ExcelToXmlUpdate = int Function(
    Pointer<Int8> cfgJson, Pointer<Int8> excelPath, Pointer<Int8> xmlDirPath);

typedef ExcelToXmlQuickUpdateC = Int32 Function(
    Pointer<Int8> cfgJson, Pointer<Int8> excelPath, Pointer<Int8> xmlDirPath);
typedef ExcelToXmlQuickUpdate = int Function(
    Pointer<Int8> cfgJson, Pointer<Int8> excelPath, Pointer<Int8> xmlDirPath);

typedef ExcelToXmlGetDefaultConfigC = Pointer<Int8> Function();
typedef ExcelToXmlGetDefaultConfig = Pointer<Int8> Function();

typedef ExcelToXmlFreeStringC = Void Function(Pointer<Int8> ptr);
typedef ExcelToXmlFreeString = void Function(Pointer<Int8> ptr);



class ExcelToXmlLib {
  late DynamicLibrary _lib;
  late ExcelToXmlUpdate _update;
  late ExcelToXmlQuickUpdate _quickUpdate;
  late ExcelToXmlGetDefaultConfig _getDefaultConfig;
  late ExcelToXmlFreeString _freeString;

  ExcelToXmlLib() {
    // Load the dynamic library
    if (Platform.isAndroid) {
      _lib = DynamicLibrary.open('libexcel_to_xml.so');
    } else if (Platform.isIOS) {
      _lib = DynamicLibrary.executable();
    } else if (Platform.isMacOS) {
      _lib = DynamicLibrary.open('libexcel_to_xml.dylib');
    } else if (Platform.isWindows) {
      _lib = DynamicLibrary.open('excel_to_xml.dll');
    } else if (Platform.isLinux) {
      _lib = DynamicLibrary.open('libexcel_to_xml.so');
    } else {
      throw UnsupportedError('Platform ${Platform.operatingSystem} is not supported');
    }

    // Get function pointers
    _update = _lib.lookupFunction<ExcelToXmlUpdateC, ExcelToXmlUpdate>('excel_to_xml_update');
    _quickUpdate = _lib.lookupFunction<ExcelToXmlQuickUpdateC, ExcelToXmlQuickUpdate>('excel_to_xml_quick_update');
    _getDefaultConfig = _lib.lookupFunction<ExcelToXmlGetDefaultConfigC, ExcelToXmlGetDefaultConfig>('excel_to_xml_get_default_config');
    _freeString = _lib.lookupFunction<ExcelToXmlFreeStringC, ExcelToXmlFreeString>('excel_to_xml_free_string');
  }

  /// Update XML files from Excel data
  /// 
  /// Returns true on success, false on failure
  bool update(String cfgJson, String excelPath, String xmlDirPath) {
    final cfgJsonPtr = cfgJson.toNativeUtf8();
    final excelPathPtr = excelPath.toNativeUtf8();
    final xmlDirPathPtr = xmlDirPath.toNativeUtf8();

    try {
      final result = _update(cfgJsonPtr, excelPathPtr, xmlDirPathPtr);
      return result == 0;
    } finally {
      malloc.free(cfgJsonPtr);
      malloc.free(excelPathPtr);
      malloc.free(xmlDirPathPtr);
    }
  }

  /// Quick update XML files from Excel data (uses more memory for better performance)
  /// 
  /// Returns true on success, false on failure
  bool quickUpdate(String cfgJson, String excelPath, String xmlDirPath) {
    final cfgJsonPtr = cfgJson.toNativeUtf8();
    final excelPathPtr = excelPath.toNativeUtf8();
    final xmlDirPathPtr = xmlDirPath.toNativeUtf8();

    try {
      final result = _quickUpdate(cfgJsonPtr, excelPathPtr, xmlDirPathPtr);
      return result == 0;
    } finally {
      malloc.free(cfgJsonPtr);
      malloc.free(excelPathPtr);
      malloc.free(xmlDirPathPtr);
    }
  }

  /// Get the default configuration JSON
  String getDefaultConfig() {
    final configPtr = _getDefaultConfig();
    if (configPtr == nullptr) {
      throw Exception('Failed to get default configuration');
    }

    try {
      return configPtr.cast<Utf8>().toDartString();
    } finally {
      _freeString(configPtr);
    }
  }
}

// 字符串转换辅助函数
class CStringHelper {
  /// 将Dart字符串转换为C字符串指针
  static Pointer<Char> stringToCString(String str) {
    final bytes = utf8.encode(str);
    final ptr = malloc<Char>(bytes.length + 1);
    
    for (int i = 0; i < bytes.length; i++) {
      ptr[i] = bytes[i];
    }
    ptr[bytes.length] = 0; // null terminator
    
    return ptr;
  }
  
  /// 将C字符串指针转换为Dart字符串
  static String cStringToString(Pointer<Char> ptr) {
    if (ptr == nullptr) {
      throw ArgumentError('Null pointer');
    }
    
    final bytes = <int>[];
    var i = 0;
    while (ptr[i] != 0) {
      bytes.add(ptr[i]);
      i++;
    }
    
    return utf8.decode(bytes);
  }

}

// Example usage
void main() {
  final lib = ExcelToXmlLib();
  
  // Get default configuration
  final defaultConfig = lib.getDefaultConfig();
  print('Default configuration: $defaultConfig');
  
  // Example update (replace with actual paths)
  // final success = lib.update(
  //   defaultConfig,
  //   '/path/to/excel/file.xlsx',
  //   '/path/to/xml/directory'
  // );
  // print('Update successful: $success');
}
