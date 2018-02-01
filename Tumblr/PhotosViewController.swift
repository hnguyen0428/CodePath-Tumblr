//
//  PhotosViewController.swift
//  Tumblr
//
//  Created by Hoang on 1/31/18.
//  Copyright © 2018 Hoang. All rights reserved.
//

import Foundation
import UIKit
import AlamofireImage

class PhotosViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var posts: [[String: Any]] = []
    var cellHeight: CGFloat = 0.0
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        makeRequest()
        
        self.tableView.register(PhotoCell.self, forCellReuseIdentifier: "cell")
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }
    
    func makeRequest() {
        let url = URL(string: "https://api.tumblr.com/v2/blog/humansofnewyork.tumblr.com/posts/photo?api_key=Q6vHoaVm5L1u2ZAW1fqv3Jw48gFzYVg9P0vH0VHl3GVy6quoGV")!
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
        session.configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
        let task = session.dataTask(with: url) { (data, response, error) in
            if let error = error {
                print(error.localizedDescription)
            } else if let data = data,
                let dataDictionary = try! JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                print(dataDictionary)
                
                // Get the dictionary from the response key
                let responseDictionary = dataDictionary["response"] as! [String: Any]
                // Store the returned array of dictionaries in our posts property
                self.posts = responseDictionary["posts"] as! [[String: Any]]
                
                self.tableView.reloadData()
            }
        }
        task.resume()
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let cell = tableView.cellForRow(at: indexPath) as? PhotoCell
        if let cell = cell {
            let photoView = cell.photoView
            let size = photoView?.image?.size
            let heightToWidth = size!.height / size!.width
            let height = cell.frame.width * heightToWidth
            return height
        }
        return self.cellHeight
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! PhotoCell
        let post = posts[indexPath.row]
        
        if let photos = post["photos"] as? [[String:Any]] {
            let photo = photos[0]
            let originalSize = photo["original_size"] as! [String: Any]
            let urlString = originalSize["url"] as! String
            let url = URL(string: urlString)
            
            cell.photoView.af_setImage(withURL: url!)
            
            if let width = originalSize["width"] as? CGFloat,
                let height = originalSize["height"] as? CGFloat {
                let heightToWidth = height / width
                let height = cell.frame.width * heightToWidth
                self.cellHeight = height
            }
        }
        cell.heightConstraint.constant = self.cellHeight
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}


class PhotoCell: UITableViewCell {
    
    var photoView: UIImageView!
    var heightConstraint: NSLayoutConstraint!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        photoView = UIImageView()
        
        let width = self.bounds.width
        let height = self.bounds.height
        self.addSubview(photoView)
        photoView.translatesAutoresizingMaskIntoConstraints = false
        photoView.widthAnchor.constraint(equalToConstant: width).isActive = true
        heightConstraint = photoView.heightAnchor.constraint(equalToConstant: height)
        heightConstraint.isActive = true
        photoView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        photoView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        photoView.contentMode = .scaleAspectFill
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
