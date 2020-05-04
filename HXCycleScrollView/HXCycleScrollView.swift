//
//  HXCycleScrollView.swift
//  HXCycleScrollView
//
//  Created by wuhongxing on 2020/5/1.
//  Copyright © 2020 zto. All rights reserved.
//

import UIKit
import Kingfisher

/// PageControl 的对齐方式
public enum HXCycleScrollViewPageControlAlignment {
    case center
    case right(offset: CGFloat)
}

/// PageControl 的 Style
/// 这个后面的 animated 需要加一些参数，让我们可以自由的配置
/// 或者再增加一些其他的自定义的 case
public enum HXCycleScrollViewPageControlStyle {
    case `default`
    case animated
}

protocol HXCycleScrollViewDelegate: class {
    func cycleScrollView(_ scrollView: HXCycleScrollView, didSelectItemAt index: Int)
    func cycleScrollView(_ scrollView: HXCycleScrollView, didScrollTo index: Int)
}

extension HXCycleScrollViewDelegate {
    func cycleScrollView(_ scrollView: HXCycleScrollView, didSelectItemAt index: Int) { }
    func cycleScrollView(_ scrollView: HXCycleScrollView, didScrollTo index: Int) { }
}

public class HXCycleScrollView: UIView {
    
    var imagePathArray: [String] = [String]() {
        didSet {
            collectionView.isScrollEnabled = !isSingleImage
            (isAutoScroll && !isSingleImage) ? setupTimer() : invalidateTimer()
            setupPageControl()
            collectionView.reloadData()
        }
    }
    
    var titleArray: [String] = [String]() {
        didSet {
            if isOnlyDisplayText {
                imagePathArray = (0 ..< titleArray.count).map { _ in "" }
                backgroundColor = .clear
            }
        }
    }
    
    var timeInterval: TimeInterval = 2 {
        didSet {
            setupTimer()
        }
    }
    
    var isAutoScroll: Bool = true {
        didSet {
            setupTimer()
        }
    }
    
    var scrollDirection: UICollectionView.ScrollDirection = .horizontal {
        didSet {
            flowLayout.scrollDirection = scrollDirection
        }
    }
    
    weak var delegate: HXCycleScrollViewDelegate?
    
    var infiniteLoop: Bool = true
    var imageContentMode: UIView.ContentMode = .scaleAspectFit
    var placeholderContentMode: UIView.ContentMode = .scaleAspectFill
    
    var placeholderImage: UIImage? {
        didSet {
            backgroundImageView.image = placeholderImage
        }
    }
    var showPageControl: Bool = true {
        didSet {
            pageControl?.isHidden = !showPageControl
        }
    }
    var hidesForSinglePage: Bool = true
    var isOnlyDisplayText: Bool = false
    
    var pageControlStyle: HXCycleScrollViewPageControlStyle = .default {
        didSet {
            setupPageControl()
        }
    }
    var pageControlDotSize: CGSize = CGSize(width: 10, height: 10) {
        didSet {
            setupPageControl()
        }
    }
    var pageControlAlignment: HXCycleScrollViewPageControlAlignment = .center
    
    var currentDotColor: UIColor = .white {
        didSet {
            if let p = pageControl as? UIPageControl {
                p.currentPageIndicatorTintColor = currentDotColor
            } else if let p = pageControl as? HXPageControl {
                p.currentDotColor = currentDotColor
            }
        }
    }
    var dotColor: UIColor = .lightGray {
        didSet {
            if let p = pageControl as? UIPageControl {
                p.pageIndicatorTintColor = dotColor
            } else if let p = pageControl as? HXPageControl {
                p.dotColor = dotColor
            }
        }
    }
    var dotImageSelected: UIImage? {
        didSet {
            if pageControlStyle != .animated {
                pageControlStyle = .animated
            }
            if let image = dotImageSelected {
                setCustomPageControlDotImage(image: image, isCurrent: true)
            }
        }
    }
    var dotImageNormal: UIImage? {
        didSet {
            if pageControlStyle != .animated {
                pageControlStyle = .animated
            }
            if let image = dotImageNormal {
                setCustomPageControlDotImage(image: image, isCurrent: false)
            }
        }
    }
    var titleLabelTextColor: UIColor = .white
    var titleLabelTextFont: UIFont = .systemFont(ofSize: 14)
    var titleLabelBackgroundColor: UIColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
    var titleLabelHeight: CGFloat = 30
    var titleLabelTextAlignment: NSTextAlignment = .left
    
    // 后续可以增加 block 的方式来调用，暂时不实现
    var clickCallback: ((Int) -> Void)?
    var scrollCallback: ((Int) -> Void)?
    
    private var timer: Timer?
    private var pageControl: UIControl?
    private lazy var backgroundImageView: UIImageView = {
        let backgroundImageView = UIImageView()
        backgroundImageView.contentMode = placeholderContentMode
        insertSubview(backgroundImageView, belowSubview: collectionView)
        return backgroundImageView
    }()
    private var isSingleImage: Bool {
        return imagePathArray.count <= 1
    }
    private var totalItemsCount: Int {
        return infiniteLoop ? imagePathArray.count * 100 : imagePathArray.count
    }
    
    private func setupPageControl() {
        if let pageControl = pageControl {
            pageControl.removeFromSuperview()
        }
        if imagePathArray.count == 0 || isOnlyDisplayText || (imagePathArray.count == 1 && hidesForSinglePage) {
            return
        }
        switch pageControlStyle {
        case .animated:
            pageControl = HXPageControl()
            if let p = pageControl as? HXPageControl {
                p.numberOfPages = imagePathArray.count
                p.currentDotColor = currentDotColor
                p.dotColor = dotColor
                p.isUserInteractionEnabled = false
                p.currentPage = currentPageControlIndex
                addSubview(p)
            }
        case .default:
            pageControl = UIPageControl()
            if let p = pageControl as? UIPageControl {
                p.numberOfPages = imagePathArray.count
                p.isUserInteractionEnabled = false
                p.currentPage = currentPageControlIndex
                p.currentPageIndicatorTintColor = currentDotColor
                p.pageIndicatorTintColor = dotColor
                addSubview(p)
            }
        }
        if let image = dotImageSelected {
            dotImageSelected = image
        }
        
        if let image = dotImageNormal {
            dotImageNormal = image
        }
    }
    
    private func setCustomPageControlDotImage(image: UIImage, isCurrent: Bool) {
        if let p = pageControl as? HXPageControl {
            if isCurrent {
                p.currentDotImage = image
            } else {
                p.dotImage = image
            }
        }
    }
    
    private var currentIndex: Int {
        guard collectionView.bounds.size != .zero else {
            return 0
        }
        var index = 0
        if flowLayout.scrollDirection == .horizontal {
            index = Int((collectionView.contentOffset.x + flowLayout.itemSize.width * 0.5) / flowLayout.itemSize.width)
        } else {
            index = Int((collectionView.contentOffset.y + flowLayout.itemSize.height * 0.5) / flowLayout.itemSize.height)
        }
        return max(0, index)
    }
    
    private var currentPageControlIndex: Int {
        return currentIndex % imagePathArray.count
    }
    
    private lazy var flowLayout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.scrollDirection = .horizontal
        return layout
    }()
    
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: bounds, collectionViewLayout: flowLayout)
        collectionView.isPagingEnabled = true
        collectionView.backgroundColor = .clear
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.scrollsToTop = false
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(HXCollectionViewCell.self, forCellWithReuseIdentifier: "HXCollectionViewCell")
        return collectionView
    }()
    
    // MARK: Override
    public convenience init(frame: CGRect, imageNames: [String] = [], infiniteLoop: Bool = true) {
        self.init(frame: frame)
        
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .lightGray
        addSubview(collectionView)
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        backgroundColor = .lightGray
        addSubview(collectionView)
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        flowLayout.itemSize = frame.size
        collectionView.frame = bounds
        if collectionView.contentOffset.x == 0 && totalItemsCount > 0 {
            collectionView.scrollToItem(at: IndexPath(item: infiniteLoop ? totalItemsCount / 2 : 0, section: 0), at: .left, animated: false)
        }
        var size: CGSize = .zero
        if let p = pageControl as? HXPageControl {
            size = p.sizeForNumber(of: imagePathArray.count)
        } else {
            size = CGSize(width: CGFloat(imagePathArray.count) * pageControlDotSize.width * 1.5, height: pageControlDotSize.height)
        }
        var x = (bounds.width - size.width ) / 2
        if case let HXCycleScrollViewPageControlAlignment.right(offset) = pageControlAlignment {
            x = collectionView.bounds.width - size.width - 10 + offset
        }
        let y = collectionView.bounds.height - size.height - 10
        if let p = pageControl as? HXPageControl {
            p.sizeToFit()
        }
        pageControl?.frame = CGRect(x: x, y: y, width: size.width, height: size.height)
        pageControl?.isHidden = !showPageControl
        backgroundImageView.frame = bounds
    }
    
    // 禁用滑动手势
    public func disableScrollGesture() {
        collectionView.canCancelContentTouches = false
        collectionView.gestureRecognizers?.forEach({ (gesture) in
            if gesture.isKind(of: UIPanGestureRecognizer.self) {
                collectionView.removeGestureRecognizer(gesture)
            }
        })
    }
    
    //MARK: timer
    private func setupTimer() {
        invalidateTimer()
        guard isAutoScroll else { return }
        timer = Timer.scheduledTimer(withTimeInterval: timeInterval, repeats: true, block: { [weak self] (timer) in
            guard let self = self else { return }
            self.autoScroll()
        })
        RunLoop.main.add(timer!, forMode: .common)
    }
    
    @objc private func autoScroll() {
        guard totalItemsCount > 0 else { return }
        scroll(to: currentIndex + 1)
    }
    
    private func scroll(to targetIndex: Int) {
        if targetIndex >= totalItemsCount && infiniteLoop {
            collectionView.scrollToItem(at: IndexPath(item: totalItemsCount / 2, section: 0), at: [.left, .top], animated: false)
        } else {
            collectionView.scrollToItem(at: IndexPath(item: targetIndex, section: 0), at: [.left, .top], animated: true)
        }
    }
    
    private func invalidateTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    // MARK: clearCache
    public static func clearCache() {
        ImageCache.default.clearDiskCache()
    }
    
    deinit {
        print("HXCycleScrollView deinit")
    }
}

extension HXCycleScrollView: UICollectionViewDelegate, UICollectionViewDataSource {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return totalItemsCount
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: HXCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "HXCollectionViewCell", for: indexPath) as! HXCollectionViewCell
        cell.imageName = imagePathArray[indexPath.item % imagePathArray.count]
        if indexPath.item % imagePathArray.count < titleArray.count {
            cell.title = titleArray[indexPath.item % imagePathArray.count]
        }
        if !cell.hasConfigured {
            cell.titleLabelBackgroundColor = titleLabelBackgroundColor
            cell.titleLabelHeight = titleLabelHeight
            cell.titleLabelTextAlignment = titleLabelTextAlignment
            cell.titleLabelTextColor = titleLabelTextColor
            cell.titleLabelTextFont = titleLabelTextFont
            cell.hasConfigured = true
            cell.imageViewContentMode = imageContentMode
            cell.clipsToBounds = true
            cell.isOnlyDisplayText = isOnlyDisplayText
        }
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.cycleScrollView(self, didSelectItemAt: currentPageControlIndex)
    }
}

extension HXCycleScrollView: UIScrollViewDelegate {
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        switch pageControl {
        case let pageControl as UIPageControl:
            pageControl.currentPage = currentPageControlIndex
        case let pageControl as HXPageControl:
            pageControl.currentPage = currentPageControlIndex
        default: break
        }
    }
    
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        invalidateTimer()
    }
    
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        setupTimer()
    }
    
    public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        delegate?.cycleScrollView(self, didScrollTo: currentPageControlIndex)
    }
}
