//
//  KScrollview.swift
//  KScrollviewDemo
//
//  Created by 疯狂1024 on 2020/9/14.
//  Copyright © 2020 疯狂1024. All rights reserved.
//

import UIKit

@objc public protocol KScrollviewDelegate:class {
    @objc optional func didSelectItem(index:Int) -> Void
}

@objc public class KScrollview: UIView {
    
    private var currentIndext:Int = 1 {
        didSet {
            if currentIndext == 0 {
                page.currentPage = self.dataArray.count - 2
            } else if currentIndext == self.dataArray.count - 1 {
                page.currentPage = 0
            } else {
                page.currentPage = currentIndext - 1
            }
            
        }
    }                    // 当前展示图片的序号
    private weak var delegate:KScrollviewDelegate?
    
    private var item_width:CGFloat?                     // 图片宽度
    private var item_heiht:CGFloat?                     // 图片高度
    private var marginDistanDce_LeftAndRight:CGFloat?   // 边缘左右距离
    private var marginDistanDce_TopAndBottom:CGFloat?   // 边缘上下距离
    private var margin_BGColor:UIColor?                 // 边缘背景颜色
    private var border_width:CGFloat?                   // 边框宽度
    private var border_color:UIColor?                   // 边框颜色
    private var page_Tintcolor:UIColor?                 // 标点背景颜色
    private var page_CurrentTintColor:UIColor?          // 当前标点显示颜色
    private var page_BottomMarginDistanDce:CGFloat?      // 标点视图距离下边沿的距离
    private var isAnimation:Bool?                       // 是否有动画
    private var animationEstimate:CGFloat?              // 动画幅度系数 0~1之间
    
    private var isAutoScroll:Bool?                      // 是否自动滚动
    private var timeInterval:TimeInterval?              // 滚动间隔时间（秒:s）
    private var timer:Timer?
    
    // 图片数据
    private var dataArray:[UIImage] = [] {
        didSet {
            let firstItem = dataArray.first ?? UIImage()
            let lastItem = dataArray.last ?? UIImage()
            // 再添加两张前后相片进去，以免卡顿顺畅滑动视图图片
            dataArray.append(firstItem)                   // 把第一个放到最后位
            dataArray.insert(lastItem, at: 0)             // 把最后一个放到第一位
        }
    }
    
    let cellIdentifier = "cell_ID"
    
    /// MARK ： 懒加载视图
    lazy var layoutView:KCollectionViewFlowLayout = {
        // 图片宽度
        item_width = self.frame.size.width - 2*(self.marginDistanDce_LeftAndRight ?? 0)
        
        return KCollectionViewFlowLayout.K_ShareInitView { (make) in
            make.K_MakeAnimationIsHiden(self.isAnimation ?? true)
                .K_MakeAnimationEstimate(self.animationEstimate ?? 0)
                .K_MakeItemSize(CGSize(width: item_width ?? 0, height: item_heiht ?? 0))
                .K_MakeMinimumLineSpacing(2*(marginDistanDce_LeftAndRight ?? 0))      // line 跟滚动方向相同的间距
                .K_MakeMinimumInteritemSpacing(2*(marginDistanDce_TopAndBottom ?? 0)) // item 跟滚动方向垂直的间距
                .K_MakeScrollDirection(.horizontal)
                .K_MakeSectionInset(UIEdgeInsets(top: marginDistanDce_TopAndBottom ?? 0, left: marginDistanDce_LeftAndRight ?? 0, bottom: marginDistanDce_TopAndBottom ?? 0, right: marginDistanDce_LeftAndRight ?? 0))
        }
    }()
    
    lazy var collectionView: UICollectionView = {
        let collection = UICollectionView.init(frame: self.bounds, collectionViewLayout: self.layoutView)
        collection.dataSource = self
        collection.delegate = self
        collection.backgroundColor = .white
        collection.showsVerticalScrollIndicator = false
        collection.showsHorizontalScrollIndicator = false
        collection.isPagingEnabled = true
        collection.register(KCollectionViewCell.classForCoder(), forCellWithReuseIdentifier: cellIdentifier)
        return collection
    }()
    
    lazy var page:UIPageControl = {
        let w =  kScaleWidth(160)
        let h = kScaleWidth(15)
        let y = self.frame.height - h - (self.page_BottomMarginDistanDce ?? 0)
        let x = (self.frame.width-w)/2
        let page = UIPageControl.init(frame: CGRect(x: x, y: y, width: w, height: h))
        page.currentPage = 1
        page.pageIndicatorTintColor = self.page_Tintcolor
        page.currentPageIndicatorTintColor = self.page_CurrentTintColor
        return page
    }()
    private lazy var setupOneUI: Void = {
        self.creatUI()
        self.setTimer()
    }()
    
    @objc public override func layoutSubviews() {
        super.layoutSubviews()
        let _ = setupOneUI
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initConfig()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        stopTimer()
    }
}

extension KScrollview {
    /// MARK： 配置信息
    private func initConfig(){
        item_heiht = kScaleWidth(160)                      // 图片高度
        marginDistanDce_LeftAndRight = kScaleWidth(5)      // 边缘左右距离
        marginDistanDce_TopAndBottom = kScaleWidth(5)      // 边缘上下距离
        margin_BGColor = .white                            // 边缘背景颜色
        border_width = kScaleWidth(1)                      // 边框宽度
        border_color = .white                              // 边框颜色
        isAnimation = true                                 // 是否有动画
        animationEstimate = 0.2                            // 动画系数
        isAutoScroll = true
        timeInterval = 3
        page_Tintcolor = .white
        page_CurrentTintColor = .green
        page_BottomMarginDistanDce = kScaleWidth(5)
    }
    /// MARK： 创建UI
    private func creatUI(){
        self.frame = CGRect(x: self.frame.origin.x, y: self.frame.origin.y, width: self.frame.size.width, height: (item_heiht ?? 0)+2*(marginDistanDce_TopAndBottom ?? 0))
        self.collectionView.backgroundColor = margin_BGColor
        self.collectionView.contentOffset = CGPoint(x: self.frame.size.width * CGFloat(currentIndext), y: 0)
        self.addSubview(collectionView)
        self.addSubview(page)
    }
    
    private func setTimer() {

        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+(self.timeInterval ?? 0)) {
            if self.timer == nil && (self.isAutoScroll ?? true){
                let timerT = Timer.scheduledTimer(timeInterval: self.timeInterval ?? 3, target: self, selector: #selector(self.timerRunning), userInfo: nil, repeats: true)
                RunLoop.main.add(timerT, forMode: .default)
                self.timer = timerT

                // 调用fire()会立即启动计时器
                self.timer?.fire()
            }
        }
    }

    // 3.定时操作
    @objc private func timerRunning() {
        if currentIndext == dataArray.count-1 {
            currentIndext = 1
            self.collectionView.setContentOffset(CGPoint(x: self.bounds.width, y: 0), animated: false)
        }
        currentIndext += 1
        self.collectionView.setContentOffset(CGPoint(x: self.bounds.width*CGFloat(currentIndext), y: 0), animated: true)
    }

    // 4.停止计时
    private func stopTimer() {
        if timer != nil {
            timer!.invalidate() //销毁timer
            timer = nil
        }
    }
    
    private func tapOfchangeCollectionViewPosition(indext: Int) {
        if indext == dataArray.count-1 {
            self.collectionView.setContentOffset(CGPoint(x: self.bounds.width, y: 0), animated: false)
            currentIndext = 1
        }
        else if indext == 0 {
            self.collectionView.setContentOffset(CGPoint(x: self.bounds.width*CGFloat(dataArray.count-1-1), y: 0), animated: false)
            currentIndext = dataArray.count-2
        } else {
            currentIndext = indext
        }
    }
    
    
}
///MARK : UICollectionViewDelegate
extension KScrollview: UICollectionViewDelegate{
    @objc public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        var indext:Int?  // 都减1 ，为了表示从0开始
        if indexPath.row == 0 {
            indext = dataArray.count - 2 - 1
        } else if indexPath.row == dataArray.count - 1 {
            indext = 1 - 1
        } else {
            indext = indexPath.row - 1
        }
        delegate?.didSelectItem?(index: indext ?? 0)
    }
    
    // 当前开始触摸到的内容视图
    @objc public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.stopTimer() //销毁
        let indext = Int(scrollView.contentOffset.x / self.bounds.width)
        print("=============:\(indext)")
    }
    
    // 触摸后显示的内容视图
    @objc public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let indext:Int = Int(scrollView.contentOffset.x / self.bounds.width)
        self.tapOfchangeCollectionViewPosition(indext: indext)

         self.setTimer()
        
    }

    
}

/// MARK : UICollectionViewDataSource
extension KScrollview: UICollectionViewDataSource {
    
    @objc public  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    @objc public  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! KCollectionViewCell
        cell.K_MakeBorderWidth(self.border_width ?? 0)
            .K_MakeBorderColor(self.border_color ?? UIColor.white)
            .K_MakeBGColor(self.margin_BGColor ?? UIColor.white)
            .K_MakeGetDataOfIMG(self.dataArray[indexPath.row])
        return cell
    }
    
}
/// MARK : Public Method 配置属性接口
extension KScrollview {
    @discardableResult
    @objc public  func K_MakeDelegate(_ dalegate: KScrollviewDelegate) -> KScrollview {
        self.delegate = dalegate
        return self
    }
    
    @discardableResult
    @objc public  func K_MakeFrame(_ frame: CGRect) -> KScrollview {
        self.frame = frame
        return self
    }
    @discardableResult
    @objc public  func K_MakeSuperView(_ view: UIView) -> KScrollview {
        view.addSubview(self)
        return self
    }
    
    // 图片高度
    @discardableResult
    @objc public  func K_MakeItem_heiht(_ item_heiht: CGFloat) -> KScrollview {
        self.item_heiht = item_heiht
        return self
    }
    // 边缘左右距离
    @discardableResult
    @objc public  func K_MakeMarginDistanDce_LeftAndRight(_ marginDistanDce_LeftAndRight: CGFloat) -> KScrollview {
        if marginDistanDce_LeftAndRight < (self.frame.size.width/2 - (border_width ?? 0)) && marginDistanDce_LeftAndRight > 0{
            self.marginDistanDce_LeftAndRight = marginDistanDce_LeftAndRight
        }else {
            self.marginDistanDce_LeftAndRight = 0
        }
        return self
    }
    // 边缘上下距离
    @discardableResult
    @objc public  func K_MakeMarginDistanDce_TopAndBottom(_ marginDistanDce_TopAndBottom: CGFloat) -> KScrollview {
        if marginDistanDce_TopAndBottom < (self.frame.size.height/2 - (border_width ?? 0)) && marginDistanDce_TopAndBottom > 0{
            self.marginDistanDce_TopAndBottom = marginDistanDce_TopAndBottom
        }else {
            self.marginDistanDce_TopAndBottom = 0
        }
        return self
    }
    // 边缘背景颜色
    @discardableResult
    @objc public  func K_MakeMargin_BGColor(_ margin_BGColor: UIColor) -> KScrollview {
        self.margin_BGColor = margin_BGColor
        return self
    }
    // 边框宽度
    @discardableResult
    @objc public  func K_MakeBorder_width(_ border_width: CGFloat) -> KScrollview {
        self.border_width = border_width
        return self
    }
    // 边框颜色
    @discardableResult
    @objc public  func K_MakeBorder_color(_ border_color: UIColor) -> KScrollview {
        self.border_color = border_color
        return self
    }
    // 是否有动画
    @discardableResult
    @objc public  func K_MakeIsAnimation(_ isAnimation: Bool) -> KScrollview {
        self.isAnimation = isAnimation
        return self
    }
    // 动画系数
    @discardableResult
    @objc public  func K_MakeAnimationEstimate(_ animationEstimate: CGFloat) -> KScrollview {
        if animationEstimate>0 && animationEstimate<1 {
            self.animationEstimate = animationEstimate
        }else {
            self.animationEstimate = 0.2
        }
        return self
    }
    // 是否自动滚动
    @discardableResult
    @objc public  func K_MakeIsAutoScroll(_ isAutoScroll: Bool) -> KScrollview {
        self.isAutoScroll = isAutoScroll
        return self
    }
    // 滚动间隔时间（秒:s）
    @discardableResult
    @objc public  func K_MakeTimeInterval(_ timeInterval: TimeInterval) -> KScrollview {
        self.timeInterval = timeInterval
        return self
    }
    // 标点背景颜色
    @discardableResult
    @objc public  func K_MakePage_Tintcolor(_ page_Tintcolor: UIColor) -> KScrollview {
        self.page_Tintcolor = page_Tintcolor
        return self
    }
    // 当前标点显示颜色
    @discardableResult
    @objc public  func K_MakePage_CurrentTintColor(_ page_CurrentTintColor: UIColor) -> KScrollview {
        self.page_CurrentTintColor = page_CurrentTintColor
        return self
    }
    // 标点视图距离下边沿的距离
    @discardableResult
    @objc public  func K_MakePage_BottomMarginDistanDce(_ page_BottomMarginDistanDce: CGFloat) -> KScrollview {
        self.page_BottomMarginDistanDce = page_BottomMarginDistanDce
        return self
    }
    // 获取数据
    @discardableResult
    @objc public  func getData(_ dataArray: [UIImage]) -> KScrollview {
        self.dataArray.removeAll()
        self.dataArray = dataArray
        if dataArray.count > 0 {
            self.page.numberOfPages = self.dataArray.count-2
            self.currentIndext = 1
            self.collectionView.contentOffset = CGPoint(x: self.bounds.width, y: 0)
            self.collectionView.reloadData()
        }
        return self
    }
}
/// MARK : Public Method 实例化对象接口
extension KScrollview {

    @discardableResult  
    @objc public  static func K_ShareInitView(_ blcokView:(KScrollview) -> Void) -> KScrollview {
        let view = KScrollview.init()
        blcokView(view)
        view.creatUI()
        return view
    }
}
