import Foundation
import HealthKit

class HealthKitManager: ObservableObject {
    @Published var biologicalSex: HKBiologicalSex? = nil
    @Published var dateOfBirth: Date? = nil
    @Published var age: Int? = nil
    @Published var steps: [DailyQuantity] = []
    @Published var heartRateHistory: [DailyQuantity] = []
    @Published var heartRate: Double = 0
    @Published var restingHeartRate: Double = 0
    @Published var oxygenSaturation: Double = 0
    @Published var sleepSamples: [HKCategorySample] = []
    @Published var calories: Double = 0
    @Published var bodyMass: Double = 0
    @Published var height: Double = 0
    @Published var bodyFatPercentage: Double = 0
    @Published var bmi: Double = 0
    @Published var respiratoryRate: Double = 0
    @Published var mindfulMinutes: [HKCategorySample] = []
    @Published var water: Double = 0
    @Published var dietarySugar: Double = 0
    @Published var distanceWalking: Double = 0
    @Published var distanceCycling: Double = 0
    @Published var flightsClimbed: Double = 0
    @Published var standTime: Double = 0
    @Published var exerciseTime: Double = 0
    @Published var walkingSpeed: Double = 0
    @Published var walkingStepLength: Double = 0
    @Published var walkingDoubleSupport: Double = 0
    @Published var walkingAsymmetry: Double = 0
    @Published var dietaryCarbs: Double = 0
    @Published var dietaryProtein: Double = 0
    @Published var dietaryFat: Double = 0
    @Published var dietaryCaffeine: Double = 0
    @Published var bodyTemperature: Double = 0
    @Published var bloodGlucose: Double = 0
    
    private let healthStore = HKHealthStore()
    
    func demanderAutorisation(completion: @escaping (Bool) -> Void) {
        guard HKHealthStore.isHealthDataAvailable() else {
            completion(false)
            return
        }

        var typesLecture: Set<HKObjectType> = []

        let quantityTypes: [HKQuantityTypeIdentifier] = [
            .stepCount, .heartRate, .restingHeartRate, .oxygenSaturation,
            .activeEnergyBurned, .bodyMass, .height, .bodyFatPercentage,
            .bodyMassIndex, .respiratoryRate, .dietaryWater, .dietarySugar,
            .distanceWalkingRunning, .distanceCycling, .flightsClimbed,
            .appleExerciseTime, .appleStandTime, .walkingSpeed, .walkingStepLength,
            .walkingDoubleSupportPercentage, .walkingAsymmetryPercentage,
            .dietaryCarbohydrates, .dietaryProtein, .dietaryFatTotal,
            .dietaryCaffeine, .bodyTemperature, .bloodGlucose
        ]

        for type in quantityTypes {
            if let qt = HKQuantityType.quantityType(forIdentifier: type) {
                typesLecture.insert(qt)
            }
        }

        if let typeSleep = HKCategoryType.categoryType(forIdentifier: .sleepAnalysis) {
            typesLecture.insert(typeSleep)
        }
        if let typeMindful = HKCategoryType.categoryType(forIdentifier: .mindfulSession) {
            typesLecture.insert(typeMindful)
        }

        typesLecture.insert(HKObjectType.characteristicType(forIdentifier: .biologicalSex)!)
        typesLecture.insert(HKObjectType.characteristicType(forIdentifier: .dateOfBirth)!)

        healthStore.requestAuthorization(toShare: nil, read: typesLecture) { success, _ in
            DispatchQueue.main.async {
                if success {
                    self.lireProfilUtilisateur()
                }
                completion(success)
            }
        }
    }

    func lireProfilUtilisateur() {
        do {
            let dob = try healthStore.dateOfBirthComponents()
            self.dateOfBirth = Calendar.current.date(from: dob)
            if let birthYear = dob.year {
                let currentYear = Calendar.current.component(.year, from: Date())
                self.age = currentYear - birthYear
            }
        } catch {
            print("❌ Erreur lors de la lecture de la date de naissance : \(error.localizedDescription)")
        }

        do {
            let sex = try healthStore.biologicalSex()
            self.biologicalSex = sex.biologicalSex
        } catch {
            print("❌ Erreur lors de la lecture du sexe biologique : \(error.localizedDescription)")
        }
    }

    func lireDerniereValeur(type: HKQuantityTypeIdentifier, unite: HKUnit, completion: @escaping (Double) -> Void) {
        guard let qt = HKQuantityType.quantityType(forIdentifier: type) else { completion(0); return }
        let predicate = HKQuery.predicateForSamples(withStart: Date.distantPast, end: Date())
        let query = HKStatisticsQuery(quantityType: qt, quantitySamplePredicate: predicate, options: .discreteMostRecent) { _, result, _ in
            let valeur = result?.mostRecentQuantity()?.doubleValue(for: unite) ?? 0
            DispatchQueue.main.async { completion(valeur) }
        }
        healthStore.execute(query)
    }

    func lireToutesLesDonnees() {
            lireDerniereValeur(type: .heartRate, unite: HKUnit(from: "count/min")) { self.heartRate = $0 }
            lireDerniereValeur(type: .restingHeartRate, unite: HKUnit(from: "count/min")) { self.restingHeartRate = $0 }
            lireDerniereValeur(type: .oxygenSaturation, unite: .percent()) { self.oxygenSaturation = $0 }
            lireDerniereValeur(type: .activeEnergyBurned, unite: .kilocalorie()) { self.calories = $0 }
            lireDerniereValeur(type: .bodyMass, unite: .gramUnit(with: .kilo)) { self.bodyMass = $0 }
            lireDerniereValeur(type: .height, unite: .meter()) { self.height = $0 }
            lireDerniereValeur(type: .bodyFatPercentage, unite: .percent()) { self.bodyFatPercentage = $0 }
            lireDerniereValeur(type: .bodyMassIndex, unite: .count()) { self.bmi = $0 }
            lireDerniereValeur(type: .respiratoryRate, unite: HKUnit(from: "count/min")) { self.respiratoryRate = $0 }
            lireDerniereValeur(type: .dietaryWater, unite: .liter()) { self.water = $0 }
            lireDerniereValeur(type: .dietarySugar, unite: .gram()) { self.dietarySugar = $0 }
            lireDerniereValeur(type: .distanceWalkingRunning, unite: .meter()) { self.distanceWalking = $0 }
            lireDerniereValeur(type: .distanceCycling, unite: .meter()) { self.distanceCycling = $0 }
            lireDerniereValeur(type: .flightsClimbed, unite: .count()) { self.flightsClimbed = $0 }
            lireDerniereValeur(type: .appleStandTime, unite: .minute()) { self.standTime = $0 }
            lireDerniereValeur(type: .appleExerciseTime, unite: .minute()) { self.exerciseTime = $0 }
            lireDerniereValeur(type: .walkingSpeed, unite: HKUnit(from: "m/s")) { self.walkingSpeed = $0 }
            lireDerniereValeur(type: .walkingStepLength, unite: .meter()) { self.walkingStepLength = $0 }
            lireDerniereValeur(type: .walkingDoubleSupportPercentage, unite: .percent()) { self.walkingDoubleSupport = $0 }
            lireDerniereValeur(type: .walkingAsymmetryPercentage, unite: .percent()) { self.walkingAsymmetry = $0 }
            lireDerniereValeur(type: .dietaryCarbohydrates, unite: .gram()) { self.dietaryCarbs = $0 }
            lireDerniereValeur(type: .dietaryProtein, unite: .gram()) { self.dietaryProtein = $0 }
            lireDerniereValeur(type: .dietaryFatTotal, unite: .gram()) { self.dietaryFat = $0 }
            lireDerniereValeur(type: .dietaryCaffeine, unite: .gramUnit(with: .milli)) { self.dietaryCaffeine = $0 }
            lireDerniereValeur(type: .bodyTemperature, unite: .degreeCelsius()) { self.bodyTemperature = $0 }
            lireDerniereValeur(type: .bloodGlucose, unite: HKUnit(from: "mg/dL")) { self.bloodGlucose = $0 }
            
            lireMinutesPleineConscience()
            lireSommeil(debut: Calendar.current.date(byAdding: .day, value: -30, to: Date()) ?? Date(), fin: Date())
            lirePasQuotidiens(debut: Calendar.current.date(byAdding: .day, value: -30, to: Date()) ?? Date(), fin: Date())
            lireHistoriqueFC()
            
        }
        
    func lireMinutesPleineConscience() {
            guard let type = HKCategoryType.categoryType(forIdentifier: .mindfulSession) else { return }
            let debut = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
            let predicate = HKQuery.predicateForSamples(withStart: debut, end: Date())
            let query = HKSampleQuery(sampleType: type, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { _, samples, _ in
                DispatchQueue.main.async {
                    self.mindfulMinutes = samples as? [HKCategorySample] ?? []
                }
            }
            healthStore.execute(query)
        }
        
    func lireSommeil(debut: Date, fin: Date) {
            guard let type = HKCategoryType.categoryType(forIdentifier: .sleepAnalysis) else { return }
            let predicate = HKQuery.predicateForSamples(withStart: debut, end: fin)
            let query = HKSampleQuery(sampleType: type, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { _, samples, _ in
                DispatchQueue.main.async {
                    self.sleepSamples = samples as? [HKCategorySample] ?? []
                }
            }
            healthStore.execute(query)
        }
        
    func lirePasQuotidiens(debut: Date, fin: Date) {
            guard let qt = HKQuantityType.quantityType(forIdentifier: .stepCount) else { return }
            var interval = DateComponents(); interval.day = 1
            let predicate = HKQuery.predicateForSamples(withStart: debut, end: fin)
            let query = HKStatisticsCollectionQuery(quantityType: qt, quantitySamplePredicate: predicate, options: .cumulativeSum, anchorDate: Calendar.current.startOfDay(for: debut), intervalComponents: interval)
            query.initialResultsHandler = { _, results, _ in
                var donnees: [DailyQuantity] = []
                results?.enumerateStatistics(from: debut, to: fin) { stat, _ in
                    if let quantite = stat.sumQuantity() {
                        donnees.append(DailyQuantity(date: stat.startDate, value: quantite.doubleValue(for: .count())))
                    }
                }
                DispatchQueue.main.async { self.steps = donnees }
            }
            healthStore.execute(query)
        }
        
    func lireHistoriqueFC() {
            guard let qt = HKQuantityType.quantityType(forIdentifier: .heartRate) else { return }
            let calendar = Calendar.current
            let endDate = Date()
            let startDate = calendar.date(byAdding: .day, value: -6, to: endDate) ?? endDate
            let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate)
            var interval = DateComponents()
            interval.day = 1
            let query = HKStatisticsCollectionQuery(
                quantityType: qt,
                quantitySamplePredicate: predicate,
                options: .discreteAverage,
                anchorDate: calendar.startOfDay(for: startDate),
                intervalComponents: interval
            )
            query.initialResultsHandler = { _, results, _ in
                var dailyRates: [DailyQuantity] = []
                results?.enumerateStatistics(from: startDate, to: endDate) { stat, _ in
                    if let quantity = stat.averageQuantity() {
                        let bpm = quantity.doubleValue(for: HKUnit(from: "count/min"))
                        dailyRates.append(DailyQuantity(date: stat.startDate, value: bpm))
                    }
                }
                DispatchQueue.main.async {
                    self.heartRateHistory = dailyRates
                }
            }
            healthStore.execute(query)
        }
    }
    
    struct DailyQuantity: Identifiable {
        let id = UUID()
        let date: Date
        let value: Double
    }
    

