//
//  ResearchGatePaser.swift
//  
//
//  Created by Thang Ngo Quoc on 20.9.2022.
//

import Foundation
import Alamofire
import SwiftSoup

class ResearchGatePaser {
    
    func getAuthorName(_ article: Article) async -> [String] {
        let encodedArticleName = article.title.stringByAddingPercentEncodingForRFC3986()!
        let urlString = "https://www.researchgate.net/search/publication?q=" + encodedArticleName
        
        do {
            let result = try await AF.request(urlString).serializingString().result.get()
            return try getArticleUrl(source: result, title: article.title)
        } catch {
            print("Error getting source from \(urlString) with \(error)")
        }
        
        return []
    }
    
    private func getArticleUrl(source: String, title: String) throws -> [String] {
        let doc = try SwiftSoup.parse(source)
        let divs = try doc.getElementsByClass("nova-legacy-o-stack__item")
        var result = [String]()
        
        try divs.forEach {
            let link = try $0.getElementsByClass("nova-legacy-e-link").first()
            let t = try link?.text().replacingOccurrences(of: "’", with: "'")
            if t?.lowercased() == title.lowercased() {
                let spans = try $0.getElementsByClass("nova-legacy-v-person-inline-item__fullname")
                spans.forEach {
                    result.append(try! $0.text())
                }
            }
        }
        return result
    }
}
