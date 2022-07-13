//
//  APICaller.swift
//  NewsApp
//
//  Created by Вова Пупкин on 13.07.2022.
//

import Foundation

final class APICaller {
    static let shared = APICaller()
    struct Constants {
        static let topHeadlinesURL = URL(string: "https://newsapi.org/v2/top-headlines?country=us&apiKey=ad5b17b1190b449ca635014461e40a5d")
        static let searchUrlString = "https://newsapi.org/v2/everything?sortBy=popularity&apiKey=ad5b17b1190b449ca635014461e40a5d&q="
    }
    private init() {}
    
    public func getTopStories(complition: @escaping (Result<[Article], Error>) -> Void) {
        guard let url = Constants.topHeadlinesURL else {
            return
        }
        let task = URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                complition (.failure(error))
            }
            if let data = data {
                do {
                    let result = try JSONDecoder().decode(APIResponse.self, from: data)
                    print ("Articles: \(result.articles.count)")
                    complition(.success(result.articles))
                }
                catch {
                    complition(.failure(error))
                }
            }
        }
        task.resume()
    }
    
    public func search(with query: String, completion: @escaping (Result<[Article], Error>) -> Void) {
        guard !query.trimmingCharacters(in: .whitespaces).isEmpty else {
            return
        }
        let urltring = Constants.searchUrlString + query
        guard let url = URL(string: urltring) else {
            return
        }
        let task = URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                completion (.failure(error))
            }
            if let data = data {
                do {
                    let result = try JSONDecoder().decode(APIResponse.self, from: data)
                    print ("Articles: \(result.articles.count)")
                    completion(.success(result.articles))
                }
                catch {
                    completion(.failure(error))
                }
            }
        }
        task.resume()
    }
    
}

struct APIResponse: Codable {
    let articles: [Article]
}
struct Article: Codable {
    let source: Source
    let title: String
    let description: String?
    let url: String?
    let urlToImage: String?
    let publishedAt: String
}
struct Source: Codable {
    let name: String
}
