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
    var scriptText: String
    var scriptTitle: String
    
    init(pageTitle: String, pageURL: String, scriptText: String, scriptTitle: String) {
        self.pageTitle = pageTitle
        self.pageURL = pageURL
        self.scriptText = scriptText
        self.scriptTitle = scriptTitle
    }
}
