import UIKit
import FirebaseFirestore

class TourFormController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    let tenTourTextField = UITextField()
    let danhMucIDPicker = UIPickerView()
    let danhMucLabel = UILabel() // Thêm label cho Danh Mục
    let giaTourTextField = UITextField()
    let hinhTourTextField = UITextField()
    let soLuongKhachTextField = UITextField()
    let thoiGianTourTextField = UITextField()
    let saveButton = UIButton()
    var currentTourID: String?

    let danhMucOptions = ["Mountain", "Beach", "City", "Historical"]
    var tourToEdit: TourModel? // Tham chiếu đến tour đang được chỉnh sửa
    var isEditingTour = false // Đánh dấu chế độ chỉnh sửa

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupViews()

        // Nếu đang ở chế độ chỉnh sửa, điền dữ liệu vào các trường
        if isEditingTour, let tour = tourToEdit {
            tenTourTextField.text = tour.tenTour
            giaTourTextField.text = tour.giaTour
            hinhTourTextField.text = tour.hinhTour
            soLuongKhachTextField.text = tour.soLuongKhach
            thoiGianTourTextField.text = tour.thoiGianTour
            
            // Thiết lập cho picker view
            if let index = danhMucOptions.firstIndex(of: tour.danhMucID) {
                danhMucIDPicker.selectRow(index, inComponent: 0, animated: false)
            }
        }
    }

    private func setupViews() {
        // Thiết lập các thuộc tính của các TextField
        tenTourTextField.placeholder = "Tên Tour"
        tenTourTextField.borderStyle = .roundedRect
        
        giaTourTextField.placeholder = "Giá Tour"
        giaTourTextField.borderStyle = .roundedRect
        
        hinhTourTextField.placeholder = "Hình Tour (URL)"
        hinhTourTextField.borderStyle = .roundedRect
        
        soLuongKhachTextField.placeholder = "Số Lượng Khách"
        soLuongKhachTextField.borderStyle = .roundedRect
        
        thoiGianTourTextField.placeholder = "Thời Gian Tour"
        thoiGianTourTextField.borderStyle = .roundedRect
        
        saveButton.setTitle("Lưu Tour", for: .normal)
        saveButton.backgroundColor = .blue
        saveButton.setTitleColor(.white, for: .normal)
        saveButton.layer.cornerRadius = 5
        saveButton.addTarget(self, action: #selector(saveTour), for: .touchUpInside)

        // Thiết lập PickerView cho DanhMucID
        danhMucIDPicker.delegate = self
        danhMucIDPicker.dataSource = self
        
        // Thiết lập label cho danh mục
        danhMucLabel.text = "Danh Mục:"
        danhMucLabel.font = UIFont.systemFont(ofSize: 16, weight: .bold) // Có thể tùy chỉnh kiểu chữ
        danhMucLabel.textColor = .black // Màu chữ của label
        
        let stackView = UIStackView(arrangedSubviews: [tenTourTextField, danhMucLabel, danhMucIDPicker, giaTourTextField, hinhTourTextField, soLuongKhachTextField, thoiGianTourTextField, saveButton])
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(stackView)

        // Cài đặt Auto Layout
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }

    // MARK: - UIPickerView DataSource and Delegate Methods
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return danhMucOptions.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return danhMucOptions[row]
    }

    @objc func saveTour() {
        guard let tenTour = tenTourTextField.text, !tenTour.isEmpty,
              let giaTour = giaTourTextField.text, !giaTour.isEmpty,
              let hinhTour = hinhTourTextField.text, !hinhTour.isEmpty,
              let soLuongKhach = soLuongKhachTextField.text, !soLuongKhach.isEmpty,
              let thoiGianTour = thoiGianTourTextField.text, !thoiGianTour.isEmpty else {
            print("Vui lòng nhập đầy đủ thông tin")
            return
        }

        // Lấy giá trị đã chọn từ PickerView
        let selectedDanhMucID = danhMucOptions[danhMucIDPicker.selectedRow(inComponent: 0)]

        let tourData: [String: Any] = [
            "TenTour": tenTour,
            "DanhMucID": selectedDanhMucID,
            "GiaTour": giaTour,
            "HinhTour": hinhTour,
            "SoLuongKhach": soLuongKhach,
            "ThoiGianTour": thoiGianTour
        ]

        let db = Firestore.firestore()
        
        if let tourID = currentTourID { // Nếu có ID tour đang chỉnh sửa
            db.collection("Tour").document(tourID).updateData(tourData) { error in
                if let error = error {
                    print("Error updating document: \(error)")
                } else {
                    print("Tour updated successfully!")
                    // Reload ManageTourController
                    self.dismiss(animated: true) {
                        NotificationCenter.default.post(name: NSNotification.Name("ReloadManageTour"), object: nil)
                    }
                }
            }
        } else { // Nếu không có ID, thêm mới
            db.collection("Tour").addDocument(data: tourData) { error in
                if let error = error {
                    print("Error adding document: \(error)")
                } else {
                    print("Tour added successfully!")
                    // Reload ManageTourController
                    self.dismiss(animated: true) {
                        NotificationCenter.default.post(name: NSNotification.Name("ReloadManageTour"), object: nil)
                    }
                }
            }
        }
    }

}

