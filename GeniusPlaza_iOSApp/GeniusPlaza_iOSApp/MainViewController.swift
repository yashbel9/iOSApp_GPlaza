//
//  MainViewController.swift
//  GeniusPlaza_iOSApp
//
//  Copyright © 2019 yashbelorkar. All rights reserved.
//

import UIKit

class MainViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var myTableView: UITableView = UITableView()
    let model = MainViewModel()
    var activityIndicatorView: UIActivityIndicatorView = UIActivityIndicatorView(style: .whiteLarge)
    let container: UIView = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        let screenSize: CGRect = UIScreen.main.bounds
        let screenWidth = screenSize.width
        let screenHeight = screenSize.height
        
        myTableView.frame = CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        loadingScreen()
    }
    
    func loadingScreen() {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 20))
        label.center = view.center
        label.textAlignment = NSTextAlignment.center
        label.text = "My iOS Application"
        label.textColor = UIColor.white
        view.addSubview(label)
        
        UIView.animate(withDuration: 2.0, animations: {() -> Void in
            label.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        }, completion: {(_ finished: Bool) -> Void in
            UIView.animate(withDuration: 2.0, animations: {() -> Void in
                label.transform = CGAffineTransform(scaleX: 2, y: 2)
                
                if finished {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
                        self?.loadUI()
                        label.removeFromSuperview()
                    }
                }
            })
        })
    }
    
    func loadUI() {
        addTableView()
        showActivityIndicatory(uiView: view)
        
        model.makeRequest(endpoint: Endpoint.Music.rawValue) { [weak self] (success: Bool) in
            self?.model.makeRequest(endpoint: Endpoint.Apps.rawValue) { [weak self] (success: Bool) in
                if success {
                    DispatchQueue.main.async {
                        self?.myTableView.reloadData()
                        self?.activityIndicatorView.stopAnimating()
                        self?.container.removeFromSuperview()
                    }
                } else {
                    DispatchQueue.main.async {
                        self?.showAlert()
                        self?.activityIndicatorView.stopAnimating()
                        self?.container.removeFromSuperview()
                    }
                }
            }
        }
    }
    
    private func showAlert() {
        let alert = UIAlertController(title: "Unavailable", message: "No data available. Please try again after some time.", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        self.present(alert, animated: true)
    }
    
    func addTableView() {
        myTableView.dataSource = self
        myTableView.delegate = self
        myTableView.register(UITableViewCell.self, forCellReuseIdentifier: "myCell")
        
        view.addSubview(myTableView)
    }
    
    func showActivityIndicatory(uiView: UIView) {
        container.frame = uiView.frame
        container.center = uiView.center
        container.backgroundColor = UIColor.clear
        
        let loadingView: UIView = UIView()
        loadingView.frame = CGRect(x: 0, y: 0, width: 80, height: 80)
        loadingView.center = uiView.center
        loadingView.backgroundColor = UIColor.lightGray
        loadingView.clipsToBounds = true
        loadingView.layer.cornerRadius = 10
        
        activityIndicatorView.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        activityIndicatorView.style =
            UIActivityIndicatorView.Style.whiteLarge
        activityIndicatorView.center = CGPoint(x: loadingView.frame.size.width / 2, y: loadingView.frame.size.height / 2)
        loadingView.addSubview(activityIndicatorView)
        container.addSubview(loadingView)
        uiView.addSubview(container)
        activityIndicatorView.startAnimating()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return model.musicMediaResults.count
        case 1:
            return model.appsMediaResults.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "UITableViewCell") else {
                // Never fails:
                return UITableViewCell(style: UITableViewCell.CellStyle.subtitle, reuseIdentifier: "UITableViewCell")
            }
            return cell
        }()

        switch indexPath.section {
        case 0:
            cell.textLabel?.text = model.musicMediaResults[indexPath.row].name
            cell.detailTextLabel?.text = model.musicMediaResults[indexPath.row].type
            cell.imageView?.image = UIImage(named: "image-placeholder")
            if let url = URL(string: model.musicMediaResults[indexPath.row].thumbnail) {
                getData(from: url) { data, response, error in
                    guard let data = data, error == nil else { return }
                    DispatchQueue.main.async() {
                        cell.imageView?.image = UIImage(data: data)
                    }
                }
            }
        case 1:
            cell.textLabel?.text = model.appsMediaResults[indexPath.row].name
            cell.detailTextLabel?.text = model.appsMediaResults[indexPath.row].type
            cell.imageView?.image = UIImage(named: "image-placeholder")
            if let url = URL(string: model.appsMediaResults[indexPath.row].thumbnail) {
                getData(from: url) { data, response, error in
                    guard let data = data, error == nil else { return }
                    DispatchQueue.main.async() {
                        cell.imageView?.image = UIImage(data: data)
                    }
                }
            }
        default:
            return cell
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let sectionName: String
        switch section {
        case 0:
            sectionName = "Apple Music"
        case 1:
            sectionName = "iOS Apps"
        default:
            sectionName = "unknown"
        }
        return sectionName
    }
    
    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
}

public extension UIImage {
    public convenience init?(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) {
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        color.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        guard let cgImage = image?.cgImage else { return nil }
        self.init(cgImage: cgImage)
    }
}
