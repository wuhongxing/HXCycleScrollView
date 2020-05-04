//
//  ViewController.swift
//  HXCycleScrollView
//
//  Created by wuhongxing on 2020/5/1.
//  Copyright © 2020 zto. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        navigationController?.pushViewController(NextViewController(), animated: true)
    }
}

class NextViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        let imageArray = ["https://ss2.baidu.com/-vo3dSag_xI4khGko9WTAnF6hhy/super/whfpf%3D425%2C260%2C50/sign=a4b3d7085dee3d6d2293d48b252b5910/0e2442a7d933c89524cd5cd4d51373f0830200ea.jpg",
        "https://ss0.baidu.com/-Po3dSag_xI4khGko9WTAnF6hhy/super/whfpf%3D425%2C260%2C50/sign=a41eb338dd33c895a62bcb3bb72e47c2/5fdf8db1cb134954a2192ccb524e9258d1094a1e.jpg",
        "http://c.hiphotos.baidu.com/image/w%3D400/sign=c2318ff84334970a4773112fa5c8d1c0/b7fd5266d0160924c1fae5ccd60735fae7cd340d.jpg"
        ]
        let localImageArray = ["h1.jpg", "h2.jpg", "h3.jpg", "h4.jpg"]
        let titleArray = ["新建交流QQ群：185534916 ",
        "disableScrollGesture可以设置禁止拖动",
        "感谢您的支持，如果下载的",
        "如果代码在使用过程中出现问题",
        "您可以发邮件到gsdios@126.com"]
        
        // DEMO1
        let view1 = HXCycleScrollView(frame: CGRect(x: 0, y: 64, width: view.bounds.width, height: 180))
        view1.delegate = self
        view1.infiniteLoop = false
        view1.pageControlStyle = .default
        view1.imagePathArray = localImageArray
        view.addSubview(view1)
        
        // DEMO2
        let view2 = HXCycleScrollView(frame: CGRect(x: 0, y: 280, width: view.bounds.width, height: 180))
        view2.placeholderImage = UIImage(named: "placeholder")
        view2.titleArray = titleArray
        view2.isOnlyDisplayText = true
        view2.currentDotColor = .blue
        view.addSubview(view2)

        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
            view2.imagePathArray = imageArray
        }
        
//        let view2 = HXCycleScrollView(frame: CGRect(x: 0, y: 280, width: view.bounds.width, height: 180))
//        view2.isOnlyDisplayText = true
//        view2.scrollDirection = .vertical
//        view2.titleArray = titleArray
//        view2.disableScrollGesture()
//        view2.delegate = self
//        view.addSubview(view2)
        
        // DEMO3
        let view3 = HXCycleScrollView(frame: CGRect(x: 0, y: 450, width: view.bounds.width, height: 180))
//        view3.delegate = self
        view3.placeholderImage = UIImage(named: "placeholder")
        view3.dotImageSelected = UIImage(named: "pageControlCurrentDot")
        view3.dotImageNormal = UIImage(named: "pageControlDot")
        view3.pageControlAlignment = .right(offset: -10)
        view3.imagePathArray = imageArray
        view3.scrollDirection = .vertical
        view.addSubview(view3)
        
    }
}


extension NextViewController: HXCycleScrollViewDelegate {
    func cycleScrollView(_ scrollView: HXCycleScrollView, didSelectItemAt index: Int) {
        print(#function, index)
    }
    
    func cycleScrollView(_ scrollView: HXCycleScrollView, didScrollTo index: Int) {
        print(#function, index)
    }
}
