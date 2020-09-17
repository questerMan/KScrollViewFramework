//
//  KCollectionViewCell.swift
//  KScrollviewDemo
//
//  Created by 疯狂1024 on 2020/9/14.
//  Copyright © 2020 疯狂1024. All rights reserved.
//

import UIKit

class KCollectionViewCell: UICollectionViewCell {
   
    lazy var imageview:UIImageView = {
        let imageview = UIImageView.init(frame: self.bounds)
        let bezierPath = UIBezierPath.init(roundedRect: imageview.bounds, cornerRadius: kScaleWidth(10))
        let shapeLayer = CAShapeLayer.init()
        shapeLayer.frame = self.bounds
        shapeLayer.path = bezierPath.cgPath
        imageview.layer.mask = shapeLayer
        imageview.contentMode = .scaleAspectFill
        return imageview
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.contentView.addSubview(imageview)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
extension KCollectionViewCell {
    @discardableResult // 取消警告
    internal func K_MakeGetDataOfIMG(_ image: UIImage) -> KCollectionViewCell {
        self.imageview.image = image
        return self
    }
    @discardableResult 
    internal func K_MakeBorderWidth(_ borderWidth: CGFloat) -> KCollectionViewCell {
        self.imageview.layer.borderWidth = borderWidth
        return self
    }
    @discardableResult
    internal func K_MakeBorderColor(_ borderColor: UIColor) -> KCollectionViewCell {
        self.imageview.layer.borderColor = borderColor.cgColor
        return self
    }
    @discardableResult
    internal func K_MakeBGColor(_ bgColor: UIColor) -> KCollectionViewCell {
        self.contentView.backgroundColor = bgColor
        return self
    }
}
