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
    
    @objc func reloadWebView(_ sender: UIRefreshControl) {
        webview.reload()
        sender.endRefreshing()
    }
    
    // Is login
    private func isLogin() -> Bool {
        var result = false
        let cookieStore = webview.configuration.websiteDataStore.httpCookieStore
        cookieStore.getAllCookies { (cookies) in
            for cookie in cookies {
                if cookie.name == "interpals_sessid" {
                    result = true
                    break
                }
            }
        }
        return result
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
        
        // Case by signouted.
        if !isLogin() {
            return
        }
        
        webView.evaluateJavaScript("document.body.innerHTML", completionHandler: { (html, error) -> Void in
            do {
                // Parsed html to setup tabbar badgeValue.
                self.tabbar.items?.last!.badgeValue = nil
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
