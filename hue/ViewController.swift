//
//  ViewController.swift
//  hue
//
//  Created by Chen, Baron on 1/14/17.
//  Copyright © 2017 PoAn (Baron) Chen. All rights reserved.
//

import UIKit
import Foundation

class ViewController: UIViewController {
    
    var currentStatus = false
    
    @IBOutlet weak var brightnessSliderValue: UILabel!
    @IBOutlet weak var brightnessSlider: UISlider!
    
    func put(url: URL, body: NSMutableDictionary, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) throws {
        var request: URLRequest = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.httpBody = try JSONSerialization.data(withJSONObject: body, options: JSONSerialization.WritingOptions.prettyPrinted)
        let session: URLSession = URLSession.shared
        session.dataTask(with: request, completionHandler: completionHandler).resume()
    }

    @IBAction func buttonPressed(_ sender: Any) {
        let urlForGet = URL(string: "http://192.168.1.64/api/MAwfbzshj18WUCafSSU6AqQjT6dNiaGlTpJYs6n4/lights/3")
        URLSession.shared.dataTask(with: urlForGet!) { data, response, error in
            guard error == nil else {
                print(error ?? "Something went wrong")
                return
            }
            guard let data = data else {
                print("Data is empty")
                return
            }
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options:.allowFragments) as? [String: Any] {
                    let state = json["state"] as! [String: Any]
                    for eachItem in state {
                        if eachItem.key == "on" {
                            if eachItem.value as! Bool {
                                self.currentStatus = true
                            } else {
                                self.currentStatus = false
                            }
                            let urlForPut: URL = URL(string: "http://192.168.1.64/api/MAwfbzshj18WUCafSSU6AqQjT6dNiaGlTpJYs6n4/lights/3/state")!
                            let body: NSMutableDictionary = NSMutableDictionary()
                            
                            if self.currentStatus {
                                body.setValue(false, forKey: "on")
                            } else {
                                body.setValue(true, forKey: "on")
                            }
                            
                            try! self.put(url: urlForPut, body: body, completionHandler: { data, response, error in
                            })
                        }
                    }
                }
            } catch let err {
                print(err.localizedDescription)
            }
        }.resume()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    @IBAction func brightnessSliderValueChanged(_ sender: UISlider) {
        let brightnessSliderValue = Int(sender.value)
        self.brightnessSliderValue.text = brightnessSliderValue.description
        
        let urlForPut: URL = URL(string: "http://192.168.1.64/api/MAwfbzshj18WUCafSSU6AqQjT6dNiaGlTpJYs6n4/lights/3/state")!
        let body: NSMutableDictionary = NSMutableDictionary()
        
        body.setValue(brightnessSliderValue, forKey: "bri")
        
        try! self.put(url: urlForPut, body: body, completionHandler: { data, response, error in
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
