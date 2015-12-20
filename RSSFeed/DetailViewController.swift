//
//  DetailViewController.swift
//  RSSFeed
//
//  Created by Yakov Shkolnikov on 12/16/15.
//  Copyright © 2015 junor. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    
    var item: Item?

    @IBOutlet weak var titleTextView: UITextView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var detailTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Apple News"
        
        self.titleTextView.userInteractionEnabled = false
        self.detailTextView.editable = false
        
        self.titleTextView.text = self.item?.title
        self.timeLabel.text = self.item?.time
        
        let imageView = UIImageView(image: item?.image as? UIImage)
        imageView.frame = CGRect(x: 0, y: 0, width: 100, height: 100);
        imageView.sizeToFit()
        self.detailTextView.addSubview(imageView)
        
        let imageRect = UIBezierPath(rect: imageView.frame);
        self.detailTextView.textContainer.exclusionPaths = [imageRect]

        self.detailTextView.text = self.item?.descr
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
