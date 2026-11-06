import 'dart:convert';
import 'dart:io';

/// Information regarding an installed Windows printer.
class WindowsPrinterInfo {
  final String name;
  final bool isDefault;

  const WindowsPrinterInfo({
    required this.name,
    required this.isDefault,
  });
}

/// Service handling raw and formatted print jobs via the Windows Print Spooler.
class WindowsPrinterService {
  /// Queries all installed Windows printers via PowerShell CIM query.
  static Future<List<WindowsPrinterInfo>> getInstalledPrinters() async {
    if (!Platform.isWindows) return [];
    try {
      final res = await Process.run('powershell', [
        '-NoProfile',
        '-Command',
        'Get-CimInstance Win32_Printer | Select-Object Name, Default | ConvertTo-Json',
      ]);
      if (res.exitCode != 0 || res.stdout.toString().trim().isEmpty) return [];
      final decoded = jsonDecode(res.stdout.toString().trim());
      if (decoded is List) {
        return decoded
            .map((e) => WindowsPrinterInfo(
                  name: e['Name'] as String,
                  isDefault: e['Default'] as bool? ?? false,
                ))
            .toList();
      } else if (decoded is Map) {
        return [
          WindowsPrinterInfo(
            name: decoded['Name'] as String,
            isDefault: decoded['Default'] as bool? ?? false,
          ),
        ];
      }
    } catch (_) {}
    return [];
  }

  /// Sends a text receipt file directly to the Windows print spooler.
  /// If [printerName] is omitted, prints to the Windows default printer.
  static Future<bool> printTextFile(File file, {String? printerName}) async {
    if (!Platform.isWindows) return false;
    try {
      final path = file.absolute.path.replaceAll("'", "''");
      final script = printerName != null && printerName.isNotEmpty
          ? "Get-Content -LiteralPath '$path' -Encoding utf8 | Out-Printer -Name '${printerName.replaceAll("'", "''")}'"
          : "Get-Content -LiteralPath '$path' -Encoding utf8 | Out-Printer";

      final res = await Process.run('powershell', [
        '-NoProfile',
        '-Command',
        script,
      ]);
      return res.exitCode == 0;
    } catch (_) {
      return false;
    }
  }

  /// Prints a file using the Windows shell default print verb.
  static Future<bool> printViaShell(File file) async {
    if (!Platform.isWindows) return false;
    try {
      final path = file.absolute.path.replaceAll("'", "''");
      final res = await Process.run('powershell', [
        '-NoProfile',
        '-Command',
        "Start-Process -FilePath '$path' -Verb Print",
      ]);
      return res.exitCode == 0;
    } catch (_) {
      return false;
    }
  }
}

