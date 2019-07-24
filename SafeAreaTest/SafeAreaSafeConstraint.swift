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

    private weak var substituteConstraint: NSLayoutConstraint?

    override func awakeFromNib() {
        super.awakeFromNib()
        if #available(iOS 11.0, *) { return }
        guard let connectedViewController = resolveViewController(from: self.firstItem) ?? resolveViewController(from: self.secondItem) else {
            assertionFailure("This subclass can only be used for constraints connected to a view controller's Safe Area on one of its ends.")
            return
        }
        let simulatedSafeArea = getOrCreateSimulatedSafeArea(in: connectedViewController)
        guard let firstItem = self.firstItem else {
            assertionFailure("Missing first item of constraint. This should not be possible at all.")
            return
        }
        guard let secondItem = self.secondItem else {
            assertionFailure("Missing second item of constraint. Constant-value constraints cannot be created on Safe Area, so this should not happen.")
            return
        }
        let substituteFirstItem = firstItem === connectedViewController.view ? simulatedSafeArea : firstItem
        let substituteSecondItem = secondItem === connectedViewController.view ? simulatedSafeArea : secondItem
        isActive = false
        self.substituteConstraint = makeSubstituteConstraint(first: substituteFirstItem, second: substituteSecondItem)
    }
}

// MARK: - Private helpers
extension SafeAreaSafeConstraint {
    
    private func resolveViewController(from object: AnyObject?) -> UIViewController? {
        guard
            let vc = (object as? UIResponder)?.nextViewController,
            vc.view === object else { return nil }
        return vc
    }
    
    private func getOrCreateSimulatedSafeArea(in connectedViewController: UIViewController) -> UIView {
        return connectedViewController.view.subviews.first(where: { $0 is SimulatedSafeArea }) ?? {
            let area = SimulatedSafeArea()
            area.translatesAutoresizingMaskIntoConstraints = false
            connectedViewController.view.insertSubview(area, at: 0)
            NSLayoutConstraint.activate([
                area.topAnchor.constraint(equalTo: connectedViewController.topLayoutGuide.bottomAnchor),
                area.bottomAnchor.constraint(equalTo: connectedViewController.bottomLayoutGuide.topAnchor),
                area.leadingAnchor.constraint(equalTo: connectedViewController.view.leadingAnchor),
                area.trailingAnchor.constraint(equalTo: connectedViewController.view.trailingAnchor)
                ])
            return area
            }()
    }
    
    private func makeSubstituteConstraint(first: AnyObject, second: AnyObject) -> NSLayoutConstraint {
        let substituteConstraint = SubstituteConstraint(item: first, attribute: firstAttribute, relatedBy: relation, toItem: second, attribute: secondAttribute, multiplier: multiplier, constant: constant)
        substituteConstraint.originalConstraint = self
        substituteConstraint.priority = priority
        substituteConstraint.shouldBeArchived = shouldBeArchived
        substituteConstraint.isActive = true
        substituteConstraint.identifier = "\(identifier ?? "Unnamed constraint") (iOS <11 substitute)"
        return substituteConstraint
    }
}

// MARK: - Delegated superclass properties
extension SafeAreaSafeConstraint {
    
    override var priority: UILayoutPriority {
        get { if substituteConstraint != nil { return substituteConstraint!.priority } else { return super.priority } }
        set { if substituteConstraint != nil { substituteConstraint!.priority = newValue } else { super.priority = newValue } }
    }
    
    override var shouldBeArchived: Bool {
        get { if substituteConstraint != nil { return substituteConstraint!.shouldBeArchived } else { return super.shouldBeArchived } }
        set { if substituteConstraint != nil { substituteConstraint!.shouldBeArchived = newValue } else { super.shouldBeArchived = newValue } }
    }

    override var firstItem: AnyObject? {
        if substituteConstraint != nil { return substituteConstraint!.firstItem } else { return super.firstItem }
    }
    
    override var firstAttribute: NSLayoutConstraint.Attribute {
        if substituteConstraint != nil { return substituteConstraint!.firstAttribute } else { return super.firstAttribute }
    }
    
    override var secondItem: AnyObject? {
        if substituteConstraint != nil { return substituteConstraint!.secondItem } else { return super.secondItem }
    }
    
    override var secondAttribute: NSLayoutConstraint.Attribute {
        if substituteConstraint != nil { return substituteConstraint!.secondAttribute } else { return super.secondAttribute }
    }
    
    override var firstAnchor: NSLayoutAnchor<AnyObject> {
        if substituteConstraint != nil { return substituteConstraint!.firstAnchor } else { return super.firstAnchor }
    }
    
    override var secondAnchor: NSLayoutAnchor<AnyObject>? {
        if substituteConstraint != nil { return substituteConstraint!.secondAnchor } else { return super.secondAnchor }
    }
    
    override var relation: NSLayoutConstraint.Relation {
        if substituteConstraint != nil { return substituteConstraint!.relation } else { return super.relation }
    }
    
    override var multiplier: CGFloat {
        if substituteConstraint != nil { return substituteConstraint!.multiplier } else { return super.multiplier }
    }
        
    override var constant: CGFloat {
        get { if substituteConstraint != nil { return substituteConstraint!.constant } else { return super.constant } }
        set { if substituteConstraint != nil { substituteConstraint!.constant = newValue } else { super.constant = newValue } }
    }
    
    override var isActive: Bool {
        get { if substituteConstraint != nil { return substituteConstraint!.isActive } else { return super.isActive } }
        set { if substituteConstraint != nil { substituteConstraint!.isActive = newValue } else { super.isActive = newValue } }
    }
    
    override var identifier: String? {
        get { if substituteConstraint != nil { return substituteConstraint!.identifier } else { return super.identifier } }
        set { if substituteConstraint != nil { substituteConstraint!.identifier = newValue } else { super.identifier = newValue } }
    }
}

// MARK: - Connected view controller helper
private extension UIResponder {
    
    var nextViewController: UIViewController? {
        return (next as? UIViewController) ?? next?.nextViewController
    }
}

// MARK: -
private class SimulatedSafeArea: UIView {
}

// MARK: -
private class SubstituteConstraint: NSLayoutConstraint {
    
    var originalConstraint: NSLayoutConstraint?
}
