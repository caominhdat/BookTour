import UIKit
import FirebaseFirestore

class ManageTourController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    var tours = [TourModel]()
    var collectionView: UICollectionView!
    var currentTourID: String?
    var selectedIndexPath: IndexPath?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white

        setupNavigationBar()
        setupCollectionView()
        fetchTours()
        
        // Lắng nghe thông báo ReloadManageTour
        NotificationCenter.default.addObserver(self, selector: #selector(fetchTours), name: NSNotification.Name("ReloadManageTour"), object: nil)
    }

    deinit {
        // Đảm bảo xóa observer khi controller bị giải phóng
        NotificationCenter.default.removeObserver(self)
    }

    func setupNavigationBar() {
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTour)),
            UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editTour)),
            UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(deleteTour))
        ]
    }

    func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10

        collectionView = UICollectionView(frame: self.view.bounds, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(ManageTourCell.self, forCellWithReuseIdentifier: "ManageTourCell")
        collectionView.backgroundColor = .white
        self.view.addSubview(collectionView)
    }

    @objc func fetchTours() {
        let db = Firestore.firestore()
        db.collection("Tour").getDocuments { (snapshot, error) in
            if let error = error {
                print("Error getting documents: \(error)")
            } else {
                self.tours.removeAll() // Xóa các tour hiện có
                for document in snapshot!.documents {
                    let data = document.data()
                    let id = document.documentID // Lấy ID của tài liệu
                    // Khởi tạo TourModel với dữ liệu từ Firestore
                    let tour = TourModel(dictionary: data, id: id)
                    self.tours.append(tour) // Thêm vào danh sách tour
                }
                self.collectionView.reloadData() // Tải lại dữ liệu cho collectionView
            }
        }
    }

    @objc func addTour() {
        print("Add Tour")
        let tourFormController = TourFormController()
        let navigationController = UINavigationController(rootViewController: tourFormController)
        present(navigationController, animated: true, completion: nil)
    }

    @objc func editTour() {
        guard let selectedIndexPath = collectionView.indexPathsForSelectedItems?.first else { return }
        let selectedTour = tours[selectedIndexPath.item]
        
        let tourFormController = TourFormController()
        tourFormController.tourToEdit = selectedTour // Chuyển đối tượng tour
        tourFormController.currentTourID = selectedTour.id // Gán ID tour
        tourFormController.isEditingTour = true // Đánh dấu là đang ở chế độ chỉnh sửa
        let navigationController = UINavigationController(rootViewController: tourFormController)
        present(navigationController, animated: true, completion: nil)
    }

    @objc func deleteTour() {
        guard let selectedTourID = currentTourID else {
            print("No tour selected for deletion")
            return
        }

        let alert = UIAlertController(title: "Xóa Tour", message: "Bạn có chắc chắn muốn xóa tour này?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Hủy", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Xóa", style: .destructive, handler: { _ in
            self.confirmDeleteTour(tourID: selectedTourID)
        }))

        self.present(alert, animated: true, completion: nil)
    }

    private func confirmDeleteTour(tourID: String) {
        let db = Firestore.firestore()
        db.collection("Tour").document(tourID).delete() { error in
            if let error = error {
                print("Error deleting document: \(error)")
            } else {
                print("Tour deleted successfully!")
                // Reload lại danh sách tours
                self.fetchTours()
            }
        }
    }

    // UICollectionView DataSource and Delegate Methods
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tours.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ManageTourCell", for: indexPath) as! ManageTourCell
        let tour = tours[indexPath.item]
        cell.configure(with: tour)

        // Đặt màu sắc của cell dựa trên việc nó có được chọn hay không
        if indexPath == selectedIndexPath {
            cell.backgroundColor = UIColor.lightGray // Màu sắc khi được chọn
        } else {
            cell.backgroundColor = UIColor.white // Màu sắc mặc định
        }

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // Nếu có chỉ số đã chọn trước đó, bỏ chọn nó
        if let previousIndexPath = selectedIndexPath {
            collectionView.deselectItem(at: previousIndexPath, animated: true)
            if let previousCell = collectionView.cellForItem(at: previousIndexPath) as? ManageTourCell {
                previousCell.backgroundColor = UIColor.white // Đặt lại màu sắc của cell khi bỏ chọn
            }
        }

        // Cập nhật chỉ số đã chọn
        selectedIndexPath = indexPath

        // Sáng màu cell đã chọn
        let selectedCell = collectionView.cellForItem(at: indexPath) as! ManageTourCell
        selectedCell.backgroundColor = UIColor.lightGray // Màu sắc khi được chọn

        // Gán currentTourID
        currentTourID = tours[indexPath.item].id // Cập nhật ID của tour đang chọn
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (self.view.frame.width - 30) / 2, height: 250)
    }
}

