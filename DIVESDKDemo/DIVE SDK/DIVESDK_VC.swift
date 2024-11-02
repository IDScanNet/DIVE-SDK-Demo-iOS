//
//  DIVESDK_VC.swift
//  DIVESDKDemo
//
//  Created by AKorotkov on 28.09.2023.
//

import Foundation
import UIKit
import DIVESDK
import DIVESDKCommon

class DIVESDK_VC: UIViewController, DIVESDKDelegate {
    
    var sdk: DIVESDK?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let json = loadJson(filename: "ConfigDemo"), let sdk = DIVESDK(configuration: json, token: <# Put your token here #>, delegate: self) {
            self.sdk = sdk
        }
    }
    
    @IBAction func startAction(_ sender: Any) {
        self.sdk?.start(from: self)
    }
    
    private func openResult(result: [String : Any]) {
        if let theJSONData = try? JSONSerialization.data(withJSONObject: result, options: [.prettyPrinted]) {
            let theJSONText = String(data: theJSONData, encoding: .ascii)
            
            let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
            let resultVC = storyboard.instantiateViewController(withIdentifier: "Result_VC") as! Result_VC
            resultVC.loadView()
            resultVC.textView.text = theJSONText
            self.navigationController?.pushViewController(resultVC, animated: true)
        }
    }
    
    // MARK: - DIVESDKDelegate
    
    func diveSDKDataPrepaired(sdk: IDIVESDK, data: DIVESDKData) {
        sdk.close()
        
        //You can do something with the captured data and decide whether to send it.
        self.showWaitingAlert(message: "💭\n\nUploading data")
        sdk.sendData(data: data)
    }

    func diveSDKResult(sdk: IDIVESDK, result: [String : Any]) {
        self.dismissWaitingAlert()
        self.openResult(result: result)
    }
    
    func diveSDKSendingDataProgress(sdk: IDIVESDK, progress: Float, requestTime: TimeInterval) {
        let progressPercent = "\(round((progress * 100) * 100) / 100.0)%"
        let progressStr = progress == 1 ? "Validation" : "Uploading data: \(progressPercent)"
        self.showWaitingAlert(message: "💭\n\n\(progressStr)")
    }
    
    func diveSDKError(sdk: IDIVESDK, error: Error) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.showOKAlert(title: "❗️\nError", message: error.localizedDescription)
        }
    }
}
