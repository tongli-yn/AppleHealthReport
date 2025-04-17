import Foundation

struct SimpleHealthReport: Codable {
    let heartRate: Double?
    let steps: Int?
    let sleep: Double?
    let bloodPressure: BloodPressure?
    
    struct BloodPressure: Codable {
        let systolic: Double?
        let diastolic: Double?
    }
}


func createHealthReportJSON(heartRate: Double?, steps: Int?, sleep: Double?, bloodPressure: (Double?, Double?)) {
    let report = SimpleHealthReport(
        heartRate: heartRate,
        steps: steps,
        sleep: sleep,
        bloodPressure: SimpleHealthReport.BloodPressure(systolic: bloodPressure.0, diastolic: bloodPressure.1)
    )

    let jsonEncoder = JSONEncoder()
    jsonEncoder.outputFormatting = .prettyPrinted

    do {
        let jsonData = try jsonEncoder.encode(report)
        let jsonString = String(data: jsonData, encoding: .utf8)!
        print("✅ JSON Report Created:\n\(jsonString)")
        
        let fileURL = FileManager.default.temporaryDirectory.appendingPathComponent("HealthReport.json")
        try jsonData.write(to: fileURL)
        print("📁 JSON saved at: \(fileURL)")
    } catch {
        print("❌ Failed to create JSON: \(error.localizedDescription)")
    }
}
