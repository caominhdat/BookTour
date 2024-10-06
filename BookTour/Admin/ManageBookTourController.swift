import UIKit
import FirebaseFirestore

class ManageBookTourController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var bookings: [Booking] = []
    let tableView = UITableView()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white

        setupTableView()
        fetchAllSubCollectionBookings()
    }

    func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.frame = view.bounds
        tableView.register(BookingCell.self, forCellReuseIdentifier: "BookingCell")
        view.addSubview(tableView)
    }

    // Truy vấn tất cả các sub-collection Bookings trong collection History
    func fetchAllSubCollectionBookings() {
        let db = Firestore.firestore()

        // Truy vấn tất cả các document trong collection History
        db.collection("History").getDocuments { (snapshot, error) in
            if let error = error {
                print("Error getting History documents: \(error)")
                return
            }
            
            guard let documents = snapshot?.documents, !documents.isEmpty else {
                print("No History documents found")
                return
            }

            // Lặp qua tất cả các document trong collection History
            let dispatchGroup = DispatchGroup() // Sử dụng DispatchGroup để đồng bộ hóa
            for document in documents {
                // Truy vấn tất cả các document trong sub-collection Bookings
                let bookingsRef = document.reference.collection("Bookings")
                
                dispatchGroup.enter() // Tham gia vào dispatch group
                
                bookingsRef.getDocuments { (bookingSnapshot, error) in
                    defer { dispatchGroup.leave() } // Thoát dispatch group khi hoàn thành

                    if let error = error {
                        print("Error getting bookings for History document \(document.documentID): \(error)")
                        return
                    }

                    guard let bookingDocuments = bookingSnapshot?.documents, !bookingDocuments.isEmpty else {
                        print("No Bookings found for History document: \(document.documentID)")
                        return
                    }

                    // Lặp qua tất cả các document trong sub-collection Bookings
                    for bookingDoc in bookingDocuments {
                        let data = bookingDoc.data()
                        
                        // Lấy các trường cần thiết
                        if let bookingDate = (data["bookingDate"] as? Timestamp)?.dateValue(),
                           let email = data["email"] as? String,
                           let items = data["items"] as? [[String: Any]],
                           let phone = data["phone"] as? String,
                           let totalPrice = data["totalPrice"] as? Int {
                            
                            // Tạo Booking và thêm vào mảng bookings
                            let booking = Booking(id: bookingDoc.documentID, data: data)
                            self.bookings.append(booking)
                            
                            // In ra các trường (trừ hinhTour)
                            print("Booking Data for Document \(document.documentID):")
                            print(" - Booking Date: \(bookingDate)")
                            print(" - Email: \(email)")
                            print(" - Phone: \(phone)")
                            print(" - Total Price: \(totalPrice)")
                            
                            // Chỉ in ra các items mà không có hinhTour
                            for item in items {
                                let tenTour = item["tenTour"] as? String ?? "N/A"
                                let soLuong = item["soLuong"] as? Int ?? 0
                                let giaTour = item["giaTour"] as? String ?? "N/A"
                                
                                print(" - Items: [\"tenTour\": \(tenTour), \"soLuong\": \(soLuong), \"giaTour\": \(giaTour)]")
                            }
                        }
                    }
                }
            }

            // Chờ cho tất cả các truy vấn hoàn thành
            dispatchGroup.notify(queue: .main) {
                print("All bookings have been fetched.")
                self.tableView.reloadData() // Cập nhật giao diện sau khi có dữ liệu
            }
        }
    }

    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return bookings.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BookingCell", for: indexPath) as! BookingCell
        let booking = bookings[indexPath.row]
        
        // Cấu hình cell với booking
        cell.configure(with: booking)
        return cell
    }
}

// Struct mô tả đối tượng Booking
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

