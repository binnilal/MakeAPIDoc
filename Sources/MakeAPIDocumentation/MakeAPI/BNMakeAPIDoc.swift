//
//  MakeAPI.swift
//  MakeAPIDocumentation
//
//  Created by Binnilal on 06/08/2022.
//

import Foundation
import UIKit

public class BNMakeAPIDoc {
    
    public static let shared: BNMakeAPIDoc = BNMakeAPIDoc()
    
    init() {
        
        UIViewController.swizzle()
        NotificationCenter.default.addObserver(self, selector: #selector(viewControllerChanged), name: NSNotification.Name("ViewControllerChangedEvent"), object: nil)
    }
    
    // Configuration
    var isEnableAPIDocShareButton: Bool = false
    let makePDF: BNMakePDF = BNMakePDF()
    
    public func setUP() {
        CoreDataManager.setUp(withDataModel: "NetworkData", presistentStoreName: "NetworkData",
                              presistentStoryType: .sqLite)
        self.isEnableAPIDocShareButton = true
        self.initialiseUI()
    }
    
    func saveRestAPI(ofAPI restApi: RestAPIData) {
        CoreDataManager.saveRestAPI(ofAPI: restApi)
    }
    
    func exportAPIDocument() {
        self.makePDF.makePDF()
    }
    
    @objc func viewControllerChanged() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.configureShareButton()
        }
    }
    
    
    // Private methods
    private func initialiseUI() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.configureShareButton()
        }
    }
    

    private func configureShareButton() {
        guard BNMakeAPIDoc.shared.isEnableAPIDocShareButton else {
            return
        }
        

        if let rootVC: UINavigationController = UIApplication.topWindow.rootViewController as? UINavigationController {
            let vc = rootVC.viewControllers[rootVC.viewControllers.count - 1]
            self.addConstraintsToShareButton(superView: vc.view)
        } else if let rootVC: UITabBarController = UIApplication.topWindow.rootViewController as? UITabBarController {
            if let vc = rootVC.selectedViewController {
                self.addConstraintsToShareButton(superView: vc.view)
            }
        } else if let rootVC: UIViewController = UIApplication.topWindow.rootViewController {
            self.addConstraintsToShareButton(superView: rootVC.view)
        }
        shareButton.addTarget(self, action: #selector(shareAPI), for: .touchUpInside)
    }
    
    private func addConstraintsToShareButton(superView view: UIView) {
        
        self.shareButton.removeAllConstraintOfButton()
        self.shareButton.removeFromSuperview()
        
        view.addSubview(shareButton)
        
        NSLayoutConstraint.activate([
            shareButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 60.0),
            shareButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8.0),
            shareButton.widthAnchor.constraint(equalToConstant: 89.0),
            shareButton.heightAnchor.constraint(equalToConstant: 24.0)
        ])
    }

    

    @objc func shareAPI() {
        BNMakeAPIDoc.shared.exportAPIDocument()
    }
    
    var shareButton: UIButton = {
        let button: UIButton = UIButton(type: .custom)
        let image = "mk_share_api".image
        button.setImage(image, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = .white
        return button
    }()
}

extension UIApplication {
  static var topWindow: UIWindow {
    if #available(iOS 15.0, *) {
      let scenes = UIApplication.shared.connectedScenes
      let windowScene = scenes.first as? UIWindowScene
      return windowScene!.windows.first!
    }
    return UIApplication.shared.windows.filter { $0.isKeyWindow }.first!
  }
}

extension String {
    var image: UIImage? {
        if #available(iOS 13.0, *) {
            return UIImage(named: self, in: Bundle(identifier: "com.binni.MakeAPIDocumentation"), with: nil)
        } else {
            return nil
        }
    }
}

extension UIButton {
    func removeAllConstraintOfButton() {
        for constraint in self.constraints {
            self.removeConstraint(constraint)
        }
        
        if let view = self.superview {
            for constraint in view.constraints {
                if let button = constraint.secondItem as? UIButton, button == self {
                    print("Is button")
                    view.removeConstraint(constraint)
                }
                if let button = constraint.firstItem as? UIButton, button == self {
                    print("Is button")
                    view.removeConstraint(constraint)
                }
            }
        }
    }
}
