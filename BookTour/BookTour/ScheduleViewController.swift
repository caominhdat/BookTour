import UIKit

class ScheduleViewController: UIViewController {
    var scheduleData: [String: Any]?  // Biến lưu dữ liệu lịch trình được truyền vào

    private let closeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("X", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 24)
        button.addTarget(ScheduleViewController.self, action: #selector(closeSchedule), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let scheduleTextView: UITextView = {
        let textView = UITextView()
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.isEditable = false
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white.withAlphaComponent(0.9)
        setupUI()
        displaySchedule()
    }

    private func setupUI() {
        view.addSubview(closeButton)
        view.addSubview(scheduleTextView)
        
        // Constraints cho nút đóng
        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            closeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            // Constraints cho textView hiển thị lịch trình
            scheduleTextView.topAnchor.constraint(equalTo: closeButton.bottomAnchor, constant: 20),
            scheduleTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            scheduleTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            scheduleTextView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20)
        ])
    }

    private func displaySchedule() {
        guard let scheduleData = scheduleData else { return }
        
        var scheduleText = ""
        for (day, times) in scheduleData {
            scheduleText += "📅 \(day):\n"
            if let times = times as? [String: String] {
                for (time, activity) in times {
                    scheduleText += "🕒 \(time) - \(activity)\n"
                }
            }
            scheduleText += "\n"
        }
        
        scheduleTextView.text = scheduleText
    }

    @objc private func closeSchedule() {
        dismiss(animated: true, completion: nil)
    }
}

