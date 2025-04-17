
import Foundation

struct Prompt {
    let system: String
    let user: String
}

struct PromptBuilder {
    static func generatePrompt(with summary: String) -> Prompt {
        let systemMessage = """
        Tu es un assistant santé intelligent. D’après les données physiologiques suivantes, fournis des recommandations personnalisées sur :
        - L'activité physique (intensité, durée)
        - Le sommeil (durée, qualité)
        - L'alimentation (eau, sucre, caféine, etc.)
        - Le stress ou les signes vitaux anormaux

        
        Génère un résumé personnalisé et des conseils en français(Version drole).
        """

        let userMessage = "Voici mes données :\n\n\(summary)"

        return Prompt(system: systemMessage, user: userMessage)
    }
}
