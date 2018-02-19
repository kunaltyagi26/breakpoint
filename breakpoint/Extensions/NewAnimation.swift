//
//  NewAnimation.swift
//  breakpoint
//
//  Created by Kunal Tyagi on 19/02/18.
//  Copyright © 2018 Kunal Tyagi. All rights reserved.
//

import Foundation
import RAMAnimatedTabBarController

class NewAnimation: RAMItemAnimation {
    
    override func playAnimation(_ icon: UIImageView, textLabel: UILabel) {
        playBounceAnimation(icon)
        textLabel.textColor = #colorLiteral(red: 0.6187600493, green: 0.836951673, blue: 0.3785187602, alpha: 1)
        icon.tintColor = #colorLiteral(red: 0.6187600493, green: 0.836951673, blue: 0.3785187602, alpha: 1)
    }
    
    override func deselectAnimation(_ icon: UIImageView, textLabel: UILabel, defaultTextColor: UIColor, defaultIconColor: UIColor) {
        textLabel.textColor = UIColor.gray
        icon.tintColor = UIColor.gray
    }
    
    override func selectedState(_ icon: UIImageView, textLabel: UILabel) {
        textLabel.textColor = #colorLiteral(red: 0.6187600493, green: 0.836951673, blue: 0.3785187602, alpha: 1)
        icon.tintColor = #colorLiteral(red: 0.6187600493, green: 0.836951673, blue: 0.3785187602, alpha: 1)
    }
    
    func playBounceAnimation(_ icon : UIImageView) {
        
        let bounceAnimation = CAKeyframeAnimation(keyPath: "transform.scale")
        bounceAnimation.values = [1.0 ,1.4, 0.9, 1.15, 0.95, 1.02, 1.0]
        bounceAnimation.duration = TimeInterval(duration)
        bounceAnimation.calculationMode = kCAAnimationCubic
        
        icon.layer.add(bounceAnimation, forKey: "bounceAnimation")
    }
}
