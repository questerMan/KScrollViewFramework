//
//  KCollectionViewFlowLayout.swift
//  KScrollviewDemo
//
//  Created by 疯狂1024 on 2020/9/14.
//  Copyright © 2020 疯狂1024. All rights reserved.
//

import UIKit

class KCollectionViewFlowLayout: UICollectionViewFlowLayout {

    
    private var animationIsHiden:Bool?                     // 是否有动画
    private var animationEstimate:CGFloat?                 // 动画系数
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let attributes:Array<UICollectionViewLayoutAttributes> = NSArray(array: super.layoutAttributesForElements(in: rect) ?? NSArray.init() as!  [UICollectionViewLayoutAttributes], copyItems: true) as! Array<UICollectionViewLayoutAttributes>
        
        //let attributes = super.layoutAttributesForElements(in: rect)
        if !(self.animationIsHiden ?? true) { return (attributes )}
        // 2.计算整体的中心点的x值
        let centerX:CGFloat = (self.collectionView?.contentOffset.x)! + (self.collectionView?.bounds.size.width)!*0.5
        
        // 3.修改一下attributes对象
        for item in attributes{
            // 3.1 计算每个cell的中心点距离
            let distance:CGFloat = abs(item.center.x - centerX)
             // 3.2 距离越大，缩放比越小，距离越小，缩放比越大
            let factor:CGFloat = (self.animationEstimate ?? 0)/100
            let f:CGFloat = (1+distance*factor)
            let scale = 1/f
            item.transform =  CGAffineTransform(scaleX: scale, y: scale)//CGAffineTransformMakeScale
        }
        return attributes
    }
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
    override init() {
        super.init()
        self.setConfig()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setConfig() {
        animationIsHiden = true
        animationEstimate = 0.2
    }
    
}

extension KCollectionViewFlowLayout {
    @discardableResult  
    internal func K_MakeAnimationIsHiden(_ animationIsHiden: Bool) -> KCollectionViewFlowLayout {
        self.animationIsHiden = animationIsHiden
        return self
    }
    
    @discardableResult
    internal func K_MakeAnimationEstimate(_ animationEstimate: CGFloat) -> KCollectionViewFlowLayout {
        self.animationEstimate = animationEstimate
        return self
    }
    //itemSize
    @discardableResult
    internal func K_MakeItemSize(_ itemSize: CGSize) -> KCollectionViewFlowLayout {
        self.itemSize = itemSize
        return self
    }
    //minimumInteritemSpacing
    @discardableResult
    internal func K_MakeMinimumInteritemSpacing(_ minimumInteritemSpacing: CGFloat) -> KCollectionViewFlowLayout {
        self.minimumInteritemSpacing = minimumInteritemSpacing
        return self
    }
    //minimumLineSpacing
    @discardableResult
    internal func K_MakeMinimumLineSpacing(_ minimumLineSpacing: CGFloat) -> KCollectionViewFlowLayout {
        self.minimumLineSpacing = minimumLineSpacing
        return self
    }
    //scrollDirection
    @discardableResult
    internal func K_MakeScrollDirection(_ scrollDirection: UICollectionView.ScrollDirection) -> KCollectionViewFlowLayout {
        self.scrollDirection = scrollDirection
        return self
    }
    //sectionInset
    @discardableResult
    internal func K_MakeSectionInset(_ sectionInset: UIEdgeInsets) -> KCollectionViewFlowLayout {
        self.sectionInset = sectionInset
        return self
    }
    
    @discardableResult
    internal static func K_ShareInitView(_ blcokView:(KCollectionViewFlowLayout) -> Void) -> KCollectionViewFlowLayout {
        let flowView = KCollectionViewFlowLayout.init()
        blcokView(flowView)
        return flowView
    }
}
