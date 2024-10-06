//
//  BookingModel.swift
//  BookTour
//
//  Created by Cao Đạt on 03/10/2024.
//

import Foundation

struct Booking {
    var id: String
    var bookingDate: Date?
    var email: String
    var items: [[String: Any]]
    var name: String
    var phone: String
    var totalPrice: Int

    init(id: String, data: [String: Any]) {
        self.id = id
        self.bookingDate = (data["bookingDate"] as? Timestamp)?.dateValue()
        self.email = data["email"] as? String ?? ""
        self.items = data["items"] as? [[String: Any]] ?? []
        self.name = data["name"] as? String ?? ""
        self.phone = data["phone"] as? String ?? ""
        self.totalPrice = data["totalPrice"] as? Int ?? 0
    }
}
