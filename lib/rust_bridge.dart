import 'dart:ffi';
import 'dart:io';
import 'package:ffi/ffi.dart';

// Rust 结构体的 Dart 表示
sealed class ProcessPaths extends Struct {
  external Pointer<Utf8> jsonPath;
  external Pointer<Utf8> excelPath;
  external Pointer<Utf8> xmlFolderPath;
}

sealed class ProcessResult extends Struct {
  @Bool()
  external bool success;
  external Pointer<Utf8> message;
}

// 函数签名
typedef ProcessExcelToXmlNative = ProcessResult Function(ProcessPaths paths);
typedef ProcessExcelToXmlDart = ProcessResult Function(ProcessPaths paths);

typedef FreeProcessResultNative = Void Function(ProcessResult result);
typedef FreeProcessResultDart = void Function(ProcessResult result);

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

class ConversionResult {
  final bool success;
  final String message;

  ConversionResult({required this.success, required this.message});
}

class RustBridge {
  static final DynamicLibrary _dylib = _openDynamicLibrary();
  
  static final ProcessExcelToXmlDart _processExcelToXml = _dylib
      .lookupFunction<ProcessExcelToXmlNative, ProcessExcelToXmlDart>(
          'process_excel_to_xml');
          
  static final FreeProcessResultDart _freeProcessResult = _dylib
      .lookupFunction<FreeProcessResultNative, FreeProcessResultDart>(
          'free_process_result');

  static DynamicLibrary _openDynamicLibrary() {
    if (Platform.isMacOS) {
      return DynamicLibrary.open('libexcel_to_xml_rust.dylib');
    } else if (Platform.isWindows) {
      return DynamicLibrary.open('excel_to_xml_rust.dll');
    } else if (Platform.isLinux) {
      return DynamicLibrary.open('libexcel_to_xml_rust.so');
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }

  Future<ConversionResult> processExcelToXml(
    String jsonPath,
    String excelPath,
    String xmlFolderPath,
  ) async {
    final paths = calloc<ProcessPaths>();
    
    try {
      paths.ref.jsonPath = jsonPath.toNativeUtf8();
      paths.ref.excelPath = excelPath.toNativeUtf8();
      paths.ref.xmlFolderPath = xmlFolderPath.toNativeUtf8();

      final result = _processExcelToXml(paths.ref);
      
      final message = result.message.toDartString();
      final success = result.success;
      
      // 释放 Rust 分配的内存
      _freeProcessResult(result);
      
      return ConversionResult(success: success, message: message);
    } finally {
      // 释放 Dart 分配的内存
      calloc.free(paths.ref.jsonPath);
      calloc.free(paths.ref.excelPath);
      calloc.free(paths.ref.xmlFolderPath);
      calloc.free(paths);
    }
  }
}