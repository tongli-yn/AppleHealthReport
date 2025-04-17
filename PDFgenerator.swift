import Foundation
import PDFKit
import HealthKit

struct PDFGenerator {
    let manager: HealthKitManager
    let aiSummary: String?
    func generatePDF() -> Data {
        let format = UIGraphicsPDFRendererFormat()
        let metaData: [String: Any] = [
            kCGPDFContextTitle as String: "Rapport de Santé Complet",
            kCGPDFContextAuthor as String: "Mon Application Santé"
        ]
        format.documentInfo = metaData

        let pageRect = CGRect(x: 0, y: 0, width: 595.2, height: 841.8) // A4
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)

        let data = renderer.pdfData { context in
            context.beginPage()
            drawHeader(in: context, pageRect: pageRect)
            drawUserInfo(in: context, pageRect: pageRect)
            
            var currentY = drawCardioSection(in: context, pageRect: pageRect, startY: 180)
            currentY = drawActivitySection(in: context, pageRect: pageRect, startY: currentY + 20)
            currentY = drawBodySection(in: context, pageRect: pageRect, startY: currentY + 20)
            currentY = drawNutritionSection(in: context, pageRect: pageRect, startY: currentY + 20)
            currentY = drawSleepSection(in: context, pageRect: pageRect, startY: currentY + 20)
            
            if currentY > pageRect.height - 100 {
                context.beginPage()
                currentY = 50
            }
            
            drawVitalitySection(in: context, pageRect: pageRect, startY: currentY)
            if let summary = aiSummary {
                context.beginPage()
                _ = drawAIAssessment(in: context, pageRect: pageRect, startY: 50, text: summary)
            }
        }

        return data
    }
    func motivationalSummary() -> String {
        var parts: [String] = []

        // IMC
        switch manager.bmi {
        case ..<18.5:
            parts.append("🦴 Vous êtes un peu léger·ère ! Ajoutez du carburant à cette fusée corporelle. Plus de calories, plus d'énergie, GO ! 💪")
        case 18.5..<25:
            parts.append("🥗 Votre IMC est parfait ! Vous êtes aussi équilibré·e qu’une salade bio en méditation.")
        case 25..<30:
            parts.append("⚖️ Légèrement au-dessus ? Rien d'alarmant ! On se bouge un peu, on mange smart, et hop, retour à la zone verte.")
        default:
            parts.append("🔥 Mission brûlage de gras enclenchée ! Pas de panique, chaque jour est une nouvelle chance. Allez, ON Y VA !")
        }

        // Fréquence cardiaque
        if manager.heartRate < 60 {
            parts.append("🧘‍♂️ Fréquence cardiaque de moine Shaolin détectée. Zen extrême. Trop cool.")
        } else if manager.heartRate <= 100 {
            parts.append("❤️ Fréquence cardiaque ? Royal. Votre cœur bat au rythme d’un tambour zen.")
        } else {
            parts.append("⚡️ Cœur en mode turbo ! Peut-être trop de café ou trop d'amour ? Dans tous les cas, check-up conseillé.")
        }

        // Sommeil
        let sleepHours = calculateSleepDuration()
        if sleepHours < 6 {
            parts.append("😵 Moins de 6h de sommeil ?! Bro, tu veux devenir zombie ? Au lit plus tôt ce soir, et que ça saute !")
        } else if sleepHours <= 9 {
            parts.append("😴 Vous dormez comme un koala sous sédatif. Récupération niveau pro.")
        } else {
            parts.append("⏰ Vous dormez beaucoup... recharge complète activée. Veillez juste à ne pas rater le matin !")
        }

        // Activité
        let steps = manager.steps.last?.value ?? 0
        if steps < 4000 {
            parts.append("🛋️ Alerte canapé ! Levez-vous, bougez, mettez du feu dans vos semelles !")
        } else if steps < 8000 {
            parts.append("🚶 Activité modérée. C’est bien, mais on veut du **🔥🔥🔥** !")
        } else {
            parts.append("🏃 Activité physique : vous êtes une machine de guerre ! Continuez à marcher comme si vous conquériez le monde.")
        }

        parts.append("🚀 **Conclusion :** continuez comme ça. Mangez bien. Buvez de l’eau. Soyez le boss de votre bien-être.")

        return parts.joined(separator: "\n\n")
    }

    private func drawHeader(in context: UIGraphicsPDFRendererContext, pageRect: CGRect) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.locale = Locale(identifier: "fr_FR")
        
        let title = "📊 Rapport de Santé Complet"
        let date = "Date: \(dateFormatter.string(from: Date()))"
        
        let titleAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 24),
            .foregroundColor: UIColor(red: 0.1, green: 0.3, blue: 0.5, alpha: 1)
        ]
        
        let dateAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.italicSystemFont(ofSize: 14),
            .foregroundColor: UIColor.gray
        ]
        
        NSString(string: title).draw(at: CGPoint(x: 50, y: 40), withAttributes: titleAttrs)
        NSString(string: date).draw(at: CGPoint(x: 50, y: 75), withAttributes: dateAttrs)
    }

    private func drawUserInfo(in context: UIGraphicsPDFRendererContext, pageRect: CGRect) {
        let yPosition: CGFloat = 110
        let lineSpacing: CGFloat = 25
        let labelFont = UIFont.boldSystemFont(ofSize: 14)
        let valueFont = UIFont.systemFont(ofSize: 14)
        
        let age = manager.age.map { "\($0) ans" } ?? "Non disponible"
        let sex = manager.biologicalSex.map { sexToString($0) } ?? "Non disponible"

        
        let userData = [
            ("Âge", age),
            ("Sexe biologique", sex),
            ("Taille", String(format: "%.2f m", manager.height)),
            ("Poids", String(format: "%.1f kg", manager.bodyMass))
        ]
        
        for (index, (label, value)) in userData.enumerated() {
            let y = yPosition + CGFloat(index) * 20
            NSString(string: "\(label):").draw(at: CGPoint(x: 50, y: y), withAttributes: [.font: labelFont])
            NSString(string: value).draw(at: CGPoint(x: 200, y: y), withAttributes: [.font: valueFont])
        }
        
        let finalY = yPosition + CGFloat(userData.count) * lineSpacing
            context.cgContext.translateBy(x: 0, y: 30)
    }


    private func drawCardioSection(in context: UIGraphicsPDFRendererContext, pageRect: CGRect, startY: CGFloat) -> CGFloat {
        let title = "❤️ Santé Cardiovasculaire"
        let titleAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 18),
            .foregroundColor: UIColor(red: 0.8, green: 0.2, blue: 0.2, alpha: 1)
        ]
        
        NSString(string: title).draw(at: CGPoint(x: 50, y: startY), withAttributes: titleAttrs)
        
        let cardioData = [
            HealthMetric(
                title: "Fréquence cardiaque",
                definition: "Nombre de battements cardiaques par minute",
                reference: "60-100 bpm (adulte au repos)",
                value: manager.heartRate,
                evaluation: rating(for: manager.heartRate, normalRange: 60...100)
            ),
            HealthMetric(
                title: "FC au repos",
                definition: "Fréquence cardiaque la plus basse pendant l'éveil",
                reference: "50-80 bpm (selon condition physique)",
                value: manager.restingHeartRate,
                evaluation: rating(for: manager.restingHeartRate, normalRange: 50...80)
            ),
            HealthMetric(
                title: "Saturation O2",
                definition: "Niveau d'oxygénation du sang",
                reference: "95-100% (niveau normal)",
                value: manager.oxygenSaturation * 100,
                evaluation: rating(for: manager.oxygenSaturation * 100, normalRange: 95...100)
            ),
            HealthMetric(
                title: "Pression artérielle",
                definition: "Pression systolique/diastolique",
                reference: "<120/<80 mmHg (idéal)",
                value: 0, // 需要实际数据
                evaluation: "Non mesurée"
            )
        ]
        
        return drawMetricsSection(in: context, pageRect: pageRect, startY: startY + 30, metrics: cardioData)
    }


    private func drawActivitySection(in context: UIGraphicsPDFRendererContext, pageRect: CGRect, startY: CGFloat) -> CGFloat {
        let title = "🏃 Activité Physique"
        let titleAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 18),
            .foregroundColor: UIColor(red: 0.2, green: 0.6, blue: 0.2, alpha: 1)
        ]
        
        NSString(string: title).draw(at: CGPoint(x: 50, y: startY), withAttributes: titleAttrs)
        
        let activityData = [
            HealthMetric(
                title: "Pas quotidiens",
                definition: "Nombre total de pas effectués",
                reference: "8,000-10,000 (recommandation générale)",
                value: manager.steps.last?.value ?? 0,
                evaluation: stepsEvaluation()
            ),
            HealthMetric(
                title: "Distance marchée",
                definition: "Distance totale parcourue à pied",
                reference: "5-8 km (objectif journalier)",
                value: manager.distanceWalking / 1000,
                evaluation: distanceEvaluation()
            ),
            HealthMetric(
                title: "Calories dépensées",
                definition: "Énergie dépensée en activité",
                reference: "Varie selon le métabolisme",
                value: manager.calories,
                evaluation: caloriesEvaluation()
            ),
            HealthMetric(
                title: "Temps d'exercice",
                definition: "Minutes d'activité physique modérée à intense",
                reference: "30-60 min/jour (recommandation OMS)",
                value: manager.exerciseTime,
                evaluation: rating(for: manager.exerciseTime, normalRange: 30...60)
            ),
            HealthMetric(
                title: "Temps debout",
                definition: "Minutes passées en position debout",
                reference: "2-4 heures/jour (pour santé métabolique)",
                value: manager.standTime,
                evaluation: rating(for: manager.standTime, normalRange: 120...240)
            )
        ]
        
        return drawMetricsSection(in: context, pageRect: pageRect, startY: startY + 30, metrics: activityData)
    }


    private func drawBodySection(in context: UIGraphicsPDFRendererContext, pageRect: CGRect, startY: CGFloat) -> CGFloat {
        let title = "🏋️ Composition Corporelle"
        let titleAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 18),
            .foregroundColor: UIColor(red: 0.4, green: 0.2, blue: 0.6, alpha: 1)
        ]
        
        NSString(string: title).draw(at: CGPoint(x: 50, y: startY), withAttributes: titleAttrs)
        
        let bodyData = [
            HealthMetric(
                title: "IMC",
                definition: "Indice de Masse Corporelle (poids/taille²)",
                reference: "18.5-24.9 (poids normal)",
                value: manager.bmi,
                evaluation: bmiEvaluation()
            ),
            HealthMetric(
                title: "Masse grasse",
                definition: "Pourcentage de graisse corporelle",
                reference: "Homme: 10-20%, Femme: 18-28%",
                value: manager.bodyFatPercentage * 100,
                evaluation: bodyFatEvaluation()
            ),
            HealthMetric(
                title: "Tour de taille",
                definition: "Circonférence abdominale",
                reference: "Homme <102cm, Femme <88cm",
                value: 0,
                evaluation: "Non mesuré"
            ),
            HealthMetric(
                title: "Masse musculaire",
                definition: "Pourcentage de masse musculaire",
                reference: "Varie selon l'âge et le sexe",
                value: 0,
                evaluation: "Non mesurée"
            )
        ]
        
        return drawMetricsSection(in: context, pageRect: pageRect, startY: startY + 30, metrics: bodyData)
    }

   
    private func drawNutritionSection(in context: UIGraphicsPDFRendererContext, pageRect: CGRect, startY: CGFloat) -> CGFloat {
        let title = "🍎 Nutrition"
        let titleAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 18),
            .foregroundColor: UIColor(red: 0.9, green: 0.5, blue: 0.1, alpha: 1)
        ]
        
        NSString(string: title).draw(at: CGPoint(x: 50, y: startY), withAttributes: titleAttrs)
        
        let nutritionData = [
            HealthMetric(
                title: "Eau consommée",
                definition: "Volume total de liquides ingérés",
                reference: "2-3 L/jour (selon activité)",
                value: manager.water,
                evaluation: waterEvaluation()
            ),
            HealthMetric(
                title: "Glucides",
                definition: "Apports totaux en glucides",
                reference: "45-65% des calories totales",
                value: manager.dietaryCarbs,
                evaluation: "Analyse nutritionnelle recommandée"
            ),
            HealthMetric(
                title: "Protéines",
                definition: "Apports totaux en protéines",
                reference: "1.2-2.0 g/kg de poids",
                value: manager.dietaryProtein,
                evaluation: proteinEvaluation()
            ),
            HealthMetric(
                title: "Lipides",
                definition: "Apports totaux en graisses",
                reference: "20-35% des calories totales",
                value: manager.dietaryFat,
                evaluation: "Analyse nutritionnelle recommandée"
            ),
            HealthMetric(
                title: "Sucres ajoutés",
                definition: "Sucres libres/ajoutés consommés",
                reference: "<25 g/jour (OMS)",
                value: manager.dietarySugar,
                evaluation: rating(for: manager.dietarySugar, upperLimit: 25)
            ),
            HealthMetric(
                title: "Caféine",
                definition: "Consommation totale de caféine",
                reference: "<400 mg/jour (adulte)",
                value: manager.dietaryCaffeine,
                evaluation: rating(for: manager.dietaryCaffeine, upperLimit: 400)
            )
        ]
        
        return drawMetricsSection(in: context, pageRect: pageRect, startY: startY + 30, metrics: nutritionData)
    }


    private func drawSleepSection(in context: UIGraphicsPDFRendererContext, pageRect: CGRect, startY: CGFloat) -> CGFloat {
        let title = "😴 Sommeil"
        let titleAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 18),
            .foregroundColor: UIColor(red: 0.3, green: 0.3, blue: 0.8, alpha: 1)
        ]
        
        NSString(string: title).draw(at: CGPoint(x: 50, y: startY), withAttributes: titleAttrs)
        
        let sleepDuration = calculateSleepDuration()
        let sleepData = [
            HealthMetric(
                title: "Durée de sommeil",
                definition: "Temps total passé à dormir",
                reference: "7-9 heures (adulte)",
                value: sleepDuration,
                evaluation: sleepDurationEvaluation(duration: sleepDuration)
            ),
            HealthMetric(
                title: "Efficacité du sommeil",
                definition: "% de temps passé endormi par rapport au temps au lit",
                reference: ">85% (bonne efficacité)",
                value: calculateSleepEfficiency(),
                evaluation: sleepEfficiencyEvaluation()
            ),
            HealthMetric(
                title: "Heure de coucher",
                definition: "Moment où vous vous endormez",
                reference: "Avant 23h (recommandé)",
                value: 0, // 需要实际数据
                evaluation: bedtimeEvaluation()
            ),
            HealthMetric(
                title: "Réveils nocturnes",
                definition: "Nombre d'éveils pendant la nuit",
                reference: "1-2 (normal)",
                value: Double(manager.sleepSamples.filter { $0.value == HKCategoryValueSleepAnalysis.awake.rawValue }.count),
                evaluation: awakeningsEvaluation()
            )
        ]
        
        return drawMetricsSection(in: context, pageRect: pageRect, startY: startY + 30, metrics: sleepData)
    }

   
    private func drawVitalitySection(in context: UIGraphicsPDFRendererContext, pageRect: CGRect, startY: CGFloat) -> CGFloat {
        let title = "🌡️ Signes Vitaux"
        let titleAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 18),
            .foregroundColor: UIColor(red: 0.8, green: 0.4, blue: 0.0, alpha: 1)
        ]
        
        NSString(string: title).draw(at: CGPoint(x: 50, y: startY), withAttributes: titleAttrs)
        
        let vitalityData = [
            HealthMetric(
                title: "Température corporelle",
                definition: "Température centrale du corps",
                reference: "36-37.5°C (normale)",
                value: manager.bodyTemperature,
                evaluation: rating(for: manager.bodyTemperature, normalRange: 36...37.5)
            ),
            HealthMetric(
                title: "Fréquence respiratoire",
                definition: "Nombre de respirations par minute",
                reference: "12-20/min (adulte au repos)",
                value: manager.respiratoryRate,
                evaluation: rating(for: manager.respiratoryRate, normalRange: 12...20)
            ),
            HealthMetric(
                title: "Glycémie",
                definition: "Concentration de glucose dans le sang",
                reference: "70-140 mg/dL (à jeun <100)",
                value: manager.bloodGlucose,
                evaluation: bloodGlucoseEvaluation()
            ),
            HealthMetric(
                title: "Pleine conscience",
                definition: "Minutes de pratique méditative",
                reference: "5-20 min/jour (bénéfices démontrés)",
                value: Double(manager.mindfulMinutes.count),
                evaluation: mindfulnessEvaluation()
            )
        ]
        
        return drawMetricsSection(in: context, pageRect: pageRect, startY: startY + 30, metrics: vitalityData)
    }

    
    private struct HealthMetric {
        let title: String
        let definition: String
        let reference: String
        let value: Double
        let evaluation: String
    }
    
    private func drawMetricsSection(in context: UIGraphicsPDFRendererContext, pageRect: CGRect, startY: CGFloat, metrics: [HealthMetric]) -> CGFloat {
        var y = startY
        let titleFont = UIFont.boldSystemFont(ofSize: 14)
        let textFont = UIFont.systemFont(ofSize: 12)
        let smallFont = UIFont.systemFont(ofSize: 10)
        let lineHeight: CGFloat = 18
        let itemSpacing: CGFloat = 30
        
        for metric in metrics {
            if y > pageRect.height - 150 {
                context.beginPage()
                y = 50
            }
            
            NSString(string: metric.title).draw(
                at: CGPoint(x: 50, y: y),
                withAttributes: [
                    .font: titleFont,
                    .foregroundColor: UIColor.darkText
                ]
            )
            
            
            let valueText = String(format: "%.1f", metric.value)
            NSString(string: "Valeur: \(valueText)").draw(
                at: CGPoint(x: pageRect.width - 150, y: y),
                withAttributes: [
                    .font: titleFont,
                    .foregroundColor: UIColor(red: 0.1, green: 0.3, blue: 0.5, alpha: 1)
                ]
            )
            
            y += lineHeight
            
            NSString(string: "Définition: \(metric.definition)").draw(
                at: CGPoint(x: 60, y: y),
                withAttributes: [
                    .font: textFont,
                    .foregroundColor: UIColor.darkGray
                ]
            )
            
            y += lineHeight
            NSString(string: "Valeurs de référence: \(metric.reference)").draw(
                at: CGPoint(x: 60, y: y),
                withAttributes: [
                    .font: textFont,
                    .foregroundColor: UIColor.darkGray
                ]
            )
            
            y += lineHeight
            let evaluationColor = metric.evaluation.contains("✅") ? UIColor.systemGreen :
                                metric.evaluation.contains("⚠️") ? UIColor.systemOrange :
                                metric.evaluation.contains("❌") ? UIColor.systemRed :
                                UIColor.darkText
            
            NSString(string: "Évaluation: \(metric.evaluation)").draw(
                at: CGPoint(x: 60, y: y),
                withAttributes: [
                    .font: textFont,
                    .foregroundColor: evaluationColor
                ]
            )
            
            y += itemSpacing
        
            context.cgContext.setStrokeColor(UIColor.lightGray.withAlphaComponent(0.5).cgColor)
            context.cgContext.setLineWidth(0.5)
            context.cgContext.move(to: CGPoint(x: 50, y: y - 10))
            context.cgContext.addLine(to: CGPoint(x: pageRect.width - 50, y: y - 10))
            context.cgContext.strokePath()
        }
        
        return y
    }
    

    
    private func rating(for value: Double, normalRange: ClosedRange<Double>) -> String {
        if value < normalRange.lowerBound { return "⚠️ Bas - Consultez un médecin si persistant" }
        if value > normalRange.upperBound { return "⚠️ Élevé - Consultez un médecin si persistant" }
        return "✅ Normal - Dans les valeurs saines"
    }
    
    private func rating(for value: Double, upperLimit: Double) -> String {
        if value <= 0 { return "❌ Non mesuré" }
        return value <= upperLimit ? "✅ Bon - Dans les limites recommandées" : "⚠️ Trop élevé - Essayez de réduire"
    }
    
    private func stepsEvaluation() -> String {
        let steps = manager.steps.last?.value ?? 0
        switch steps {
        case 0..<4000: return "❌ Sédentaire - Essayez d'augmenter votre activité"
        case 4000..<8000: return "⚠️ Modéré - Ciblez 8,000 pas pour une santé optimale"
        case 8000..<12000: return "✅ Actif - Excellent niveau d'activité"
        default: return "✅ Très actif - Continuez ainsi!"
        }
    }
    
    private func distanceEvaluation() -> String {
        let distance = manager.distanceWalking / 1000
        switch distance {
        case 0..<3: return "⚠️ Faible - Essayez de marcher davantage"
        case 3..<5: return "✅ Modéré - Bon niveau d'activité"
        case 5..<8: return "✅ Élevé - Excellent pour la santé cardiovasculaire"
        default: return "✅ Très élevé - Activité physique intensive"
        }
    }
    
    private func caloriesEvaluation() -> String {
        let calories = manager.calories
        switch calories {
        case 0..<200: return "⚠️ Très faible - Augmentez votre activité"
        case 200..<400: return "⚠️ Faible - Essayez d'être plus actif"
        case 400..<600: return "✅ Modéré - Bon niveau d'activité"
        default: return "✅ Élevé - Dépense énergétique importante"
        }
    }
    
    private func bmiEvaluation() -> String {
        switch manager.bmi {
        case ..<18.5: return "⚠️ Insuffisance pondérale - Consultez un nutritionniste"
        case 18.5..<25: return "✅ Poids normal - Maintenez vos habitudes saines"
        case 25..<30: return "⚠️ Surpoids - Essayez de modifier votre alimentation et activité"
        default: return "❌ Obésité - Consultez un professionnel de santé"
        }
    }
    
    private func bodyFatEvaluation() -> String {
        let bodyFat = manager.bodyFatPercentage * 100
        let isMale = manager.biologicalSex == .male
        
        if isMale {
            switch bodyFat {
            case ..<5: return "❌ Dangereusement bas - Risque pour la santé"
            case 5..<13: return "✅ Athlétique - Très faible masse grasse"
            case 13..<18: return "✅ En forme - Niveau sain"
            case 18..<25: return "⚠️ Acceptable - Peut être amélioré"
            default: return "❌ Trop élevé - Risque accru de problèmes de santé"
            }
        } else {
            switch bodyFat {
            case ..<12: return "❌ Dangereusement bas - Risque pour la santé"
            case 12..<20: return "✅ Athlétique - Très faible masse grasse"
            case 20..<25: return "✅ En forme - Niveau sain"
            case 25..<32: return "⚠️ Acceptable - Peut être amélioré"
            default: return "❌ Trop élevé - Risque accru de problèmes de santé"
            }
        }
    }
    
    private func waterEvaluation() -> String {
        let water = manager.water
        switch water {
        case ..<1: return "❌ Dangereusement bas - Risque de déshydratation"
        case 1..<1.5: return "⚠️ Insuffisant - Buvez plus d'eau"
        case 1.5..<2.5: return "✅ Adéquat - Bon niveau d'hydratation"
        default: return "✅ Excellent - Hydratation optimale"
        }
    }
    
    private func proteinEvaluation() -> String {
        guard manager.bodyMass > 0 else { return "❌ Données manquantes" }
        
        let proteinNeeds = manager.bodyMass * 1.2
        let protein = manager.dietaryProtein
        
        if protein <= 0 {
            return "❌ Non mesuré - Assurez un apport suffisant"
        } else if protein < proteinNeeds * 0.7 {
            return "❌ Très insuffisant (\(String(format: "%.1f", protein))g) - Risque de perte musculaire"
        } else if protein < proteinNeeds {
            return "⚠️ Légèrement insuffisant (\(String(format: "%.1f", protein))g) - Cible: \(String(format: "%.1f", proteinNeeds))g"
        } else if protein < proteinNeeds * 1.5 {
            return "✅ Adéquat (\(String(format: "%.1f", protein))g) - Apport optimal"
        } else {
            return "✅ Élevé (\(String(format: "%.1f", protein))g) - Convient aux sportifs"
        }
    }
    
    private func bloodGlucoseEvaluation() -> String {
        let glucose = manager.bloodGlucose
        switch glucose {
        case ..<70: return "❌ Hypoglycémie - Risque de malaise"
        case 70..<100: return "✅ Normal - Niveau optimal"
        case 100..<126: return "⚠️ Élevé - Prédiabète possible"
        default: return "❌ Très élevé - Risque de diabète"
        }
    }
    
    private func mindfulnessEvaluation() -> String {
        let minutes = manager.mindfulMinutes.count
        switch minutes {
        case 0: return "❌ Aucune pratique - La méditation réduit le stress"
        case 1..<5: return "⚠️ Occasionnelle - Essayez 5-10 min/jour"
        case 5..<10: return "✅ Régulière - Bonne habitude"
        case 10..<20: return "✅ Excellente - Effets bénéfiques démontrés"
        default: return "✅ Exceptionnelle - Très bénéfique pour la santé mentale"
        }
    }
    
    private func calculateSleepDuration() -> Double {
        let sleepMinutes = manager.sleepSamples
            .filter { $0.value == HKCategoryValueSleepAnalysis.asleep.rawValue }
            .reduce(0) { $0 + $1.endDate.timeIntervalSince($1.startDate) / 60 }
        return sleepMinutes / 60
    }
    
    private func sleepDurationEvaluation(duration: Double) -> String {
        switch duration {
        case ..<5: return "❌ Dangereusement insuffisant (\(String(format: "%.1f", duration))h) - Risque accru de problèmes de santé"
        case 5..<6: return "⚠️ Insuffisant (\(String(format: "%.1f", duration))h) - Fatigue probable"
        case 6..<7: return "⚠️ Légèrement insuffisant (\(String(format: "%.1f", duration))h) - Ciblez 7-9h"
        case 7..<9: return "✅ Optimal (\(String(format: "%.1f", duration))h) - Durée recommandée"
        case 9..<10: return "✅ Long (\(String(format: "%.1f", duration))h) - Peut convenir selon les besoins"
        default: return "⚠️ Très long (\(String(format: "%.1f", duration))h) - Peut indiquer un problème sous-jacent"
        }
    }
    
    private func calculateSleepEfficiency() -> Double {
        let totalSleepTime = manager.sleepSamples
            .filter { $0.value == HKCategoryValueSleepAnalysis.asleep.rawValue }
            .reduce(0) { $0 + $1.endDate.timeIntervalSince($1.startDate) }
        
        let totalTimeInBed = manager.sleepSamples
            .reduce(0) { $0 + $1.endDate.timeIntervalSince($1.startDate) }
        
        guard totalTimeInBed > 0 else { return 0 }
        return (totalSleepTime / totalTimeInBed) * 100
    }
    
    private func sleepEfficiencyEvaluation() -> String {
        let efficiency = calculateSleepEfficiency()
        switch efficiency {
        case ..<75: return "❌ Faible (\(String(format: "%.1f", efficiency))%) - Beaucoup de temps éveillé au lit"
        case 75..<85: return "⚠️ Moyenne (\(String(format: "%.1f", efficiency))%) - Peut être améliorée"
        case 85..<90: return "✅ Bonne (\(String(format: "%.1f", efficiency))%) - Efficacité satisfaisante"
        default: return "✅ Excellente (\(String(format: "%.1f", efficiency))%) - Sommeil très efficace"
        }
    }
    
    private func bedtimeEvaluation() -> String {
        guard let firstSleep = manager.sleepSamples
            .filter({ $0.value == HKCategoryValueSleepAnalysis.asleep.rawValue })
            .min(by: { $0.startDate < $1.startDate }) else {
            return "❌ Non mesuré - Utilisez le suivi du sommeil"
        }
        
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: firstSleep.startDate)
        let minute = calendar.component(.minute, from: firstSleep.startDate)
        let timeString = String(format: "%02d:%02d", hour, minute)
        
        switch hour {
        case ..<22: return "✅ Très tôt (\(timeString)) - Horaire excellent"
        case 22..<23: return "✅ Idéal (\(timeString)) - Correspond aux rythmes circadiens"
        case 23..<24: return "⚠️ Un peu tard (\(timeString)) - Essayez de vous coucher plus tôt"
        case 24..<1: return "⚠️ Tard (\(timeString)) - Peut perturber le cycle de sommeil"
        default: return "❌ Très tard (\(timeString)) - Risque de privation de sommeil"
        }
    }
    
    private func awakeningsEvaluation() -> String {
        let awakenings = manager.sleepSamples.filter { $0.value == HKCategoryValueSleepAnalysis.awake.rawValue }.count
        switch awakenings {
        case 0: return "✅ Aucun - Sommeil continu excellent"
        case 1..<3: return "✅ Normal (\(awakenings)) - Éveils brefs typiques"
        case 3..<5: return "⚠️ Fréquents (\(awakenings)) - Peut affecter la qualité du sommeil"
        default: return "❌ Très fréquents (\(awakenings)) - Consultez un spécialiste du sommeil"
        }
    }
    
    private func sexToString(_ sex: HKBiologicalSex) -> String {
        switch sex {
        case .female: return "Femme"
        case .male: return "Homme"
        case .other: return "Autre"
        default: return "Non spécifié"
        }
    }
    
    private func bloodTypeToString(_ bloodType: HKBloodType) -> String {
        switch bloodType {
        case .aPositive: return "A+"
        case .aNegative: return "A-"
        case .bPositive: return "B+"
        case .bNegative: return "B-"
        case .abPositive: return "AB+"
        case .abNegative: return "AB-"
        case .oPositive: return "O+"
        case .oNegative: return "O-"
        default: return "Inconnu"
        }
    }
    
    private func walkingAnalysisSection(in context: UIGraphicsPDFRendererContext, pageRect: CGRect, startY: CGFloat) -> CGFloat {
        let title = "🚶 Analyse de la Marche"
        let titleAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 18),
            .foregroundColor: UIColor(red: 0.1, green: 0.5, blue: 0.8, alpha: 1)
        ]
        
        NSString(string: title).draw(at: CGPoint(x: 50, y: startY), withAttributes: titleAttrs)
        
        let walkingData = [
            HealthMetric(
                title: "Vitesse de marche",
                definition: "Vitesse moyenne lors de la marche",
                reference: "1.2-1.4 m/s (adulte en bonne santé)",
                value: manager.walkingSpeed,
                evaluation: walkingSpeedEvaluation()
            ),
            HealthMetric(
                title: "Longueur de pas",
                definition: "Distance moyenne entre deux pas",
                reference: "0.7-0.8 m (adulte moyen)",
                value: manager.walkingStepLength,
                evaluation: stepLengthEvaluation()
            ),
            HealthMetric(
                title: "Double support",
                definition: "% du cycle de marche avec les deux pieds au sol",
                reference: "20-40% (selon l'âge)",
                value: manager.walkingDoubleSupport * 100,
                evaluation: doubleSupportEvaluation()
            ),
            HealthMetric(
                title: "Asymétrie de marche",
                definition: "Différence entre les côtés gauche et droit",
                reference: "<10% (idéal)",
                value: manager.walkingAsymmetry * 100,
                evaluation: walkingAsymmetryEvaluation()
            )
        ]
        
        return drawMetricsSection(in: context, pageRect: pageRect, startY: startY + 30, metrics: walkingData)
    }
    
    private func walkingSpeedEvaluation() -> String {
        let speed = manager.walkingSpeed
        switch speed {
        case ..<0.6: return "❌ Très lente - Difficulté à se déplacer"
        case 0.6..<1.0: return "⚠️ Lente - Peut indiquer des problèmes de mobilité"
        case 1.0..<1.4: return "✅ Normale - Vitesse de marche saine"
        default: return "✅ Rapide - Bonne condition physique"
        }
    }
    
    private func stepLengthEvaluation() -> String {
        let length = manager.walkingStepLength
        switch length {
        case ..<0.5: return "❌ Très courte - Possible problème articulaire"
        case 0.5..<0.7: return "⚠️ Courte - Peut être améliorée"
        case 0.7..<0.9: return "✅ Normale - Longueur de pas optimale"
        default: return "✅ Longue - Bonne amplitude de mouvement"
        }
    }
    
    private func doubleSupportEvaluation() -> String {
        let support = manager.walkingDoubleSupport * 100
        switch support {
        case ..<15: return "❌ Très faible - Risque de chute"
        case 15..<25: return "✅ Faible - Jeune adulte en bonne santé"
        case 25..<35: return "✅ Normale - Adulte moyen"
        case 35..<45: return "⚠️ Élevée - Peut indiquer un problème d'équilibre"
        default: return "❌ Très élevée - Difficulté à marcher"
        }
    }
    
    private func walkingAsymmetryEvaluation() -> String {
        let asymmetry = manager.walkingAsymmetry * 100
        switch asymmetry {
        case ..<5: return "✅ Excellente - Symétrie presque parfaite"
        case 5..<10: return "✅ Bonne - Léger déséquilibre acceptable"
        case 10..<15: return "⚠️ Modérée - Possible compensation"
        default: return "❌ Sévère - Consultez un spécialiste"
        }
    }
    
    // MARK: - 呼吸数据
    
    private func respiratorySection(in context: UIGraphicsPDFRendererContext, pageRect: CGRect, startY: CGFloat) -> CGFloat {
        let title = "🌬️ Fonction Respiratoire"
        let titleAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 18),
            .foregroundColor: UIColor(red: 0.3, green: 0.7, blue: 0.9, alpha: 1)
        ]
        
        NSString(string: title).draw(at: CGPoint(x: 50, y: startY), withAttributes: titleAttrs)
        
        let respiratoryData = [
            HealthMetric(
                title: "Fréquence respiratoire",
                definition: "Nombre de respirations par minute",
                reference: "12-20/min (adulte au repos)",
                value: manager.respiratoryRate,
                evaluation: respiratoryRateEvaluation()
            ),
            HealthMetric(
                title: "Capacité vitale",
                definition: "Volume d'air maximal expiré après inspiration",
                reference: "3-5 L (varie selon taille/âge/sexe)",
                value: 0,
                evaluation: "Non mesurée"
            ),
            HealthMetric(
                title: "Débit expiratoire",
                definition: "Débit d'air maximal lors d'une expiration forcée",
                reference: ">300 L/min (adulte sain)",
                value: 0,
                evaluation: "Non mesuré"
            )
        ]
        
        return drawMetricsSection(in: context, pageRect: pageRect, startY: startY + 30, metrics: respiratoryData)
    }
    
    private func respiratoryRateEvaluation() -> String {
        let rate = manager.respiratoryRate
        switch rate {
        case ..<12: return "⚠️ Basse (bradypnée) - Possible problème neurologique"
        case 12..<20: return "✅ Normale - Fréquence saine"
        case 20..<25: return "⚠️ Élevée (tachypnée) - Possible stress ou problème pulmonaire"
        default: return "❌ Très élevée - Consultez un médecin"
        }
    }
    private func drawAIAssessment(in context: UIGraphicsPDFRendererContext, pageRect: CGRect, startY: CGFloat, text: String) -> CGFloat {
        let title = "🧠 Résumé & Conseils Personnalisés"
        let titleAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 18),
            .foregroundColor: UIColor.systemIndigo
        ]
        
        NSString(string: title).draw(at: CGPoint(x: 50, y: startY), withAttributes: titleAttrs)

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = .byWordWrapping
        paragraphStyle.lineSpacing = 6

        let bodyAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 12),
            .foregroundColor: UIColor.darkGray,
            .paragraphStyle: paragraphStyle
        ]

        let attributedText = NSAttributedString(string: text, attributes: bodyAttrs)
        let textRect = CGRect(x: 50, y: startY + 40, width: pageRect.width - 100, height: pageRect.height - startY - 60)
        
        attributedText.draw(in: textRect)

        return textRect.maxY
    
    }

}
