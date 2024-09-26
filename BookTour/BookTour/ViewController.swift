    //
    //  ViewController.swift
    //  BookTour
    //
    //  Created by Cao Đạt on 24/08/2024.
    //

import UIKit
import FirebaseFirestore

class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    
    private let headerLabel: UILabel = {
        let label = UILabel()
        label.text = "Chọn loại hình du lịch bạn thích!"
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.textColor = .black
        return label
    }()
    
    private var collectionView: UICollectionView?
    private var tourCollectionView: UICollectionView?  // Thêm Collection View cho danh sách tour
    
    
    private let models = ["Mountain", "Historical", "Beach", "City"]
    private var tours: [Tour] = []  // Mảng chứa danh sách tour từ Firestore
    private var selectedCategory: String = "Mountain"  // Giá trị mặc định ban đầu
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.addSubview(headerLabel)
        headerLabel.frame = CGRect(x: 0, y: 50, width: view.frame.size.width, height: 50)
        
        // Setup Collection View đầu tiên (loại hình du lịch)
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 90, height: 90)
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView?.register(CircleCollectionViewCell.self, forCellWithReuseIdentifier: CircleCollectionViewCell.identifier)
        collectionView?.showsHorizontalScrollIndicator = false
        collectionView?.delegate = self
        collectionView?.dataSource = self
        collectionView?.backgroundColor = .white
        guard let myCollection = collectionView else {
            return
        }
        view.addSubview(myCollection)
        
        // Setup Collection View thứ hai (danh sách tour)
        let tourLayout = UICollectionViewFlowLayout()
        tourLayout.scrollDirection = .vertical
        tourLayout.itemSize = CGSize(width: view.frame.size.width - 20, height: 100)
        tourLayout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        tourCollectionView = UICollectionView(frame: .zero, collectionViewLayout: tourLayout)
        tourCollectionView?.register(TourCollectionViewCell.self, forCellWithReuseIdentifier: TourCollectionViewCell.identifier)
        tourCollectionView?.delegate = self
        tourCollectionView?.dataSource = self
        tourCollectionView?.backgroundColor = .white
        guard let tourCollection = tourCollectionView else {
            return
        }
        view.addSubview(tourCollection)
        
        // Gọi hàm để lấy dữ liệu tour
        fetchTourData { fetchedTours in
            self.tours = fetchedTours
            DispatchQueue.main.async {
                self.tourCollectionView?.reloadData()
            }
        }
    }
    
    func reloadData() {
        // Hàm để reload dữ liệu, ví dụ lấy lại dữ liệu từ Firestore
        print("ViewController reloaded!")
        fetchTourData { fetchedTours in
            self.tours = fetchedTours
            DispatchQueue.main.async {
                self.tourCollectionView?.reloadData()
            }
        }
    }

    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Collection View thứ nhất
        collectionView?.frame = CGRect(x: 0, y: 100, width: view.frame.size.width, height: 150).integral
        
        // Collection View thứ hai
        tourCollectionView?.frame = CGRect(x: 0, y: 260, width: view.frame.size.width, height: view.frame.size.height - 360).integral
    }
    
    
    // Collection View thứ nhất (loại hình du lịch)
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.collectionView {
            return models.count
        } else {
            return tours.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == self.collectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CircleCollectionViewCell.identifier, for: indexPath) as! CircleCollectionViewCell
            cell.configure(with: models[indexPath.row])
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TourCollectionViewCell.identifier, for: indexPath) as! TourCollectionViewCell
            let tour = tours[indexPath.row]
            cell.configure(with: tour)
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == self.collectionView {
            // Lấy danh mục được chọn
            selectedCategory = models[indexPath.row]
            
            // Gọi hàm filter tour theo danh mục
            fetchFilteredTours(by: selectedCategory) { filteredTours in
                self.tours = filteredTours
                DispatchQueue.main.async {
                    self.tourCollectionView?.reloadData()
                }
            }
        }
        if collectionView == self.tourCollectionView {
                // Lấy dữ liệu tour khi người dùng bấm vào
                let selectedTour = tours[indexPath.row]

                // Chuyển đến màn hình chi tiết tour
                let detailVC = TourDetailViewController()
                detailVC.tour = selectedTour
                navigationController?.pushViewController(detailVC, animated: true)
            }
    }
    
    // Hàm lấy dữ liệu từ Firestore
    func fetchTourData(completion: @escaping ([Tour]) -> Void) {
        let db = Firestore.firestore()
        db.collection("Tour").getDocuments { (querySnapshot, error) in
            var fetchedTours: [Tour] = []
            
            if let error = error {
                print("Error getting documents: \(error)")
                completion([])
            } else {
                for document in querySnapshot!.documents {
                    let data = document.data()
                    let tour = Tour(
                        danhMucID: data["DanhMucID"] as? String ?? "",
                        ghiChu: data["GhiChu"] as? String ?? "",
                        giaTour: data["GiaTour"] as? String ?? "",
                        hinhTour: data["HinhTour"] as? String ?? "",
                        moTaTour: data["MoTaTour"] as? String ?? "",
                        soLuongKhach: data["SoLuongKhach"] as? String ?? "",
                        tenTour: data["TenTour"] as? String ?? "",
                        thoiGianTour: data["ThoiGianTour"] as? String ?? ""
                    )
                    fetchedTours.append(tour)
                }
                completion(fetchedTours)
            }
        }
    }
    
    func fetchFilteredTours(by category: String, completion: @escaping ([Tour]) -> Void) {
        let db = Firestore.firestore()
        db.collection("Tour").whereField("DanhMucID", isEqualTo: category).getDocuments { (querySnapshot, error) in
            var filteredTours: [Tour] = []
            
            if let error = error {
                print("Error getting documents: \(error)")
                completion([])
            } else {
                for document in querySnapshot!.documents {
                    let data = document.data()
                    let tour = Tour(
                        danhMucID: data["DanhMucID"] as? String ?? "",
                        ghiChu: data["GhiChu"] as? String ?? "",
                        giaTour: data["GiaTour"] as? String ?? "",
                        hinhTour: data["HinhTour"] as? String ?? "",
                        moTaTour: data["MoTaTour"] as? String ?? "",
                        soLuongKhach: data["SoLuongKhach"] as? String ?? "",
                        tenTour: data["TenTour"] as? String ?? "",
                        thoiGianTour: data["ThoiGianTour"] as? String ?? ""
                    )
                    filteredTours.append(tour)
                }
                completion(filteredTours)
            }
        }
    }
}
