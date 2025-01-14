//
//  FirebaseManager.swift
//  Share Point
//
//  Created by Dibyo sarkar on 9/1/25.
//

import Firebase
import FirebaseFirestore
import FirebaseStorage
import FirebaseAuth

class FirebaseManager {
    static let shared = FirebaseManager()
    let auth = Auth.auth()
    let firestore = Firestore.firestore()
    let storage = Storage.storage()
}


