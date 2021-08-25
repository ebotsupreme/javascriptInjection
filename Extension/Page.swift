//
//  Page.swift
//  Extension
//
//  Created by Eddie Jung on 8/25/21.
//

import Foundation

class Page: Codable {
    let pageTitle: String
    let pageURL: String
//    let scriptTitle: String
    var scriptText: String
    
    init(pageTitle: String, pageURL: String, scriptText: String) {
        self.pageTitle = pageTitle
        self.pageURL = pageURL
        self.scriptText = scriptText
    }
}
