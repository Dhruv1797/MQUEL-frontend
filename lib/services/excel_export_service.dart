import 'dart:io';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:universal_html/html.dart' as html;

class ExcelExportService {
  static Future<bool> exportPeopleToExcel({
    required List<Map<String, dynamic>> selectedData,
    required List<String> columnHeaders,
    required List<String> columnKeys,
    String? fileName,
  }) async {
    try {
      var excel = Excel.createExcel();
      Sheet sheetObject = excel['People Data'];

      if (excel.sheets.containsKey('Sheet1')) {
        excel.delete('Sheet1');
      }

      for (int i = 0; i < columnHeaders.length; i++) {
        var cell = sheetObject.cell(
          CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0),
        );
        cell.value = TextCellValue(columnHeaders[i]);

        cell.cellStyle = CellStyle(bold: true);
      }

      for (int rowIndex = 0; rowIndex < selectedData.length; rowIndex++) {
        var rowData = selectedData[rowIndex];

        for (int colIndex = 0; colIndex < columnKeys.length; colIndex++) {
          var cell = sheetObject.cell(
            CellIndex.indexByColumnRow(
              columnIndex: colIndex,
              rowIndex: rowIndex + 1,
            ),
          );

          var value = rowData[columnKeys[colIndex]];

          if (value == null) {
            cell.value = TextCellValue('');
          } else if (value is String) {
            cell.value = TextCellValue(value);
          } else if (value is num) {
            cell.value = DoubleCellValue(value.toDouble());
          } else if (value is bool) {
            cell.value = TextCellValue(value.toString());
          } else if (value is Map<String, dynamic>) {
            if (value.containsKey('label')) {
              cell.value = TextCellValue(value['label'].toString());
            } else {
              cell.value = TextCellValue(value.toString());
            }
          } else {
            cell.value = TextCellValue(value.toString());
          }
        }
      }

      for (int i = 0; i < columnHeaders.length; i++) {
        sheetObject.setColumnAutoFit(i);
      }

      fileName ??=
          'people_export_${DateTime.now().millisecondsSinceEpoch}.xlsx';

      if (kIsWeb) {
        return await _saveFileWeb(excel, fileName);
      } else {
        return await _saveFileDesktop(excel, fileName);
      }
    } catch (e) {
      print('Error exporting to Excel: $e');
      return false;
    }
  }

  static Future<bool> _saveFileWeb(Excel excel, String fileName) async {
    try {
      var bytes = excel.save();
      if (bytes != null) {
        final blob = html.Blob([bytes]);
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.document.createElement('a') as html.AnchorElement
          ..href = url
          ..style.display = 'none'
          ..download = fileName;
        html.document.body?.children.add(anchor);
        anchor.click();
        html.document.body?.children.remove(anchor);
        html.Url.revokeObjectUrl(url);
        return true;
      }
      return false;
    } catch (e) {
      print('Error saving file on web: $e');
      return false;
    }
  }

  static Future<bool> _saveFileDesktop(Excel excel, String fileName) async {
    try {
      var bytes = excel.save();
      if (bytes != null) {
        Directory? downloadsDir;

        if (Platform.isWindows) {
          String userProfile = Platform.environment['USERPROFILE'] ?? '';
          if (userProfile.isNotEmpty) {
            downloadsDir = Directory('$userProfile\\Downloads');
          }
        } else if (Platform.isMacOS) {
          String home = Platform.environment['HOME'] ?? '';
          if (home.isNotEmpty) {
            downloadsDir = Directory('$home/Downloads');
          }
        } else if (Platform.isLinux) {
          String home = Platform.environment['HOME'] ?? '';
          if (home.isNotEmpty) {
            downloadsDir = Directory('$home/Downloads');
          }
        }

        downloadsDir ??= await getApplicationDocumentsDirectory();

        if (!await downloadsDir.exists()) {
          await downloadsDir.create(recursive: true);
        }

        String filePath =
            '${downloadsDir.path}${Platform.pathSeparator}$fileName';

        File file = File(filePath);
        await file.writeAsBytes(bytes);

        print('File saved to: $filePath');
        return true;
      }
      return false;
    } catch (e) {
      print('Error saving file on desktop: $e');
      return false;
    }
  }

  static List<String> getPeopleColumnHeaders() {
    return [
      'Name',
      'Designation',
      'City',
      'Organization',
      'Email',
      'Mobile',
      'Attended',
      'Status',
      'Event',
    ];
  }

  static List<String> getPeopleColumnKeys() {
    return [
      'name',
      'designation',
      'city',
      'organization',
      'email',
      'mobile',
      'attended',
      'assignedUnassigned',
      'eventName',
    ];
  }

  static List<String> getLimitedPeopleColumnHeaders() {
    return ['Name', 'Company', 'Designation'];
  }

  static List<String> getLimitedPeopleColumnKeys() {
    return ['name', 'company', 'designation'];
  }
}
