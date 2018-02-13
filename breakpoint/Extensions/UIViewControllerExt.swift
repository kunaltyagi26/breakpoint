//
//  File.swift
//  breakpoint
//
//  Created by Kunal Tyagi on 04/02/18.
//  Copyright © 2018 Kunal Tyagi. All rights reserved.
//

import UIKit

extension UIViewController {
    func presentDetail(viewControllerToPresent: UIViewController) {
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = kCATransitionMoveIn
        transition.subtype = kCATransitionFromRight
        self.view.window?.layer.add(transition, forKey: kCATransition)
        present(viewControllerToPresent, animated: false, completion: nil)
    }
    
    func dismissDetail() {
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = kCATransitionMoveIn
        transition.subtype = kCATransitionFromLeft
        self.view.window?.layer.add(transition, forKey: kCATransition)
        dismiss(animated: false, completion: nil)
    }
}

