//
//  DIVEOnlineSDK_VC.swift
//  DIVESDKDemo
//
//  Created by AKorotkov on 28.09.2023.
//

import Foundation
import UIKit
import DIVEOnlineSDK
import DIVESDKCommon

class DIVEOnlineSDK_VC: UIViewController, DIVESDKDelegate {
    let baseURL = "https://stage.api-diveonline.idscan.net/api/v2"
    var sdk: DIVEOnlineSDK?
        
    @IBOutlet weak var configButton: UIButton!
    @IBOutlet weak var startButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.configButton.layer.borderWidth = 1
        self.configButton.layer.borderColor = UIColor(white: 0, alpha: 0.12).cgColor
    }
    
    @IBAction func loadConfigAction(_ sender: UIButton) {
        self.showWaitingAlert(message: "⚙️\n\nLoading configuration")
        
        DIVEOnlineSDK.getApplicantID(baseURL: self.baseURL) { [weak self] result in
            guard let strongSelf = self else { return }
            // MARK: -
            switch result {
                case .success(let applicantID):
                    strongSelf.sdk = DIVEOnlineSDK(applicantID: applicantID, integrationID: <# Put your integration ID here #>, token: <# Put your token here #>, baseURL: strongSelf.baseURL + "/public", delegate: strongSelf)
                    strongSelf.sdk?.updateLocation()
                    strongSelf.sdk?.loadConfiguration() { [weak strongSelf] error in
                        guard let strongSelf2 = strongSelf else { return }
                        
                        if let error = error {
                            strongSelf2.showOKAlert(title: "❗️\nError", message: error.localizedDescription)
                        } else {
                            strongSelf2.showWaitingAlert(message: "✅\n\nConfig loaded", for: 0.7)
                            strongSelf2.startButton.isEnabled = true
                        }
                    }
                case .failure(let error):
                    strongSelf.showOKAlert(title: "❗️\nError", message: error.localizedDescription)
            }
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

extension DIVEOnlineSDK {
    class func getApplicantID(baseURL: String, handler block: @escaping (Result<String, Error>) -> Void) {
        let url =  baseURL + "/private/Applicants"
        let params = ["firstName" : <# First name #>, "lastName" : <# Last name #>, "phone" : <# Phone #>]
        
        DIVENetwork().request(url: url, method: "POST", parameters: params, token: <# Put your token here #>) { result in
            switch result {
                case .success(let data):
                    if let applicantId = data["applicantId"] as? String {
                        block(.success(applicantId))
                    } else {
                        block(.failure(DIVEError.somethingWentWrong()))
                    }
                case .failure(let error):
                    block(.failure(error))
            }
        }
    }
}
