//
//  Successor.swift
//  Animation
//
//  Created by Russell Gordon on 2021-05-05.
//

import Foundation

// What replaces a predecessor in an L-system
struct Successor: Codable {
    
    // The likelihood of this successor being applied, when combined with other successors assigned to a given predecessor
    let odds: Int
    
    // The text that replaces the predecessor in the L-system's word
    let text: String
}
