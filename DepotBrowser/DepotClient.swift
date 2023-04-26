//
//  DepotClient.swift
//  DepotBrowser
//
//  Created by Martin Imobersteg on 26.04.23.
//

import ComposableArchitecture

struct DepotClient {
    var list: ([String]) async throws -> [FileDto]
}

extension DepotClient: DependencyKey {
    static let liveValue = Self(
        list: { path in
            if path.count == 0 {
                return [
                    FileDto(name: "file1", type: .FILE),
                    FileDto(name: "file2", type: .FILE),
                    FileDto(name: "file3", type: .FILE),
                    FileDto(name: "folder1", type: .FOLDER),
                    FileDto(name: "folder2", type: .FOLDER),
                ]
            }

            if path.count == 1 && path.first == "folder1" {
                return [
                    FileDto(name: "file4", type: .FILE),
                    FileDto(name: "file5", type: .FILE),
                    FileDto(name: "file6", type: .FILE),
                    FileDto(name: "folder3", type: .FOLDER),
                ]
            }

            if path.count == 1 && path.first == "folder2" {
                return [
                    FileDto(name: "file5", type: .FILE),
                    FileDto(name: "file6", type: .FILE),
                    FileDto(name: "file7", type: .FILE),
                ]
            }

            if path.count == 2 && path.first == "folder1" && path.last == "folder3" {
                return [
                    FileDto(name: "file8", type: .FILE),
                    FileDto(name: "file9", type: .FILE),
                    FileDto(name: "file10", type: .FILE),
                ]
            }

            return [FileDto]()
        }
    )
}

extension DependencyValues {
  var depot: DepotClient {
    get { self[DepotClient.self] }
    set { self[DepotClient.self] = newValue }
  }
}
