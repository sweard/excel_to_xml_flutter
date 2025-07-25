import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';

class MainViewModel extends ChangeNotifier {

  MainViewModel() {
    // 初始化时可以设置默认值或执行其他逻辑
  }

  String? _selectedJsonPath;
  String? _selectedExcelPath;
  String? _selectedXmlFolderPath;

  String? get selectedJsonPath => _selectedJsonPath;
  String? get selectedExcelPath => _selectedExcelPath;
  String? get selectedXmlFolderPath => _selectedXmlFolderPath;

  // 选择文件夹的方法
  Future<void> selectFolder() async {
    String? folderPath = await FilePicker.platform.getDirectoryPath();
    if (folderPath != null) {
      _selectedXmlFolderPath = folderPath;
      notifyListeners();
    }
  }

  // 选择JSON文件的方法
  Future<void> selectJsonFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );
    if (result != null) {
      PlatformFile file = result.files.first;
      _selectedJsonPath = file.path;
      notifyListeners();
    }
  }

  // 选择Excel文件的方法
  Future<void> selectExcelFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx', 'xls'],
    );
    if (result != null) {
      PlatformFile file = result.files.first;
      _selectedExcelPath = file.path;
      notifyListeners();
    }
  }
}
