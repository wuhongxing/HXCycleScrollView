//
//  HXCollectionViewCell.swift
//  HXCycleScrollView
//
//  Created by wuhongxing on 2020/5/1.
//  Copyright © 2020 zto. All rights reserved.
//

import UIKit
import Kingfisher

public struct HXCycleModel {
    var title: String = ""
    var imageName: String = ""
}


public class HXCollectionViewCell: UICollectionViewCell {
    
    public var isOnlyDisplayText: Bool = false
    public var titleLabelTextColor: UIColor = .white {
        didSet {
            titleLabel.textColor = titleLabelTextColor
        }
    }
    public var titleLabelTextFont: UIFont = .systemFont(ofSize: 14) {
        didSet {
            titleLabel.font = titleLabelTextFont
        }
    }
    public var titleLabelBackgroundColor: UIColor = .lightGray {
        didSet {
            titleLabel.backgroundColor = titleLabelBackgroundColor
        }
    }
    public var titleLabelHeight: CGFloat = 30
    public var titleLabelTextAlignment: NSTextAlignment = .left {
        didSet {
            titleLabel.textAlignment = titleLabelTextAlignment
        }
    }
    public var hasConfigured: Bool = false
    public var title: String = "" {
        didSet {
            titleLabel.text = title
            if titleLabel.isHidden {
                titleLabel.isHidden = false
            }
        }
    }
    public var imageName: String = "" {
        didSet {
            guard imageName != "" else { return }
            if imageName.hasPrefix("http") {
                imageView.kf.setImage(with: URL(string: imageName))
            } else { // TODO: 这里是并没有解码，并且使用 UIImage(named: )这种方式加载会缓存，之后是可以用异步加载优化的
                var image = UIImage(named: imageName)
                if image == nil  {
                    image = UIImage(contentsOfFile: imageName)
                }
                imageView.image = image
            }
        }
    }
    public var imageViewContentMode: UIView.ContentMode = .scaleAspectFit
    
    private lazy var imageView: UIImageView = {
        return UIImageView()
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.isHidden = true
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        titleLabelBackgroundColor = .lightGray
        contentView.addSubview(imageView)
        contentView.addSubview(titleLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        if isOnlyDisplayText {
            titleLabel.frame = bounds
        } else {
            imageView.frame = bounds
            titleLabel.frame = CGRect(x: 0, y: bounds.height - titleLabelHeight, width: bounds.width, height: titleLabelHeight)
        }
    }
}
