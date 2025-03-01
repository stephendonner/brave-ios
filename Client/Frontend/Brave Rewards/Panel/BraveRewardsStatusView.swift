// Copyright 2020 The Brave Authors. All rights reserved.
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import UIKit
import BraveUI
import Shared

class BraveRewardsStatusView: UIView, Themeable {
    enum VisibleStatus {
        case rewardsOff
        case rewardsOnNoCount
        case rewardsOn
    }
    
    private let stackView = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 0
    }
    
    let countView = BraveRewardsSupportedCountView().then {
        $0.isHidden = true
    }
    
    private let onView = StatusLabelView(
        image: #imageLiteral(resourceName: "rewards-panel-on").template,
        text: Strings.Rewards.enabledStatusBody
    ).then {
        $0.isHidden = true
    }
    
    private let offView = StatusLabelView(
        image: #imageLiteral(resourceName: "rewards-panel-off").template,
        text: Strings.Rewards.disabledStatusBody
    )
    
    func setVisibleStatus(status: VisibleStatus, animated: Bool = true) {
        switch status {
        case .rewardsOff:
            setVisibleView(offView, animated: animated)
        case .rewardsOn:
            setVisibleView(countView, animated: animated)
        case .rewardsOnNoCount:
            setVisibleView(onView, animated: animated)
        }
    }
    
    private var visibleView: UIView?
    private func setVisibleView(_ view: UIView, animated: Bool) {
        if view === visibleView { return }
        if animated {
            let oldValue = visibleView
            visibleView = view
            if oldValue != nil {
                visibleView?.alpha = 0.0
            }
            UIView.animate(withDuration: 0.1, animations: {
                oldValue?.alpha = 0.0
            }, completion: { _ in
                oldValue?.isHidden = true
                UIView.animate(withDuration: 0.1, animations: {
                    self.visibleView?.isHidden = false
                })
                UIView.animate(withDuration: 0.1, delay: 0.05) {
                    self.visibleView?.alpha = 1.0
                }
            })
        } else {
            visibleView?.isHidden = true
            visibleView = view
            view.isHidden = false
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        layer.cornerRadius = 8
        layer.cornerCurve = .continuous
        
        addSubview(stackView)
        stackView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(UIEdgeInsets(top: 16, left: 20, bottom: 16, right: 20))
        }
        
        stackView.addStackViewItems(
            .view(countView),
            .view(offView),
            .view(onView)
        )
        
        visibleView = offView
    }
    
    @available(*, unavailable)
    required init(coder: NSCoder) {
        fatalError()
    }
    
    func applyTheme(_ theme: Theme) {
        backgroundColor = theme.isDark ? UIColor(white: 0.2, alpha: 1.0) : UIColor(rgb: 0xE9E9F4)
        countView.applyTheme(theme)
        onView.applyTheme(theme)
        offView.applyTheme(theme)
    }
}

private class StatusLabelView: UIStackView, Themeable {
    let image: UIImage
    let text: String
    
    private let imageView = UIImageView().then {
        $0.setContentHuggingPriority(.required, for: .horizontal)
    }
    
    private let label = UILabel().then {
        $0.textAlignment = .left
        $0.numberOfLines = 0
        $0.font = .systemFont(ofSize: 15)
    }
    
    init(image: UIImage, text: String) {
        self.image = image
        self.text = text
        
        super.init(frame: .zero)
        
        imageView.image = image
        label.text = text
        
        spacing = 12
        alignment = .center
        
        addStackViewItems(
            .view(imageView),
            .view(label)
        )
    }
    
    func applyTheme(_ theme: Theme) {
        let isDark = theme.isDark
        imageView.tintColor = isDark ? .white : Colors.neutral700
        label.appearanceTextColor = isDark ? .white : .black
    }
    
    @available(*, unavailable)
    required init(coder: NSCoder) {
        fatalError()
    }
}
