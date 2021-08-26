//
//  ActionViewController.swift
//  Extension
//
//  Created by Eddie Jung on 8/25/21.
//

import UIKit
import MobileCoreServices

class ActionViewController: UIViewController {
    @IBOutlet var script: UITextView!
    
    var pages = [Page]()
    
    var pageTitle = ""
    var pageURL = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(add))
    
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        
//        UserDefaults.standard.removeObject(forKey: "pages")
//        print(UserDefaults.standard.bool(forKey: "pages"))
        
        load()
        
        if let inputItem = extensionContext?.inputItems.first as? NSExtensionItem {
            if let itemProvider = inputItem.attachments?.first {
                itemProvider.loadItem(forTypeIdentifier: kUTTypePropertyList as String) { [weak self] (dict, error) in
                    guard let itemDictionary = dict as? NSDictionary else { return }
                    guard let javaScriptValues = itemDictionary[NSExtensionJavaScriptPreprocessingResultsKey] as? NSDictionary else { return }
                    
                    self?.pageTitle = javaScriptValues["title"] as? String ?? ""
                    self?.pageURL = javaScriptValues["URL"] as? String ?? ""
                    
                    let pageTitle = javaScriptValues["title"] as? String ?? ""
                    let pageURL = javaScriptValues["URL"] as? String ?? ""
                    
                    if self?.pages.isEmpty == true {
                        let page = Page(pageTitle: pageTitle, pageURL:  pageURL, scriptText: "", scriptTitle: "")
                        self?.pages.append(page)
                    } else {
                        self?.pages.forEach { page in
                            if page.pageURL == pageURL {
                                DispatchQueue.main.async {
                                    // exists, load script text
                                    self?.script.text = page.scriptText
                                }
                                
                            } else {
                                let page = Page(pageTitle: pageTitle, pageURL: pageURL, scriptText: "", scriptTitle: "")
                                self?.pages.append(page)
                            }
                        }
                    }
                    DispatchQueue.main.async {
                        self?.title = pageTitle
                    }
                    print(self?.pages)
                    
//                    self?.pageTitle = javaScriptValues["title"] as? String ?? ""
//                    self?.pageURL = javaScriptValues["URL"] as? String ?? ""
//
//                    DispatchQueue.main.async {
//                        self?.title = self?.pageTitle
//                    }
                }
            }
        }
        
    }
    
    func load() {
        let defaults = UserDefaults.standard
        if let savedPages = defaults.object(forKey: "pages") as? Data {
            let jsonDecoder = JSONDecoder()
            
            do {
                pages = try jsonDecoder.decode([Page].self, from: savedPages)
                print("PAGES::: \(pages)")
            } catch {
                print("Failed to load pages.")
            }
        }
    }
    
    func save() {
        let jsonEncoder = JSONEncoder()

        if let savedData = try? jsonEncoder.encode(pages) {
            let defaults = UserDefaults.standard
            defaults.set(savedData, forKey: "pages")
        }
    }
    
    @objc func add() {
        let ac = UIAlertController(title: "Scripts", message: "Add a script.", preferredStyle: .actionSheet)
        let titleAction = UIAlertAction(title: "Title", style: .default, handler: displayAction)
        let URLAction = UIAlertAction(title: "URL", style: .default, handler: displayAction)
        ac.addAction(titleAction)
        ac.addAction(URLAction)
        present(ac, animated: true)
    }
    
    func displayAction(action: UIAlertAction) {
        guard let title = action.title else { return }
        
        if title == "Title" {
            script.text = "alert(document.title);"
        } else if title == "URL" {
            script.text = "alert(document.URL);"
        }
    }

    @IBAction func done() {
        let item = NSExtensionItem()
        let argument: NSDictionary = ["customJavaScript": script.text ?? ""]
        let webDictionary: NSDictionary = [NSExtensionJavaScriptFinalizeArgumentKey: argument]
        let customJavaScript = NSItemProvider(item: webDictionary, typeIdentifier: kUTTypePropertyList as String)
        item.attachments = [customJavaScript]
        extensionContext?.completeRequest(returningItems: [item])
        
//        print("BEGIN AC ADD SCRIPT NAME")
//        let ac = UIAlertController(title: "Add script name", message: nil, preferredStyle: .alert)
//        ac.addTextField()
//        let submitAction = UIAlertAction(title: "Submit", style: .default) { [weak self, weak ac] _ in
//            let answer = ac?.textFields?[0].text
//            print("ASNWER: \(answer)")
//            if let submitAnswer = answer {
//                self?.submit(answer: submitAnswer)
//            }
//
//        }
//        ac.addAction(submitAction)
//        present(ac, animated: true)
        
        pages.forEach { page in
            if page.pageURL == pageURL {
                print("MATCH")
                page.scriptText = script.text
            }
        }
        
        save()
    }
    
    @objc func adjustForKeyboard(notification: Notification) {
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        
        let keyboardScreenEndFrame = keyboardValue.cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)
        
        if notification.name == UIResponder.keyboardWillHideNotification {
            script.contentInset = .zero
        } else {
            script.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height - view.safeAreaInsets.bottom, right: 0)
        }
        
        script.scrollIndicatorInsets = script.contentInset
        
        let selectedRange = script.selectedRange
        script.scrollRangeToVisible(selectedRange)
    }
    
//    func submit(answer: String) {
//        print("SUBMIT FUNC ")
//        pages.forEach { page in
//            if page.pageURL == pageURL {
//                print("MATCH")
//                page.scriptText = script.text
//                page.scriptTitle = answer
//            }
//        }
//    }

}
