//
//  PhotoDetailsViewController.swift
//  Tumblr
//
//  Created by Hoang on 2/7/18.
//  Copyright © 2018 Hoang. All rights reserved.
//

import Foundation
import UIKit

class PhotoDetailsViewController: UIViewController {
    
    @IBOutlet weak var photoView: UIImageView!
    var post: [String:Any]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        photoView.contentMode = .scaleAspectFill
        setImage()
    }
    
    func setImage() {
        if let post = post {
            if let photos = post["photos"] as? [[String:Any]] {
                let photo = photos[0]
                let originalSize = photo["original_size"] as! [String: Any]
                let urlString = originalSize["url"] as! String
                let url = URL(string: urlString)
                
                photoView.af_setImage(withURL: url!)
            }
        }
    }
    
}
