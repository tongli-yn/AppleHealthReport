//
//  ReportViewController.swift
//  AIdiagme
//
//  Created by 李桐 on 15/04/2025.
//


import UIKit
import HealthKit

class ReportViewController: UIViewController {
    
    let healthManager = HealthKitManager()
    let gptService = GPTService()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        setupGenerateButton()
    }

    // MARK: - UI: 创建一个按钮触发生成
    private func setupGenerateButton() {
        let button = UIButton(type: .system)
        button.setTitle("📄 Générer Rapport Santé", for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 18)
        button.backgroundColor = .systemBlue
        button.tintColor = .white
        button.layer.cornerRadius = 10
        button.addTarget(self, action: #selector(generateReportButtonTapped), for: .touchUpInside)

        button.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(button)

        NSLayoutConstraint.activate([
            button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            button.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            button.widthAnchor.constraint(equalToConstant: 280),
            button.heightAnchor.constraint(equalToConstant: 60)
        ])
    }

    // MARK: - 按钮触发生成报告
    @objc func generateReportButtonTapped() {
        let fakeSummary = "Ceci est un résumé généré automatiquement pour test."

        let generator = PDFGenerator(manager: healthManager, aiSummary: fakeSummary)
        let pdfData = generator.generatePDF()

        let activityVC = UIActivityViewController(activityItems: [pdfData], applicationActivities: nil)
        present(activityVC, animated: true)
    }


    
    private func buildPrompt() -> String {
        let age = healthManager.age ?? 0
        let heartRate = healthManager.heartRate
        let bmi = healthManager.bmi
        let steps = healthManager.steps.last?.value ?? 0
        let protein = healthManager.dietaryProtein
        let sleep = calculateSleepDuration()
        
        return """
        Voici les données de santé d'un utilisateur :
        - Âge : \(age) ans
        - IMC : \(String(format: "%.1f", bmi))
        - Fréquence cardiaque : \(String(format: "%.0f", heartRate)) bpm
        - Durée de sommeil : \(String(format: "%.1f", sleep)) heures
        - Pas quotidiens : \(Int(steps))
        - Protéines journalières : \(Int(protein)) g

        Donne un résumé clair et des conseils personnalisés en français.
        """
    }

   
    private func calculateSleepDuration() -> Double {
        let sleepMinutes = healthManager.sleepSamples
            .filter { $0.value == HKCategoryValueSleepAnalysis.asleep.rawValue }
            .reduce(0) { $0 + $1.endDate.timeIntervalSince($1.startDate) / 60 }
        return sleepMinutes / 60
    }
}
