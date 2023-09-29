//
//  AppDelegate.swift
//  DIVESDKDemo
//
//  Created by AKorotkov on 24.10.2022.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        return true
    }
}

func loadJson(filename fileName: String) -> [String: Any]? {
    if let path = Bundle.main.path(forResource: fileName, ofType: "json") {
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
            let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
            if let jsonResult = jsonResult as? [String: Any] {
                return jsonResult
            }
        } catch {
            print("error:\(error)")
        }
    }
    
    return nil
}

extension String {
    func fromBase64() -> String? {
        guard let data = Data(base64Encoded: self) else { return nil }
        return String(data: data, encoding: .utf8)
    }
    
    func toBase64() -> String {
        return Data(self.utf8).base64EncodedString()
    }
    
    func jsonToDictionary() -> [String: Any]? {
        if let data = self.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
}

extension UIViewController {
    func showOKAlert(title: String?, message: String?) {
        self.dismissWaitingAlert()
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(alertController, animated: true)
    }
    
    func showWaitingAlert(message: String, for sec: TimeInterval? = nil) {
        if let alertController = self.currentWaitingAlertController() {
            UIView.transition(with: alertController.view, duration: 0.2, options: [.transitionCrossDissolve, .curveEaseInOut], animations: {
                alertController.message = message
            }, completion: nil)
        } else {
            let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
            alertController.view.tag = 938468347
            self.present(alertController, animated: true)
        }
        
        if let sec = sec {
            DispatchQueue.main.asyncAfter(deadline: .now() + sec) {
                self.dismissWaitingAlert()
            }
        }
    }
    
    func dismissWaitingAlert() {
        if let alertController = self.currentWaitingAlertController() {
            alertController.dismiss(animated: true)
        }
    }
    
    fileprivate func currentWaitingAlertController() -> UIAlertController? {
        guard let window = UIApplication.shared.keyWindow, let rootViewController = window.rootViewController else {
            return nil
        }
        
        var topController = rootViewController
        
        while let newTopController = topController.presentedViewController {
            topController = newTopController
        }
        
        if let alertController = topController as? UIAlertController {
            if alertController.actions.count == 0 && alertController.view.tag == 938468347 {
                return alertController
            }
        }
        
        return nil
    }
}
