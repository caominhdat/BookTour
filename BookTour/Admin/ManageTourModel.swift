import Foundation

struct TourModel {
    var id: String
    var danhMucID: String
    var giaTour: String
    var hinhTour: String
    var soLuongKhach: String
    var tenTour: String
    var thoiGianTour: String

    init(dictionary: [String: Any], id: String) {
        self.id = id
        self.danhMucID = dictionary["DanhMucID"] as? String ?? ""
        self.giaTour = dictionary["GiaTour"] as? String ?? ""
        self.hinhTour = dictionary["HinhTour"] as? String ?? ""
        self.soLuongKhach = dictionary["SoLuongKhach"] as? String ?? ""
        self.tenTour = dictionary["TenTour"] as? String ?? ""
        self.thoiGianTour = dictionary["ThoiGianTour"] as? String ?? ""
    }
}
