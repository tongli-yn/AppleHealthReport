import Foundation

class GPTService {
    private let apiKey = "your OpenAI API Key"  
    private let endpoint = "https://api.openai.com/v1/chat/completions"
    
    func generateHealthSummary(from input: String, completion: @escaping (String?) -> Void) {
        let headers = [
            "Authorization": "Bearer \(apiKey)",
            "Content-Type": "application/json"
        ]
        
        let body: [String: Any] = [
            "model": "gpt-4",
            "messages": [
                ["role": "system", "content": "Tu es un assistant médical qui donne des conseils personnalisés en français."],
                ["role": "user", "content": input]
            ],
            "temperature": 0.7
        ]
        
        guard let url = URL(string: endpoint),
              let httpBody = try? JSONSerialization.data(withJSONObject: body) else {
            completion(nil)
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = headers
        request.httpBody = httpBody
        
        URLSession.shared.dataTask(with: request) { data, _, error in
            guard let data = data,
                  let result = try? JSONDecoder().decode(GPTResponse.self, from: data),
                  let text = result.choices.first?.message.content else {
                completion(nil)
                return
            }
            completion(text)
        }.resume()
    }
}

struct GPTResponse: Codable {
    struct Choice: Codable {
        let message: Message
    }
    
    struct Message: Codable {
        let role: String
        let content: String
    }
    
    let choices: [Choice]
}
