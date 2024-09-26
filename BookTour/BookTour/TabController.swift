    //
    //  TabController.swift
    //  BookTour
    //
    //  Created by Cao Đạt on 21/09/2024.
    //

    import UIKit

    class TabController: UITabBarController, UITabBarControllerDelegate {
        
        var cartCount: Int = 0 {
                didSet {
                    updateCartBadge()
                }
            }

        override func viewDidLoad() {
            self.navigationItem.hidesBackButton = true
            super.viewDidLoad()
            self.setupTab()
            self.delegate = self
            
            // Cài đặt giao diện TabBar
            self.tabBar.unselectedItemTintColor = .purple  // Màu của các item chưa được chọn
            self.tabBar.barTintColor = .white              // Màu nền của TabBar
            self.tabBar.tintColor = .black
        }
        
        private func setupTab() {
            // Khởi tạo các View Controllers với biểu tượng và tiêu đề
            let home = self.createNav(with: "Home", and: UIImage(systemName: "house"), vc: ViewController())
            let cart = self.createNav(with: "Cart", and: UIImage(systemName: "cart"), vc: CartController())
            let history = self.createNav(with: "History", and: UIImage(systemName: "clock"), vc: HistoryController())
            let account = self.createNav(with: "Account", and: UIImage(systemName: "accessibility"), vc: AccountController())
            self.setViewControllers([home, cart, history, account], animated: true)
            
        }
        
        private func createNav(with title: String, and image: UIImage?, vc: UIViewController) -> UINavigationController {
            let nav = UINavigationController(rootViewController: vc)
            
            // Cài đặt tiêu đề và biểu tượng cho tab
            nav.tabBarItem.title = title
            nav.tabBarItem.image = image
            return nav
        }
        
        // Delegate method: Được gọi khi người dùng chọn tab
        func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
            if let navController = viewController as? UINavigationController,
               let homeVC = navController.viewControllers.first as? ViewController {
                // Gọi hàm reload cho ViewController ở đây
                homeVC.reloadData()
            }
        }
        
        func updateCartBadge() {
            let cartTabIndex = 2 // Giả sử tab "Cart" là tab thứ 3
            if let tabBarItems = self.tabBarController?.tabBar.items {
                let cartItem = tabBarItems[cartTabIndex]
                let cartCount = CartManager.shared.tourCount() // Hàm trả về số lượng tour trong giỏ
                cartItem.badgeValue = cartCount > 0 ? "\(cartCount)" : nil
            }
        }
        
        func addToCart(tour: Tour) {
            CartManager.shared.addTour(tour)
            updateCartBadge()
        }
        
        class CartManager {
            static let shared = CartManager()
            
            private var toursInCart: [Tour] = []

            private init() {}

            func addTour(_ tour: Tour) {
                toursInCart.append(tour)
            }

            func tourCount() -> Int {
                return toursInCart.count
            }

            func getTours() -> [Tour] {
                return toursInCart
            }
        }
    }
