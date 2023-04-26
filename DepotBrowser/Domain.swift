//
//  Domain.swift
//  DepotBrowser
//
//  Created by Martin Imobersteg on 26.04.23.
//

import Foundation

struct FileDto: Equatable, Identifiable {

    enum FileType: String {
        case FILE, FOLDER
    }

    let id = UUID()
    let name: String
    let type: FileType
}
