import Foundation

enum AIConnectionStatus {
    case idle
    case testing
    case connected
    case notConnected(String)
}

struct AIClient {

    /// Test an OpenAI-compatible Chat Completions endpoint.
    ///
    /// We send a tiny request:
    /// POST {baseURL}/v1/chat/completions
    ///
    /// Requirements (typical for most providers):
    /// - Authorization: Bearer {apiKey}
    /// - JSON body: model + messages
    static func testConnection(baseURL: String, apiKey: String, model: String) async -> Result<String, Error> {
        let trimmedURL = baseURL.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedKey = apiKey.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedModel = model.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedURL.isEmpty else {
            return .failure(NSError(domain: "AIClient", code: 1, userInfo: [NSLocalizedDescriptionKey: "Base URL is empty."]))
        }
        guard !trimmedKey.isEmpty else {
            return .failure(NSError(domain: "AIClient", code: 2, userInfo: [NSLocalizedDescriptionKey: "API Key is empty."]))
        }
        guard !trimmedModel.isEmpty else {
            return .failure(NSError(domain: "AIClient", code: 3, userInfo: [NSLocalizedDescriptionKey: "Model is empty."]))
        }

        // Build endpoint: {baseURL}/v1/chat/completions
        // If user already typed ending with "/", handle safely.
        let endpointString: String = {
            var b = trimmedURL
            while b.hasSuffix("/") { b.removeLast() }
            return b + "/v1/chat/completions"
        }()

        guard let url = URL(string: endpointString) else {
            return .failure(NSError(domain: "AIClient", code: 4, userInfo: [NSLocalizedDescriptionKey: "Invalid Base URL: \(endpointString)"]))
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.timeoutInterval = 12
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(trimmedKey)", forHTTPHeaderField: "Authorization")

        // Minimal OpenAI-compatible payload
        let body: [String: Any] = [
            "model": trimmedModel,
            "messages": [
                ["role": "user", "content": "ping"]
            ],
            "temperature": 0
        ]

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
        } catch {
            return .failure(error)
        }

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            guard let http = response as? HTTPURLResponse else {
                return .failure(NSError(domain: "AIClient", code: 5, userInfo: [NSLocalizedDescriptionKey: "No HTTP response."]))
            }

            // If failed, try to return readable error details
            guard (200...299).contains(http.statusCode) else {
                let raw = String(data: data, encoding: .utf8) ?? ""
                let msg = raw.isEmpty
                ? "HTTP \(http.statusCode) with empty body."
                : "HTTP \(http.statusCode): \(raw)"
                return .failure(NSError(domain: "AIClient", code: http.statusCode, userInfo: [NSLocalizedDescriptionKey: msg]))
            }

            // Basic parse: look for choices[0].message.content or just non-empty body.
            if let json = try? JSONSerialization.jsonObject(with: data, options: []),
               let dict = json as? [String: Any],
               let choices = dict["choices"] as? [[String: Any]],
               let first = choices.first,
               let message = first["message"] as? [String: Any],
               let content = message["content"] as? String,
               !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                return .success(content)
            }

            // If we can't parse content, as long as it's 2xx we treat as connected.
            let raw = String(data: data, encoding: .utf8) ?? ""
            return .success(raw.isEmpty ? "ok" : raw)
        } catch {
            return .failure(error)
        }
    }
}
