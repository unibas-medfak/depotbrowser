//
//  DepotClient.swift
//  DepotBrowser
//
//  Created by Martin Imobersteg on 26.04.23.
//

import Foundation
import ComposableArchitecture

struct FileDto: Equatable, Identifiable {

    enum FileType: String {
        case FILE, FOLDER
    }

    let id = UUID()
    let name: String
    let type: FileType
    let modified: Date
    let size: Int
}

enum CatError: Error {
    case runtimeError(String)
}

struct DepotClient {
    var list:([String]) async throws -> [FileDto]
    var get: ([String]) async throws -> Data
}

extension DepotClient: DependencyKey {
    static let liveValue = Self(
        list: { path in
            if path.count == 0 {
                return [
                    FileDto(name: "file1", type: .FILE, modified: Date(), size: 1000),
                    FileDto(name: "file2", type: .FILE, modified: Date(), size: 100),
                    FileDto(name: "file3", type: .FILE, modified: Date(), size: 10),
                    FileDto(name: "folder1", type: .FOLDER, modified: Date(), size: 0),
                    FileDto(name: "folder2", type: .FOLDER, modified: Date(), size: 0),
                ]
            }

            if path.count == 1 && path.first == "folder1" {
                return [
                    FileDto(name: "file4", type: .FILE, modified: Date(), size: 1000),
                    FileDto(name: "file5", type: .FILE, modified: Date(), size: 100),
                    FileDto(name: "file6", type: .FILE, modified: Date(), size: 10),
                    FileDto(name: "folder3", type: .FOLDER, modified: Date(), size: 0),
                ]
            }

            if path.count == 1 && path.first == "folder2" {
                return [
                    FileDto(name: "file5", type: .FILE, modified: Date(), size: 1000),
                    FileDto(name: "file6", type: .FILE, modified: Date(), size: 100),
                    FileDto(name: "file7", type: .FILE, modified: Date(), size: 10),
                ]
            }

            if path.count == 2 && path.first == "folder1" && path.last == "folder3" {
                return [
                    FileDto(name: "file8", type: .FILE, modified: Date(), size: 1000),
                    FileDto(name: "file9", type: .FILE, modified: Date(), size: 100),
                    FileDto(name: "file10", type: .FILE, modified: Date(), size: 10),
                ]
            }

            return [FileDto]()
        },
        get: { path in
            if let cat = Bundle.main.url(forResource: "cat", withExtension: "jpeg") {
                return try Data(contentsOf: cat)
            }

            throw CatError.runtimeError("miow")
        }

    )
}

extension DependencyValues {
  var depot: DepotClient {
    get { self[DepotClient.self] }
    set { self[DepotClient.self] = newValue }
  }
}
