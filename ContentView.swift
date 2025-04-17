import SwiftUI
import Charts

struct ContentView: View {
    @StateObject var manager = HealthKitManager()
    @State private var selectedStepRange: Int = 30 // 7 or 30

    var body: some View {
        TabView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("♥️ Données Cardiaques")
                        .font(.title2.bold())
                    CardView {
                        InfoRow(title: "Fréquence cardiaque (7j)", value: manager.heartRate, unit: "bpm")
                        InfoRow(title: "Dernière FC", value: manager.heartRate, unit: "bpm")
                        InfoRow(title: "FC repos (7j)", value: manager.restingHeartRate, unit: "bpm")
                    }

                    Divider()
                    Text("📉 Tendance FC réelle")
                        .font(.headline)

                    Chart(manager.heartRateHistory.prefix(7)) { item in
                        LineMark(
                            x: .value("Date", item.date, unit: .day),
                            y: .value("Fréquence cardiaque", item.value)
                        )
                        .foregroundStyle(.red)
                        .symbol(Circle())
                    }
                    .frame(height: 220)
                    .chartYScale(domain: 40...200)
                }
                .padding()
            }
            .tabItem {
                Label("Cœur", systemImage: "heart.fill")
            }

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("🧬 Vitalité")
                        .font(.title2.bold())
                    CardView {
                        InfoRow(title: "Saturation O2 (7j)", value: manager.oxygenSaturation * 100, unit: "%")
                        InfoRow(title: "Température (7j)", value: manager.bodyTemperature, unit: "°C")
                        InfoRow(title: "Glycémie (7j)", value: manager.bloodGlucose, unit: "mg/dL")
                    }
                }
                .padding()
            }
            .tabItem {
                Label("Vitalité", systemImage: "waveform.path.ecg")
            }

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("🏋️ Poids & Taille")
                        .font(.title2.bold())
                    CardView {
                        InfoRow(title: "Poids", value: manager.bodyMass, unit: "kg")
                        InfoRow(title: "Taille", value: manager.height, unit: "m")
                        InfoRow(title: "Graisse corporelle", value: manager.bodyFatPercentage * 100, unit: "%")
                        InfoRow(title: "IMC", value: manager.bmi, unit: "")
                    }
                }
                .padding()
            }
            .tabItem {
                Label("Mensurations", systemImage: "figure.stand")
            }

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("🏃‍♂️ Activité")
                        .font(.title2.bold())
                    CardView {
                        InfoRow(title: "Calories", value: manager.calories, unit: "kcal")
                        InfoRow(title: "Marche", value: manager.distanceWalking / 1000, unit: "km")
                        InfoRow(title: "Cyclisme", value: manager.distanceCycling / 1000, unit: "km")
                        InfoRow(title: "Étage montés", value: manager.flightsClimbed, unit: "")
                        InfoRow(title: "Temps debout", value: manager.standTime, unit: "min")
                        InfoRow(title: "Exercice", value: manager.exerciseTime, unit: "min")
                    }

                    Divider()
                    Text("📈 Pas")
                        .font(.headline)
                    Picker("Durée", selection: $selectedStepRange) {
                        Text("7 jours").tag(7)
                        Text("30 jours").tag(30)
                    }
                    .pickerStyle(SegmentedPickerStyle())

                    Chart(manager.steps.suffix(selectedStepRange)) { item in
                        BarMark(
                            x: .value("Date", item.date, unit: .day),
                            y: .value("Pas", item.value)
                        )
                        .foregroundStyle(.blue.gradient)
                    }
                    .frame(height: 220)
                }
                .padding()
            }
            .tabItem {
                Label("Activité", systemImage: "figure.walk")
            }

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("🌿 Nutrition")
                        .font(.title2.bold())
                    CardView {
                        InfoRow(title: "Eau", value: manager.water, unit: "L")
                        InfoRow(title: "Sucres", value: manager.dietarySugar, unit: "g")
                        InfoRow(title: "Glucides", value: manager.dietaryCarbs, unit: "g")
                        InfoRow(title: "Proéines", value: manager.dietaryProtein, unit: "g")
                        InfoRow(title: "Lipides", value: manager.dietaryFat, unit: "g")
                        InfoRow(title: "Caféine", value: manager.dietaryCaffeine, unit: "mg")
                    }

                    Divider()
                    Text("🍽️ Répartition Nutritionnelle")
                        .font(.headline)
                    Chart {
                        SectorMark(angle: .value("Glucides", manager.dietaryCarbs), innerRadius: .ratio(0.5))
                            .foregroundStyle(.orange)
                        SectorMark(angle: .value("Protéines", manager.dietaryProtein), innerRadius: .ratio(0.5))
                            .foregroundStyle(.green)
                        SectorMark(angle: .value("Lipides", manager.dietaryFat), innerRadius: .ratio(0.5))
                            .foregroundStyle(.purple)
                    }
                    .frame(height: 220)

                    HStack(spacing: 12) {
                        Label("Glucides", systemImage: "circle.fill").foregroundColor(.orange)
                        Label("Protéines", systemImage: "circle.fill").foregroundColor(.green)
                        Label("Lipides", systemImage: "circle.fill").foregroundColor(.purple)
                    }
                    .font(.caption)
                    .padding(.top, 4)
                }
                .padding()
            }
            .tabItem {
                Label("Nutrition", systemImage: "leaf")
            }

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("🛌 Sommeil & Bien-être")
                        .font(.title2.bold())
                    CardView {
                        InfoRow(title: "Sessions de pleine conscience", value: Double(manager.mindfulMinutes.count), unit: "")
                        InfoRow(title: "Épisodes de sommeil", value: Double(manager.sleepSamples.count), unit: "")
                    }
                    Button("➕ Rafraîchir les données") {
                        manager.demanderAutorisation { success in
                            if success {
                                manager.lireToutesLesDonnees()
                            }
                        }
                    }
                    
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(8)

                }
                .padding()
            }
            .tabItem {
                Label("Repos", systemImage: "bed.double.fill")
            }
        }
        Button("📄 Générer PDF") {
            let prompt = """
            Voici les données de santé :
            - IMC : \(String(format: "%.1f", manager.bmi))
            - Fréquence cardiaque : \(String(format: "%.0f", manager.heartRate))
            - Pas quotidiens : \(Int(manager.steps.last?.value ?? 0))
            - Sommeil : \(String(format: "%.1f", manager.sleepSamples.count)) sessions
            
            Donne un résumé santé + conseils personnalisés en français.
            """
            
                let generator = PDFGenerator(
                    manager: manager,
                    aiSummary: PDFGenerator(manager: manager, aiSummary: nil).motivationalSummary() //
                )
                
                let pdfData = generator.generatePDF()
                
                let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("RapportSante.pdf")
                try? pdfData.write(to: tempURL)
                
                let activityVC = UIActivityViewController(activityItems: [tempURL], applicationActivities: nil)
                UIApplication.shared.windows.first?.rootViewController?.present(activityVC, animated: true, completion: nil)
            }


        .padding()
        .background(Color.green.opacity(0.1))
        .cornerRadius(8)
        .onAppear {
            manager.demanderAutorisation { success in
                if success {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        manager.lireToutesLesDonnees()
                    }
                }
            }
        }
    }
}

struct InfoRow: View {
    var title: String
    var value: Double
    var unit: String

    var body: some View {
        HStack {
            Text(title).frame(maxWidth: .infinity, alignment: .leading)
            Spacer()
            Text(String(format: "%.1f %@", value, unit))
                .font(.body.bold())
                .foregroundColor(.blue)
        }
    }
}

struct CardView<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        VStack(spacing: 12) {
            content
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}
