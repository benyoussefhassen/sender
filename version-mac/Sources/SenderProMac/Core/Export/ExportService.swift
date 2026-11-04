import Foundation
import AppKit
import UniformTypeIdentifiers

public enum ExportFormat: String, CaseIterable, Identifiable {
    case excelXLSX = "All Data By Excel (.xlsx)"
    case csvUTF8BOM = "CSV for Excel (.csv)"
    case textTXT = "Text File (.txt)"
    case vcardVCF = "Google Contacts (.vcf)"

    public var id: String { rawValue }
}

@MainActor
public final class ExportService {
    public static let shared = ExportService()
    private init() {}

    // MARK: - Open File Dialog (Import .txt / .csv)
    public func promptImportLines(title: String = "Select File (.txt / .csv)") -> [String] {
        let panel = NSOpenPanel()
        panel.title = title
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        panel.allowsMultipleSelection = false
        panel.allowedContentTypes = [.plainText, .commaSeparatedText, .data]
        guard panel.runModal() == .OK, let url = panel.url else { return [] }
        return readLines(from: url)
    }

    public func readLines(from url: URL) -> [String] {
        guard let data = try? Data(contentsOf: url) else { return [] }
        let str = String(data: data, encoding: .utf8)
            ?? String(data: data, encoding: .utf16)
            ?? String(data: data, encoding: .isoLatin1)
            ?? ""
        return str
            .replacingOccurrences(of: "\r\n", with: "\n")
            .replacingOccurrences(of: "\r", with: "\n")
            .components(separatedBy: "\n")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
    }

    // MARK: - Save Dialog & Export (.xlsx, .csv, .txt, .vcf)
    @discardableResult
    public func promptAndExport(
        columns: [String],
        rows: [[String]],
        format: ExportFormat,
        defaultFileName: String = "SenderPro_Export",
        autoOpenInApp: Bool = true
    ) -> URL? {
        let panel = NSSavePanel()
        let ext: String
        switch format {
        case .excelXLSX: ext = "xlsx"
        case .csvUTF8BOM: ext = "csv"
        case .textTXT: ext = "txt"
        case .vcardVCF: ext = "vcf"
        }
        panel.nameFieldStringValue = "\(defaultFileName).\(ext)"
        panel.canCreateDirectories = true
        guard panel.runModal() == .OK, let url = panel.url else { return nil }

        let ok = exportToURL(url: url, columns: columns, rows: rows, format: format)
        if ok && autoOpenInApp {
            NSWorkspace.shared.open(url)
        }
        return ok ? url : nil
    }

    @discardableResult
    public func exportToURL(
        url: URL,
        columns: [String],
        rows: [[String]],
        format: ExportFormat
    ) -> Bool {
        switch format {
        case .excelXLSX:
            return writeNativeXLSX(to: url, columns: columns, rows: rows)
        case .csvUTF8BOM:
            return writeCSVWithBOM(to: url, columns: columns, rows: rows)
        case .textTXT:
            return writeTXTWithBOM(to: url, rows: rows)
        case .vcardVCF:
            return writeVCF(to: url, rows: rows)
        }
    }

    // MARK: - UTF-8 with BOM CSV (Opens Arabic cleanly in Microsoft Excel & Apple Numbers)
    public func writeCSVWithBOM(to url: URL, columns: [String], rows: [[String]]) -> Bool {
        var lines: [String] = []
        let header = columns.map { escapeCSV($0) }.joined(separator: ",")
        lines.append(header)
        for row in rows {
            let line = (0..<columns.count).map { i in
                escapeCSV(i < row.count ? row[i] : "")
            }.joined(separator: ",")
            lines.append(line)
        }
        let body = "\u{FEFF}" + lines.joined(separator: "\r\n")
        do {
            try body.write(to: url, atomically: true, encoding: .utf8)
            return true
        } catch {
            return false
        }
    }

    // MARK: - UTF-8 with BOM TXT (Matches V08 Telegram keyword encoding requirement)
    public func writeTXTWithBOM(to url: URL, rows: [[String]]) -> Bool {
        let lines = rows.map { $0.joined(separator: "\t") }
        let body = "\u{FEFF}" + lines.joined(separator: "\r\n")
        do {
            try body.write(to: url, atomically: true, encoding: .utf8)
            return true
        } catch {
            return false
        }
    }

    // MARK: - vCard 3.0 (.vcf) Generator (Matches Text As vcf in V10 02:48)
    public func writeVCF(to url: URL, rows: [[String]], contactPrefix: String = "SenderPro_Client") -> Bool {
        var cards: [String] = []
        for (idx, row) in rows.enumerated() {
            let phone = row.first?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            guard !phone.isEmpty else { continue }
            let name = (row.count > 1 && !row[1].isEmpty) ? row[1] : "\(contactPrefix)_\(idx + 1)"
            let vcf = """
            BEGIN:VCARD
            VERSION:3.0
            FN:\(name)
            N:\(name);;;;
            TEL;TYPE=CELL:\(phone)
            END:VCARD
            """
            cards.append(vcf)
        }
        let content = cards.joined(separator: "\r\n")
        do {
            try content.write(to: url, atomically: true, encoding: .utf8)
            return true
        } catch {
            return false
        }
    }

    // MARK: - Native OpenXML (.xlsx) Generator (No external dependencies)
    public func writeNativeXLSX(to url: URL, columns: [String], rows: [[String]]) -> Bool {
        let fm = FileManager.default
        let tempDir = fm.temporaryDirectory.appendingPathComponent("xlsx_\(UUID().uuidString)", isDirectory: true)
        let relsDir = tempDir.appendingPathComponent("_rels", isDirectory: true)
        let xlDir = tempDir.appendingPathComponent("xl", isDirectory: true)
        let xlRelsDir = xlDir.appendingPathComponent("_rels", isDirectory: true)
        let wsDir = xlDir.appendingPathComponent("worksheets", isDirectory: true)

        do {
            try fm.createDirectory(at: relsDir, withIntermediateDirectories: true)
            try fm.createDirectory(at: xlRelsDir, withIntermediateDirectories: true)
            try fm.createDirectory(at: wsDir, withIntermediateDirectories: true)

            let contentTypes = """
            <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
            <Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">
                <Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>
                <Default Extension="xml" ContentType="application/xml"/>
                <Override PartName="/xl/workbook.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet.main+xml"/>
                <Override PartName="/xl/worksheets/sheet1.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.worksheet+xml"/>
            </Types>
            """
            try contentTypes.write(to: tempDir.appendingPathComponent("[Content_Types].xml"), atomically: true, encoding: .utf8)

            let rootRels = """
            <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
            <Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
                <Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" Target="xl/workbook.xml"/>
            </Relationships>
            """
            try rootRels.write(to: relsDir.appendingPathComponent(".rels"), atomically: true, encoding: .utf8)

            let workbookXML = """
            <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
            <workbook xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships">
                <sheets>
                    <sheet name="SenderProData" sheetId="1" r:id="rId1"/>
                </sheets>
            </workbook>
            """
            try workbookXML.write(to: xlDir.appendingPathComponent("workbook.xml"), atomically: true, encoding: .utf8)

            let wbRels = """
            <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
            <Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
                <Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/worksheet" Target="worksheets/sheet1.xml"/>
            </Relationships>
            """
            try wbRels.write(to: xlRelsDir.appendingPathComponent("workbook.xml.rels"), atomically: true, encoding: .utf8)

            var sheetRowsXML = ""
            let allRows = [columns] + rows
            for (rIdx, rData) in allRows.enumerated() {
                let rowNum = rIdx + 1
                var cellsXML = ""
                for (cIdx, val) in rData.enumerated() {
                    let colRef = excelColumnName(cIdx) + "\(rowNum)"
                    let escaped = escapeXML(val)
                    cellsXML += "<c r=\"\(colRef)\" t=\"inlineStr\"><is><t>\(escaped)</t></is></c>"
                }
                sheetRowsXML += "<row r=\"\(rowNum)\">\(cellsXML)</row>"
            }

            let sheetXML = """
            <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
            <worksheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main">
                <sheetData>\(sheetRowsXML)</sheetData>
            </worksheet>
            """
            try sheetXML.write(to: wsDir.appendingPathComponent("sheet1.xml"), atomically: true, encoding: .utf8)

            try? fm.removeItem(at: url)
            let proc = Process()
            proc.executableURL = URL(fileURLWithPath: "/usr/bin/zip")
            proc.currentDirectoryURL = tempDir
            proc.arguments = ["-q", "-r", url.path, "[Content_Types].xml", "_rels", "xl"]
            try proc.run()
            proc.waitUntilExit()
            try? fm.removeItem(at: tempDir)
            return proc.terminationStatus == 0
        } catch {
            try? fm.removeItem(at: tempDir)
            return false
        }
    }

    private func excelColumnName(_ index: Int) -> String {
        var i = index
        var name = ""
        while i >= 0 {
            let rem = i % 26
            name = String(UnicodeScalar(65 + rem)!) + name
            i = (i / 26) - 1
        }
        return name
    }

    private func escapeCSV(_ s: String) -> String {
        if s.contains(",") || s.contains("\"") || s.contains("\n") || s.contains("\r") {
            return "\"" + s.replacingOccurrences(of: "\"", with: "\"\"") + "\""
        }
        return s
    }

    private func escapeXML(_ s: String) -> String {
        s.replacingOccurrences(of: "&", with: "&amp;")
         .replacingOccurrences(of: "<", with: "&lt;")
         .replacingOccurrences(of: ">", with: "&gt;")
         .replacingOccurrences(of: "\"", with: "&quot;")
         .replacingOccurrences(of: "'", with: "&apos;")
    }
}
