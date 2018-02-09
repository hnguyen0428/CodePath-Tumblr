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
                
                // Get the dictionary from the response key
                let responseDictionary = dataDictionary["response"] as! [String: Any]
                // Store the returned array of dictionaries in our posts property
                self.posts = responseDictionary["posts"] as! [[String: Any]]
                
                let post = self.posts.first!
                
                if let photos = post["photos"] as? [[String:Any]] {
                    let photo = photos[0]
                    let originalSize = photo["original_size"] as! [String: Any]
                    
                    if let width = originalSize["width"] as? CGFloat,
                        let height = originalSize["height"] as? CGFloat {
                        let heightToWidth = height / width
                        let height = self.tableView.frame.width * heightToWidth
                        self.cellHeight = height
                        self.tableView.rowHeight = self.cellHeight
                    }
                }
                
                self.tableView.reloadData()
            }
        }
        task.resume()
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PhotoCell", for: indexPath) as! PhotoCell
        
        //let post = posts[indexPath.row]
        
        let post = posts[indexPath.section]
        
        if let photos = post["photos"] as? [[String:Any]] {
            let photo = photos[0]
            let originalSize = photo["original_size"] as! [String: Any]
            let urlString = originalSize["url"] as! String
            let url = URL(string: urlString)
            
            cell.photoView.af_setImage(withURL: url!, completion: { _ in
                cell.photoView.frame = CGRect(x: 0, y: 0, width: cell.frame.width, height: self.cellHeight)
            })
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //return posts.count
        return 1 
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc = segue.destination as! PhotoDetailsViewController
        let cell = sender as! UITableViewCell
        if let indexPath = tableView.indexPath(for: cell) {
            let post = self.posts[indexPath.section]
            vc.post = post
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: 320, height: 50))
        headerView.backgroundColor = UIColor(white: 1, alpha: 0.9)
        
        let profileView = UIImageView(frame: CGRect(x: 10, y: 10, width: 30, height: 30))
        profileView.clipsToBounds = true
        profileView.layer.cornerRadius = 15;
        profileView.layer.borderColor = UIColor(white: 0.7, alpha: 0.8).cgColor
        profileView.layer.borderWidth = 1;
        
        // Set the avatar
        profileView.af_setImage(withURL: URL(string: "https://api.tumblr.com/v2/blog/humansofnewyork.tumblr.com/avatar")!)
        headerView.addSubview(profileView)
        
        // Add a UILabel for the date here
        
        //let label = UILabel (frame: CGRect(x: 0, y: 0, width: 320, height: 50))
        
        
        // Use the section number to get the right URL
        // let label = ...

        let post = posts[section]
        
        
        let label = UILabel (frame: CGRect(x: 0, y: 0, width: 320, height: 50))
        label.textAlignment = .center
        var dateStr = post["date"] as! String
        
//        let formatter = DateFormatter()
//        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
//        formatter.timeZone = TimeZone(identifier: "GMT")
//        let date = formatter.date(from: dateStr!)
//        formatter.dateFormat = "MMM d, yyyy, hh:mm"
//        let newDate = formatter.string(from: date!)
//        label.text = newDate
        label.text = dateStr
        headerView.addSubview(label)

        return headerView
        
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
}



class PhotoCell: UITableViewCell {
    
    @IBOutlet weak var photoView: UIImageView!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        photoView.contentMode = .scaleAspectFill
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
