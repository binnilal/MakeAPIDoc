//
//  MethodSwizzle.swift
//  MakeAPIDocumentation
//
//  Created by Tawakal Express on 09/08/2022.
//

import UIKit

extension UIViewController {
    @objc dynamic func _tracked_viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.post(name: NSNotification.Name("ViewControllerChangedEvent"), object: self)
        _tracked_viewWillAppear(animated)
    }

    static func swizzle() {
        //Make sure This isn't a subclass of UIViewController,
        // So that It applies to all UIViewController childs
        if self != UIViewController.self {
            return
        }
        let _: () = {
            let originalSelector =
                #selector(UIViewController.viewWillAppear(_:))
            let swizzledSelector =
                #selector(UIViewController._tracked_viewWillAppear(_:))
            if let originalMethod =
                class_getInstanceMethod(self, originalSelector), let swizzledMethod =
                class_getInstanceMethod(self, swizzledSelector) {
                method_exchangeImplementations(originalMethod, swizzledMethod)
            }
            
        }()
    }
}
