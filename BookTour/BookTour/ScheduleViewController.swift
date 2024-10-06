import UIKit
import FirebaseFirestore

class ScheduleViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    // Tạo tableView để hiển thị lịch trình
    private let tableView = UITableView()

    // Mảng lưu dữ liệu lịch trình
    var scheduleData: [(day: String, activities: [String: String])] = []

    var tourID: String? // Nhận tourID từ màn hình trước để load dữ liệu lịch trình

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "Lịch trình"

        setupTableView()
        loadScheduleData()  // Gọi hàm load dữ liệu lịch trình
    }

    // Thiết lập tableView
    private func setupTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        view.addSubview(tableView)

        // Ràng buộc tableView
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    // Tải dữ liệu lịch trình từ Firestore
    private func loadScheduleData() {
        guard let tourID = tourID else {
            print("TourID không hợp lệ")
            return
        }

        // Sử dụng tourID để lấy dữ liệu từ collection LichTrinh với documentID tương ứng
        let db = Firestore.firestore()
        let scheduleRef = db.collection("LichTrinh").document(tourID)

        scheduleRef.getDocument { [weak self] (document, error) in
            if let document = document, document.exists {
                guard let data = document.data() else { return }

                // Duyệt qua từng ngày và lưu vào mảng
                for (key, value) in data {
                    if let activities = value as? [String: String] {
                        self?.scheduleData.append((day: "Ngày \(key)", activities: activities))
                    }
                }

                // Reload tableView để hiển thị dữ liệu
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
            } else {
                print("Lỗi khi lấy dữ liệu lịch trình: \(error?.localizedDescription ?? "Không rõ lỗi")")
            }
        }
    }

    // MARK: - UITableViewDataSource

    func numberOfSections(in tableView: UITableView) -> Int {
        return scheduleData.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return scheduleData[section].activities.count
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return scheduleData[section].day
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)

        let activities = scheduleData[indexPath.section].activities
        let activityKey = Array(activities.keys)[indexPath.row]
        let activityValue = activities[activityKey]

        cell.textLabel?.text = "\(activityKey): \(activityValue ?? "")"
        return cell
    }
}


//import UIKit
//import FirebaseFirestore
//
//class ScheduleViewController: UIViewController {
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        self.view.backgroundColor = .white
//        
//        createSampleSchedule(for: "Tour_Nui")
//        setupTitle()
//    }
//    
//    private func setupTitle() {
//        let titleLabel = UILabel()
//        titleLabel.text = "Lịch trình"
//        titleLabel.font = UIFont.boldSystemFont(ofSize: 24)
//        titleLabel.textAlignment = .center
//        titleLabel.translatesAutoresizingMaskIntoConstraints = false
//        // Thêm titleLabel vào view
//        view.addSubview(titleLabel)
//
//        // Ràng buộc tiêu đề để nó nằm giữa
//        NSLayoutConstraint.activate([
//            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
//            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
//        ])
//    }
//    
//    func createSampleSchedule(for tourID: String) {
//        let db = Firestore.firestore()
//
//        // Tạo tham chiếu đến Collection "LichTrinh" với documentID là tourID
//        let scheduleRef = db.collection("LichTrinh").document(tourID)
//
//        // Kiểm tra xem document đã tồn tại chưa
//        scheduleRef.getDocument { (document, error) in
//            if let document = document, document.exists {
//                print("Document với ID \(tourID) đã tồn tại, không tạo thêm.")
//            } else {
//                // Dữ liệu mẫu cho các ngày
//                let scheduleData: [String: Any] = [
//                    "1": [
//                        "06:00": "Đón khách tại điểm hẹn",
//                        "07:00": "Khởi hành đến điểm tham quan",
//                        "08:30": "Tham quan địa danh A",
//                        "12:00": "Dùng bữa trưa"
//                    ],
//                    "2": [
//                        "06:30": "Ăn sáng tại khách sạn",
//                        "09:00": "Tham quan địa danh B",
//                        "12:30": "Dùng bữa trưa tại nhà hàng C",
//                        "15:00": "Tự do khám phá"
//                    ],
//                    "3": [
//                        "07:00": "Ăn sáng tại khách sạn",
//                        "10:00": "Tham quan địa danh C",
//                        "12:00": "Kết thúc tour và trở về"
//                    ]
//                ]
//
//                // Lưu dữ liệu vào Firestore nếu document chưa tồn tại
//                scheduleRef.setData(scheduleData) { error in
//                    if let error = error {
//                        print("Lỗi khi tạo dữ liệu mẫu: \(error.localizedDescription)")
//                    } else {
//                        print("Dữ liệu mẫu đã được tạo thành công!")
//                    }
//                }
//            }
//        }
//    }
//}
