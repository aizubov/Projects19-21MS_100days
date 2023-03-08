//
//  Note.swift
//  Projects19-21MS_100days
//
//  Created by user228564 on 3/8/23.
//

import Foundation

class Note: Codable {
    var text: String
    var date: Date

    init(text: String, date: Date) {
        self.text = text
        self.date = date
    }
}
