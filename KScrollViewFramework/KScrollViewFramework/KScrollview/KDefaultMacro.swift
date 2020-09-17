//
//  KDefaultMacro.swift
//  KProgressFramework
//
//  Created by 疯狂1024 on 2020/9/16.
//  Copyright © 2020 疯狂1024. All rights reserved.
//

import UIKit

let KScreen_Width = UIScreen.main.bounds.width
let KScreen_Height = UIScreen.main.bounds.height

// iphone6s为适配的宽度尺寸比例
func kScaleWidth(_ width:CGFloat) -> CGFloat { return ((width)*(KScreen_Width/375.0))}
// 判断是否iphone6P
let IsIphone6P = (KScreen_Width == 414.0 ? true : false)

let KSizeScale = (IsIphone6P ? 1.2 : 1)
// 字体适配
func kFontSize(_ value:CGFloat) -> CGFloat{ return value * CGFloat(KSizeScale)}

class KDefaultMacro: NSObject {

}
///UIImage拓展
extension UIImage {
    /**
     *  重设图片大小
     */
    func setSizeImage(_ setSize:CGSize)->UIImage {
        //UIGraphicsBeginImageContext(reSize);
        UIGraphicsBeginImageContextWithOptions(setSize,false,UIScreen.main.scale)
        draw(in: CGRect(x: 0, y: 0, width: setSize.width, height: setSize.height))
        let reSizeImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext();
        return reSizeImage;
    }
    
    /**
     *  等比率缩放
     */
    func scaleImage(scaleSize:CGFloat)->UIImage {
        let reSize = CGSize(width: self.size.width * scaleSize, height: self.size.height * scaleSize)
        return setSizeImage(reSize)
    }
    
}
