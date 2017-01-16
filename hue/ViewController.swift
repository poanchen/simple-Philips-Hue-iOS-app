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
    // RRGGBB hex colors in the same order as the image
    let colorArray = [ 0x000000, 0xfe0000, 0xff7900, 0xffb900, 0xffde00, 0xfcff00, 0xd2ff00, 0x05c000, 0x00c0a7, 0x0600ff, 0x6700bf, 0x9500c0, 0xbf0199, 0xffffff ]
    
    @IBOutlet weak var brightnessSliderValue: UILabel!
    @IBOutlet weak var brightnessSlider: UISlider!
    @IBOutlet weak var selectedColorView: UIView!
    @IBOutlet weak var colorSelectorSlider: UISlider!
    @IBOutlet weak var colorView: UIImageView!
    
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
                            break
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
        self.brightnessSliderValue.text = "Loading..."
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
                        if eachItem.key == "bri" {
                            let currentBri = (eachItem.value as! Float)/2.59
                            self.brightnessSlider.value = currentBri
                            self.brightnessSliderValue.text = Int(currentBri).description + "%"
                            break
                        }
                    }
                }
            } catch let err {
                print(err.localizedDescription)
            }
        }.resume()
    }

    @IBAction func brightnessSliderValueChanged(_ sender: UISlider) {
        let brightnessSliderValue = Int(sender.value)
        self.brightnessSliderValue.text = brightnessSliderValue.description + "%"
        
        let urlForPut: URL = URL(string: "http://192.168.1.64/api/MAwfbzshj18WUCafSSU6AqQjT6dNiaGlTpJYs6n4/lights/3/state")!
        let body: NSMutableDictionary = NSMutableDictionary()
        
        body.setValue(Int(Double(brightnessSliderValue)*2.59), forKey: "bri")
        
        try! self.put(url: urlForPut, body: body, completionHandler: { data, response, error in
        })
    }
    
    @IBAction func colorSelectorSliderValueChanged(_ sender: UISlider) {
        selectedColorView.backgroundColor = self.uiColorFromHex(rgbValue: self.colorArray[Int(sender.value)])
    }
    
    func uiColorFromHex(rgbValue: Int) -> UIColor {
        
        let red =   CGFloat((rgbValue & 0xFF0000) >> 16) / 0xFF
        let green = CGFloat((rgbValue & 0x00FF00) >> 8) / 0xFF
        let blue =  CGFloat(rgbValue & 0x0000FF) / 0xFF
        let alpha = CGFloat(1.0)
        
        let redF = (red > 0.04045) ? pow((red + 0.055) / (1.0 + 0.055), 2.4) : (red / 12.92)
        let greenF = (green > 0.04045) ? pow((green + 0.055) / (1.0 + 0.055), 2.4) : (green / 12.92)
        let blueF = (blue > 0.04045) ? pow((blue + 0.055) / (1.0 + 0.055), 2.4) : (blue / 12.92)
        
        let X = redF * 0.664511 + greenF * 0.154324 + blueF * 0.162028
        let Y = redF * 0.283881 + greenF * 0.668433 + blueF * 0.047685
        let Z = redF * 0.000088 + greenF * 0.072310 + blueF * 0.986039
        
        let x = X / (X + Y + Z)
        let y = Y / (X + Y + Z)
        
        let urlForPut: URL = URL(string: "http://192.168.1.64/api/MAwfbzshj18WUCafSSU6AqQjT6dNiaGlTpJYs6n4/lights/3/state")!
        let body: NSMutableDictionary = NSMutableDictionary()
        
        body.setValue([x,y], forKey: "xy")
        
        try! self.put(url: urlForPut, body: body, completionHandler: { data, response, error in
        })
        
        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
