//
//  UserModel.swift
//  BookTour
//
//  Created by Cao Đạt on 01/10/2024.
//

import Foundation

struct User: Codable {
    var id: String?  // Sẽ gán thủ công từ Firestore document ID
    var name: String
    var email: String
    var phone: String
    var role: String?  // role có thể là nil nếu không có trong dữ liệu
}
