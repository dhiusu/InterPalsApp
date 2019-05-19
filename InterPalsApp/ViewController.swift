//
//  ViewController.swift
//  InterPalsApp
//
//  Created by Ryu Kikkawa on 2019/05/09.
//  Copyright © 2019 Ryu Kikkawa. All rights reserved.
//

import UIKit
import WebKit
import Kanna

class ViewController: UIViewController {

    @IBOutlet weak var webview: WKWebView!
    
    @IBOutlet weak var tabbar: UITabBar!
    private var tabbarIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // Set refreshControl
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(reloadWebView(_:)), for: .valueChanged)
        webview.scrollView.addSubview(refreshControl)
        
        // Load to Interpals.
        webview.load(URLRequest(url: URL(string: "https://www.interpals.net")!))
        
        // NavigationDelegate
        webview.navigationDelegate = self
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        webview.reload()
    }
    
    @objc func reloadWebView(_ sender: UIRefreshControl) {
        webview.reload()
        sender.endRefreshing()
    }
    
}

// MARK: UITabBarDelegate
extension ViewController: UITabBarDelegate {
    
    // Type tabbar index.
    enum TabBarIndex: Int {
        case Home       = 1
        case Search     = 2
        case Message    = 3
    }
    
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        
        if self.tabbarIndex != item.tag {
            // Changing tabindex.
            self.tabbarIndex = item.tag
        } else {
            // Skip process.
            return
        }
        
        var urlString = "https://www.interpals.net"
        switch item.tag {
        case TabBarIndex.Home.rawValue: urlString += "/app/account"
        case TabBarIndex.Search.rawValue: urlString += "/app/search"
        case TabBarIndex.Message.rawValue: urlString += "/pm.php"
        default: break
        }
        
        self.webview.load(URLRequest(url: URL(string: urlString)!))
        
    }
    
}

// MARK: WKNavigationDelegate
extension ViewController: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        webView.evaluateJavaScript("document.body.innerHTML", completionHandler: { (html, error) -> Void in
            do {
                // Parsed html to setup tabbar badgeValue.
                let doc = try HTML(html: html as! String, encoding: .utf8)
                let newAlert = doc.css("span#pmNewCnt").first!.innerHTML!
                if !newAlert.isEmpty {
                    self.tabbar.items?.last!.badgeValue = newAlert
                }
            } catch {
                print("Parser error.")
            }
        })
    }
    
}
