//
//  main.swift
//  
//
//  Created by Thang Ngo Quoc on 20.9.2022.
//

import Foundation
import CSV
import SwiftSoup
import Alamofire
import Algorithms

func main() async throws {
    let articles = loadCSV()
    let parser = ResearchGatePaser()
    var output = [ArticleOutput]()
    for a in articles {
        let authors = await parser.getAuthorName(a)
        output.append(
            ArticleOutput(
                metaphor: a.metaphor,
                subMetaphor: a.subMetaphor,
                title: a.title,
                year: Int(a.year)!,
                authors: authors,
                publishLocation: a.publishLocation,
                isJournal: a.isJournal.lowercased() == "true",
                DOI: a.DOI,
                citationsDOI: a.citationsDOI,
                citationsCount: Int(a.citationsCount.trimmingCharacters(in: .whitespacesAndNewlines))
            )
        )
    }
    
    printAsJson(output: output)
}

func printAsJson(output: Encodable) {
    let encoder = JSONEncoder()
    encoder.outputFormatting = .prettyPrinted
    let data = try! encoder.encode(output)
    print(String(data: data, encoding: .utf8)!)
}

struct Article {
    let metaphor: String
    let subMetaphor: String
    let title: String
    let year: String
    let author: String
    let publishLocation: String
    let isJournal: String
    let DOI: String
    let citationsDOI: String
    let citationsCount: String
}

struct ArticleOutput: Codable {
    let metaphor: String
    let subMetaphor: String
    let title: String
    let year: Int
    let authors: [String]
    let publishLocation: String
    let isJournal: Bool
    let DOI: String
    let citationsDOI: String
    let citationsCount: Int?
}

func loadCSV() -> [Article]{
    let path = Bundle.local.path(forResource: "00_bestiaryDF", ofType: "csv")!
    let stream = InputStream(fileAtPath: path)!
    let csv = try! CSVReader(stream: stream, hasHeaderRow: true)
    var result: [Article] = []
    while let row = csv.next() {
        result.append(
            Article(
                metaphor: row[0],
                subMetaphor: row[1],
                title: row[2],
                year: row[3],
                author: row[4],
                publishLocation: row[5],
                isJournal: row[6],
                DOI: row[7],
                citationsDOI: row[8],
                citationsCount: row[9]
           )
        )
    }
    return result
}

func loadJSON(filename: String) throws -> [ArticleOutput] {
    let url = Bundle.local.url(forResource: filename, withExtension: "json")!
    let string = try String.init(contentsOf: url)
    return try JSONDecoder().decode([ArticleOutput].self, from: string.data(using: .utf8)!)
}

extension Foundation.Bundle {
    static var local: Bundle = {
        let bundleName = "Hoa_Hoa"
        let bundle = Bundle.main.bundleURL.appendingPathComponent("\(bundleName).bundle")
        return Bundle(url: bundle)!
    }()
}

extension String {
    func stringByAddingPercentEncodingForRFC3986() -> String? {
        let unreserved = "-._~/?"
        let allowed = NSMutableCharacterSet.alphanumeric()
        allowed.addCharacters(in: unreserved)
        return addingPercentEncoding(withAllowedCharacters: allowed as CharacterSet)
    }
}

// try await main()
// let articles = try loadJSON(filename: "researchgate")
let articles = loadCSV().map {
    ArticleOutput(
        metaphor: $0.metaphor,
        subMetaphor: $0.subMetaphor,
        title: $0.title,
        year: Int($0.year)!,
        authors: $0.author.split(separator: ";").map { $0.trimmingCharacters(in: .whitespacesAndNewlines)},
        publishLocation: $0.publishLocation,
        isJournal: $0.isJournal == "TRUE",
        DOI: $0.DOI,
        citationsDOI: $0.citationsDOI,
        citationsCount: Int($0.citationsCount)
    )
}
let articelsWithAuthor = articles.filter { !$0.authors.isEmpty }
var matrix: [String: [String: Int]] = [:]

let uniqueAuthors = Array(articelsWithAuthor.map { $0.authors }.joined()).uniqued()
for author in uniqueAuthors {
    matrix[author] = [:]
    for anotherAuthor in uniqueAuthors {
        if (author != anotherAuthor) {
            matrix[author]![anotherAuthor] = articelsWithAuthor.filter { $0.authors.contains(author) && $0.authors.contains(anotherAuthor) }.count
        }
    }
}

printAsJson(output: matrix)
