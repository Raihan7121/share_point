//
//  Models.swift
//  Share Point
//
//  Created by Dibyo sarkar on 9/1/25.
//

import Foundation

struct Post: Identifiable {
    var id: String // Firebase document ID or any unique identifier
    var title: String
    var content: String
    var imageURL: String
    var likes: Int
    var dislikes: Int
    var authorUID: String
    var createdAt: Date
}




struct Comment: Identifiable, Codable {
    var id: String
    var text: String
    var userId: String
    var createdAt: Date
}



struct User: Identifiable, Codable {
    var id: String { userUID } // Firebase uses `userUID` as the unique identifier
    var username: String
    var bio: String
    var profileImageURL: String
    var userUID: String
    var email: String
}





