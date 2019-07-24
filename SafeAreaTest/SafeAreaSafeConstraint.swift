//
//  CustomConstraint.swift
//  SO-33819852
//
//  Created by Peter Lizak on 23/07/2019.
//  Copyright © 2019 SwiftArchitect. All rights reserved.
//

import Foundation
import UIKit

// MARK: Private property initializers
class SafeAreaSafeConstraint: NSLayoutConstraint {

    private var substitutedConstraint: NSLayoutConstraint?

    private lazy var substitutedFirstItem: AnyObject = {
        guard let firstItem = self.firstItem else {
            assertionFailure("Missing first item of constraint. This should not be possible at all.")
            return UIView()
        }
        return firstItem === self.connectedViewController.view ? self.simulatedSafeArea : firstItem
    }()
    
    private lazy var substitutedSecondItem: AnyObject = {
        guard let secondItem = self.secondItem else {
            assertionFailure("Missing second item of constraint. Constant-value constraints cannot be created on Safe Area, so this should not happen.")
            return UIView()
        }
        return secondItem === self.connectedViewController.view ? self.simulatedSafeArea : secondItem
    }()

    private lazy var simulatedSafeArea: UIView = {
        if let area = self.connectedViewController.view.subviews.first(where: { $0 is SimulatedSafeArea }) { return area }
        let area = SimulatedSafeArea()
        area.translatesAutoresizingMaskIntoConstraints = false
        self.connectedViewController.view.insertSubview(area, at: 0)
        NSLayoutConstraint.activate([
            area.topAnchor.constraint(equalTo: self.connectedViewController.topLayoutGuide.bottomAnchor),
            area.bottomAnchor.constraint(equalTo: self.connectedViewController.bottomLayoutGuide.topAnchor),
            area.leadingAnchor.constraint(equalTo: self.connectedViewController.view.leadingAnchor),
            area.trailingAnchor.constraint(equalTo: self.connectedViewController.view.trailingAnchor)
            ])
        return area
    }()
    
    private lazy var connectedViewController: UIViewController = {
        guard let vc = resolveViewController(from: self.firstItem) ?? resolveViewController(from: self.secondItem) else {
            assertionFailure("This subclass can only be used for constraints connected to a view controller's Safe Area on one of its ends.")
            return UIViewController()
        }
        return vc
    }()
}

// MARK: - Awake from NIB
extension SafeAreaSafeConstraint {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        if #available(iOS 11.0, *) { return }
        let substitutedConstraint = NSLayoutConstraint(item: self.substitutedFirstItem, attribute: self.firstAttribute, relatedBy: self.relation, toItem: self.substitutedSecondItem, attribute: self.secondAttribute, multiplier: self.multiplier, constant: self.constant)
        substitutedConstraint.priority = priority
        substitutedConstraint.shouldBeArchived = shouldBeArchived
        substitutedConstraint.isActive = isActive
        substitutedConstraint.identifier = "\(identifier ?? "Unnamed constraint") (iOS <11 substitute)"
        isActive = false
        self.substitutedConstraint = substitutedConstraint
    }
}

// MARK: - Delegated superclass properties
extension SafeAreaSafeConstraint {
    
    override var priority: UILayoutPriority {
        get { if substitutedConstraint != nil { return substitutedConstraint!.priority } else { return super.priority } }
        set { if substitutedConstraint != nil { substitutedConstraint!.priority = newValue } else { super.priority = newValue } }
    }
    
    override var shouldBeArchived: Bool {
        get { if substitutedConstraint != nil { return substitutedConstraint!.shouldBeArchived } else { return super.shouldBeArchived } }
        set { if substitutedConstraint != nil { substitutedConstraint!.shouldBeArchived = newValue } else { super.shouldBeArchived = newValue } }
    }

    override var firstItem: AnyObject? {
        if substitutedConstraint != nil { return substitutedConstraint!.firstItem } else { return super.firstItem }
    }
    
    override var firstAttribute: NSLayoutConstraint.Attribute {
        if substitutedConstraint != nil { return substitutedConstraint!.firstAttribute } else { return super.firstAttribute }
    }
    
    override var secondItem: AnyObject? {
        if substitutedConstraint != nil { return substitutedConstraint!.secondItem } else { return super.secondItem }
    }
    
    override var secondAttribute: NSLayoutConstraint.Attribute {
        if substitutedConstraint != nil { return substitutedConstraint!.secondAttribute } else { return super.secondAttribute }
    }
    
    override var firstAnchor: NSLayoutAnchor<AnyObject> {
        if substitutedConstraint != nil { return substitutedConstraint!.firstAnchor } else { return super.firstAnchor }
    }
    
    override var secondAnchor: NSLayoutAnchor<AnyObject>? {
        if substitutedConstraint != nil { return substitutedConstraint!.secondAnchor } else { return super.secondAnchor }
    }
    
    override var relation: NSLayoutConstraint.Relation {
        if substitutedConstraint != nil { return substitutedConstraint!.relation } else { return super.relation }
    }
    
    override var multiplier: CGFloat {
        if substitutedConstraint != nil { return substitutedConstraint!.multiplier } else { return super.multiplier }
    }
        
    override var constant: CGFloat {
        get { if substitutedConstraint != nil { return substitutedConstraint!.constant } else { return super.constant } }
        set { if substitutedConstraint != nil { substitutedConstraint!.constant = newValue } else { super.constant = newValue } }
    }
    
    override var isActive: Bool {
        get { if substitutedConstraint != nil { return substitutedConstraint!.isActive } else { return super.isActive } }
        set { if substitutedConstraint != nil { substitutedConstraint!.isActive = newValue } else { super.isActive = newValue } }
    }
    
    override var identifier: String? {
        get { if substitutedConstraint != nil { return substitutedConstraint!.identifier } else { return super.identifier } }
        set { if substitutedConstraint != nil { substitutedConstraint!.identifier = newValue } else { super.identifier = newValue } }
    }
}

// MARK: - Connected view controller helper
private extension SafeAreaSafeConstraint {

    func resolveViewController(from object: AnyObject?) -> UIViewController? {
        guard
            let vc = (object as? UIResponder)?.nextViewController,
            vc.view === object else { return nil }
        return vc
    }
}

private extension UIResponder {
    
    var nextViewController: UIViewController? {
        return (next as? UIViewController) ?? next?.nextViewController
    }
}

// MARK: - Safe area helper
private class SimulatedSafeArea: UIView {
}
