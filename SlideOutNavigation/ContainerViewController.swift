/// Copyright (c) 2019 Razeware LLC
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
///
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import UIKit
import QuartzCore

enum SlideOutState {
  case bothCollapsed
  case leftPanelExpanded
  case rightPanelExpanded
}

class ContainerViewController: UIViewController {
  
  // MARK: - IBOutlets & Properties
  var centerNavigationController: UINavigationController!
  var centerViewController: CenterViewController!
  var leftViewController: SidePanelViewController?
  let centerPanelExpandedOffset: CGFloat = 90
  var currentState: SlideOutState = .bothCollapsed {
    didSet {
      let shouldShowShadow = currentState != .bothCollapsed
      showShadowForCenterViewController(shouldShowShadow)
    }
  }


  
  // MARK: - View LifeCycle
  override func viewDidLoad() {
    super.viewDidLoad()
    initCenterViewController()
  }
  
  // MARK: - IBActions & Methods
  private func initCenterViewController() {
    centerViewController = UIStoryboard.centerViewController()
    centerViewController.delegate = self
    centerNavigationController = UINavigationController(rootViewController: centerViewController)
    view.addSubview(centerNavigationController.view)
    addChild(centerNavigationController)
    centerNavigationController.didMove(toParent: self)
  }
  
  func addLeftPanelViewController() {
    guard leftViewController == nil else { return }
    if let vc = UIStoryboard.leftViewController() {
      vc.animals = Animal.allCats()
      addChildSidePanelController(vc)
      leftViewController = vc
    }
  }
  
  func addChildSidePanelController(_ sidePanelController: SidePanelViewController) {
    view.insertSubview(sidePanelController.view, at: 0)

    addChild(sidePanelController)
    sidePanelController.didMove(toParent: self)
  }

  func animateLeftPanel(shouldExpand: Bool) {
    if shouldExpand {
      currentState = .leftPanelExpanded
      animateCenterPanelXPosition(
        targetPosition: centerNavigationController.view.frame.width
          - centerPanelExpandedOffset)
    } else {
      animateCenterPanelXPosition(targetPosition: 0) { _ in
        self.currentState = .bothCollapsed
        self.leftViewController?.view.removeFromSuperview()
        self.leftViewController = nil
      }
    }
  }
  
  func animateCenterPanelXPosition(
      targetPosition: CGFloat,
      completion: ((Bool) -> Void)? = nil) {
    UIView.animate(
      withDuration: 0.5,
      delay: 0,
      usingSpringWithDamping: 0.8,
      initialSpringVelocity: 0,
      options: .curveEaseInOut,
      animations: {
        self.centerNavigationController.view.frame.origin.x = targetPosition
      },
      completion: completion)
  }

  func showShadowForCenterViewController(_ shouldShowShadow: Bool) {
    if shouldShowShadow {
      centerNavigationController.view.layer.shadowOpacity = 1.0
      centerNavigationController.view.layer.masksToBounds = false
    } else {
      centerNavigationController.view.layer.shadowOpacity = 0.0
    }
  }


}
// MARK: - Extensions
extension ContainerViewController: CenterViewControllerDelegate {
  func toggleLeftPanel() {
    let notAlreadyExpanded = (currentState != .leftPanelExpanded)

    if notAlreadyExpanded {
      addLeftPanelViewController()
    }

    animateLeftPanel(shouldExpand: notAlreadyExpanded)

  }
  
  func toggleRightPanel() {
    
  }
  
  func collapseSidePanels() {
  
  }
}

private extension UIStoryboard {
  static func mainStoryboard() -> UIStoryboard { return UIStoryboard(name: "Main", bundle: Bundle.main) }
  
  static func leftViewController() -> SidePanelViewController? {
    return mainStoryboard().instantiateViewController(withIdentifier: "LeftViewController") as? SidePanelViewController
  }
  
  static func rightViewController() -> SidePanelViewController? {
    return mainStoryboard().instantiateViewController(withIdentifier: "RightViewController") as? SidePanelViewController
  }
  
  static func centerViewController() -> CenterViewController? {
    return mainStoryboard().instantiateViewController(withIdentifier: "CenterViewController") as? CenterViewController
  }
}
