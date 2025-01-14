//
//  newsinfo.swift
//  Share Point
//
//  Created by Dibyo sarkar on 14/1/25.
//


import Foundation

// Represents a single article
struct Article: Codable,Identifiable {
    var id:UUID { UUID()}
    let source: Source
    let author: String?
    let title: String
    let description: String?
    let url: String
    let urlToImage: String?
    let publishedAt: String
}

// Represents the article's source
struct Source: Codable {
    let id: String?
    let name: String
}

// Represents the API response
struct NewsResponse: Codable {
    let totalResults:Int
    let status:String
    var articles: [Article]
}

import Foundation

class ArticleViewModel: ObservableObject {
    @Published var articles: [Article] = [] // Observable array of articles
    @Published var isLoading: Bool = false // Loading indicator
    @Published var errorMessage: String? = nil // Error messages

    private let apiKey = "ac3d3dcbcadb4f7cabca1f7f2b46f8af" // Replace with your News API key
    private let baseURL = "https://newsapi.org/v2/everything?q=tesla&from=2024-12-14&sortBy=publishedAt"

    /// Fetch articles from News API
    func fetchArticles() {
        guard let url = URL(string: "\(baseURL)&apiKey=\(apiKey)") else {
            self.errorMessage = "Invalid API URL."
            return
        }

        self.isLoading = true
        self.errorMessage = nil

        URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                self.isLoading = false

                if let error = error {
                    self.errorMessage = "Failed to fetch articles: \(error.localizedDescription)"
                    return
                }

                guard let data = data else {
                    self.errorMessage = "No data received from the server."
                    return
                }

                do {
                    // Decode the JSON response into NewsResponse
                    let decodedResponse = try JSONDecoder().decode(NewsResponse.self, from: data)
                    self.articles = decodedResponse.articles
                } catch {
                    print("Failed to Decode articles: \(error)")
                    if let jsonString=String(data:data, encoding: .utf8)
                    {
                        print("received JSON: \(jsonString)")
                    }
                    DispatchQueue.main.async {
                    self.errorMessage = "Failed to decode articles: \(error.localizedDescription)"
                    }
                    
                }
            }
        }.resume()
    }
}
