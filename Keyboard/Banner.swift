//
//  Banner.swift
//  SnapBoard
//
//  Created by Grant Magdanz on 9/24/15.
//  Copyright (c) 2015 Apple. All rights reserved.
//

import UIKit

class Banner: ExtraView {
    var icon: UIImage = UIImage(named: "banner")!
    var iconView: UIImageView
    
    required init(globalColors: GlobalColors.Type?, darkMode: Bool, solidColorMode: Bool) {
        iconView = UIImageView(image: icon)
        // TODO: hard coded values
        iconView.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        iconView.layer.cornerRadius = 6
        iconView.clipsToBounds = true
        
        // add shadow to make button look pressed
        iconView.layer.shadowOffset = CGSize(width: 1, height: 1)
        iconView.layer.shadowOpacity = 1
        iconView.layer.shadowRadius = 5
        
        super.init(globalColors: globalColors, darkMode: darkMode, solidColorMode: solidColorMode)
        self.addSubview(iconView)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setNeedsLayout() {
        super.setNeedsLayout()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.iconView.center = self.center
        // TODO: hardcoded
        self.iconView.frame.origin = CGPointMake(self.iconView.frame.origin.x, 5)
    }
}
