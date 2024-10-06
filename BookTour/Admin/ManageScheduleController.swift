import UIKit
import FirebaseFirestore

class ManageScheduleController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UISearchResultsUpdating, UISearchBarDelegate {

    var tourNames: [String] = [] // Mảng chứa tên các tour từ Firestore
    var filteredTourNames: [String] = [] // Mảng chứa kết quả tìm kiếm
    var selectedTourID: String? // ID của tour được chọn
    var scheduleItems: [String] = [] // Mảng chứa lịch trình từ Firestore
    let searchController = UISearchController(searchResultsController: nil)
    let pickerView = UIPickerView()
    let tableView = UITableView() // Bảng để hiển thị lịch trình

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        setupSearchController()
        setupPickerView()
        setupTableView()
        fetchTourNames() // Truy vấn dữ liệu từ Firestore
    }

    // Thiết lập UISearchController để tìm kiếm
    private func setupSearchController() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Tìm kiếm tour"
        searchController.searchBar.delegate = self // Thiết lập delegate cho searchBar
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }

    // Xử lý sự kiện nhấn Enter
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let searchText = searchBar.text, !searchText.isEmpty {
            // Tìm kiếm tên tour trong danh sách
            if let index = filteredTourNames.firstIndex(of: searchText) {
                // Nếu tìm thấy tour, chọn tour đó
                pickerView.selectRow(index, inComponent: 0, animated: true)
                pickerView.delegate?.pickerView?(pickerView, didSelectRow: index, inComponent: 0)
            } else {
                print("Không tìm thấy tour nào với tên: \(searchText)")
            }
        }
    }

    // Thiết lập UIPickerView
    private func setupPickerView() {
        pickerView.delegate = self
        pickerView.dataSource = self
        pickerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(pickerView)
        
        // Ràng buộc UIPickerView
        NSLayoutConstraint.activate([
            pickerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            pickerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            pickerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            pickerView.heightAnchor.constraint(equalToConstant: 200)
        ])
    }

    // Thiết lập UITableView để hiển thị lịch trình
    private func setupTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        view.addSubview(tableView)

        // Ràng buộc UITableView
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: pickerView.bottomAnchor, constant: 10),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell") // Đăng ký cell cho UITableView
    }

    // Truy vấn tên tour từ Firestore
    private func fetchTourNames() {
        let db = Firestore.firestore()
        db.collection("Tour").getDocuments { [weak self] (snapshot, error) in
            if let error = error {
                print("Lỗi khi lấy dữ liệu từ Firestore: \(error.localizedDescription)")
            } else if let snapshot = snapshot {
                if snapshot.documents.isEmpty {
                    print("Không có document nào trong collection Tour")
                } else {
                    self?.tourNames = snapshot.documents.compactMap { $0["TenTour"] as? String }
                    self?.filteredTourNames = self?.tourNames ?? []
                    print("Dữ liệu lấy được từ Firestore: \(self?.tourNames ?? [])")
                    DispatchQueue.main.async {
                        self?.pickerView.reloadAllComponents()
                    }
                }
            } else {
                print("Không lấy được dữ liệu, snapshot là nil")
            }
        }
    }

    // MARK: - UIPickerViewDelegate & UIPickerViewDataSource

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return filteredTourNames.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return filteredTourNames[row]
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let selectedTour = filteredTourNames[row]
        
        // Kiểm tra xem tên tour đã chọn có hợp lệ không
        guard !selectedTour.isEmpty else {
            print("Tên tour không hợp lệ")
            return
        }
        
        // Lấy document ID của tour đã chọn
        fetchTourID(for: selectedTour) { [weak self] id in
            guard let self = self else { return } // Kiểm tra self
            if let tourID = id {
                self.selectedTourID = tourID
                self.fetchSchedule(for: tourID) // Gọi hàm để lấy lịch trình
            } else {
                print("Không tìm thấy document ID cho tour: \(selectedTour)")
            }
        }
    }

    // Truy vấn document ID của tour
    private func fetchTourID(for tourName: String, completion: @escaping (String?) -> Void) {
        let db = Firestore.firestore()
        db.collection("Tour").whereField("TenTour", isEqualTo: tourName).getDocuments { snapshot, error in
            if let error = error {
                print("Lỗi khi lấy ID tour: \(error.localizedDescription)")
                completion(nil)
            } else if let snapshot = snapshot, let document = snapshot.documents.first {
                completion(document.documentID) // Trả về document ID
            } else {
                print("Không tìm thấy document cho tour: \(tourName)")
                completion(nil)
            }
        }
    }

    // Truy vấn lịch trình từ Firestore
    private func fetchSchedule(for tourID: String) {
        let db = Firestore.firestore()
        db.collection("Lich_Trinh").whereField("tourID", isEqualTo: tourID).getDocuments { [weak self] (snapshot, error) in
            if let error = error {
                print("Lỗi khi lấy lịch trình: \(error.localizedDescription)")
            } else if let snapshot = snapshot {
                self?.scheduleItems = snapshot.documents.compactMap { $0["scheduleDetail"] as? String }
                DispatchQueue.main.async {
                    self?.tableView.reloadData() // Cập nhật UITableView
                }
            }
        }
    }

    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text, !searchText.isEmpty else {
            filteredTourNames = tourNames
            pickerView.reloadAllComponents()
            return
        }

        filteredTourNames = tourNames.filter { $0.lowercased().contains(searchText.lowercased()) }
        pickerView.reloadAllComponents()
    }
}

extension ManageScheduleController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return scheduleItems.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = scheduleItems[indexPath.row] // Hiển thị lịch trình
        return cell
    }
}

