//
//  HXPageControl.swift
//  HXCycleScrollView
//
//  Created by wuhongxing on 2020/5/2.
//  Copyright © 2020 zto. All rights reserved.
//

import UIKit

protocol HXPageControlDelegate: class {
    func hxPageControl(_ pageControl: HXPageControl, didSelectPageAt index: Int)
}

extension HXPageControlDelegate {
    func hxPageControl(_ pageControl: HXPageControl, didSelectPageAt index: Int) { }
}

class HXPageControl: UIControl {
    var dotViewClass: UIView? {
        didSet {
            resetDotViews()
        }
    }
    var dotImage: UIImage? {
        didSet {
            resetDotViews()
        }
    }
    var currentDotImage: UIImage? {
        didSet {
            resetDotViews()
        }
    }
    var currentDotColor: UIColor = .white
    var dotColor: UIColor = .clear
    var dotSize: CGSize {
        if let image = dotImage {
            return image.size
        }
        return CGSize(width: 8, height: 8)
    }
    var spacingBetweenDots: CGFloat = 8 {
        didSet {
            resetDotViews()
        }
    }
    weak var delegate: HXPageControlDelegate?
    var numberOfPages: Int = 0 {
        didSet {
            resetDotViews()
        }
    }
    var currentPage: Int = 0 {
        willSet {
            changeActivity(activity: false, at: currentPage)
        }
        didSet {
            changeActivity(activity: true, at: currentPage)
        }
    }
    var hidesForSinglePage: Bool = false
    var shouldResizeFromCenter: Bool = true
    
    func sizeForNumber(of pages: Int) -> CGSize {
        return CGSize(width: (dotSize.width + spacingBetweenDots) * CGFloat(pages) - spacingBetweenDots, height: dotSize.height)
    }
    
    private var dots: [UIView] = [UIView]()
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        if touch?.view != self {
            
        }
    }
    
    override func sizeToFit() {
        updateFrame(true)
    }
    
    private func updateFrame(_ overrideExistingFrame: Bool) {
        let size = sizeForNumber(of: numberOfPages)
        if overrideExistingFrame || frame.width < size.width || frame.height < size.height && !overrideExistingFrame {
            frame = CGRect(x: frame.minX, y: frame.minY, width: size.width, height: size.height)
            if shouldResizeFromCenter {
                center = center
            }
        }
        resetDotViews()
    }
    
    private func resetDotViews() {
        dots.forEach { $0.removeFromSuperview() }
        dots.removeAll()
        updateDots()
    }
    
    private func updateDots() {
        guard numberOfPages > 0 else {
            return
        }
        (0 ..< numberOfPages).forEach { (i) in
            var dot: UIView?
            if i < dots.count {
                dot = dots[i]
            } else {
                dot = generateDotView()
            }
            updateDotFrame(dot: dot!, at: i)
            changeActivity(activity: true, at: currentPage)
            hideForSinglePage()
        }
    }
    
    private func generateDotView() -> UIView {
        var dotView: UIView?
        if let dotImage = dotImage {
            dotView = UIImageView(image: dotImage)
            dotView?.frame = CGRect(x: 0, y: 0, width: dotSize.width, height: dotSize.height)
        } else {
            dotView = HXAnimateDotView(frame: CGRect(x: 0, y: 0, width: dotSize.width, height: dotSize.height))
            if let d = dotView as? HXAnimateDotView {
                d.currentDotColor = currentDotColor
                d.dotColor = dotColor
            }
        }
        if let dotView = dotView {
            addSubview(dotView)
            dots.append(dotView)
        }
        dotView?.isUserInteractionEnabled = true
        return dotView!
    }
    
    private func updateDotFrame(dot: UIView, at index: Int) {
        let x = (dotSize.width + spacingBetweenDots) * CGFloat(index) + (frame.width - sizeForNumber(of: numberOfPages).width) / 2
        dot.frame = CGRect(x: x, y: 0, width: dotSize.width, height: dotSize.height)
    }
    
    func changeActivity(activity: Bool, at index: Int) {
        if let d = dots[index] as? HXAnimateDotView {
            d.changeActivityState(active: activity)
        } else if let dotView = dots[index] as? UIImageView {
            dotView.image = activity ? currentDotImage : dotImage
        }
    }
    
    func hideForSinglePage() {
        isHidden = (dots.count == 1 && hidesForSinglePage)
    }
}

