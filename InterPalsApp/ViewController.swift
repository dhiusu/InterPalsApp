//
//  ViewController.swift
//  InterPalsApp
//
//  Created by Ryu Kikkawa on 2019/05/09.
//  Copyright © 2019 Ryu Kikkawa. All rights reserved.
//

import UIKit
import WebKit

class ViewController: UIViewController {

    @IBOutlet weak var webview: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // Set refreshControl
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(reloadWebView(_:)), for: .valueChanged)
        webview.scrollView.addSubview(refreshControl)
        
        // Load to Interpals.
        webview.load(URLRequest(url: URL(string: "https://www.interpals.net")!))
        
    }
    
    @objc func reloadWebView(_ sender: UIRefreshControl) {
        webview.reload()
        sender.endRefreshing()
    }
    
}

