//
//  QMChatCell.swift
//  Swift-QMChatViewController
//
//  Created by Vladimir Nybozhinsky on 11/13/18.
//  Copyright © 2018 QuickBlox. All rights reserved.
//

import UIKit
import TTTAttributedLabel


struct ChatCellLayoutModel {
  
  var avatarSize: CGSize
  var containerSize: CGSize
  var containerInsets: UIEdgeInsets
  var topLabelHeight: CGFloat
  var bottomLabelHeight: CGFloat
  var staticContainerSize: CGSize
  var spaceBetweenTopLabelAndTextView: CGFloat
  var spaceBetweenTextViewAndBottomLabel: CGFloat
  var maxWidthMarginSpace: CGFloat
  var maxWidth: CGFloat
  
  init(avatarSize: CGSize = .zero,
       containerInsets: UIEdgeInsets = .init(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0),
       topLabelHeight: CGFloat = 0.0,
       bottomLabelHeight: CGFloat = 0.0,
       spaceBetweenTextViewAndBottomLabel: CGFloat = 0.0,
       maxWidth: CGFloat = 0.0,
       staticContainerSize: CGSize = .zero,
       containerSize: CGSize = .zero,
       maxWidthMarginSpace: CGFloat = 0.0,
       spaceBetweenTopLabelAndTextView: CGFloat = 0.0) {
    self.avatarSize = avatarSize
    self.containerInsets = containerInsets
    self.topLabelHeight = topLabelHeight
    self.bottomLabelHeight = bottomLabelHeight
    self.spaceBetweenTextViewAndBottomLabel = spaceBetweenTextViewAndBottomLabel
    self.maxWidth = maxWidth
    self.staticContainerSize = staticContainerSize
    self.containerSize = containerSize
    self.maxWidthMarginSpace = maxWidthMarginSpace
    self.spaceBetweenTopLabelAndTextView = spaceBetweenTopLabelAndTextView
  }
}

/**
 *  The `ChatCellDelegate` protocol defines methods that allow you to manage
 *  additional interactions within the collection view cell.
 */

@objc protocol ChatCellDelegate: NSObjectProtocol {
  /**
   *  Protocol methods down below are required to be implemented
   */
  /**
   *  Tells the delegate that the avatarImageView of the cell has been tapped.
   *
   *  @param cell The cell that received the tap touch event.
   */
  func chatCellDidTapAvatar(_ cell: ChatCell)
  
  /**
   *  Tells the delegate that the message container of the cell has been tapped.
   *
   *  @param cell The cell that received the tap touch event.
   */
  func chatCellDidTapContainer(_ cell: ChatCell)
  
  /**
   *  Protocol methods down below are optional and can be ignored
   */
  /**
   *  Tells the delegate that the cell has been tapped at the point specified by position.
   *
   *  @param cell The cell that received the tap touch event.
   *  @param position The location of the received touch in the cell's coordinate system.
   */
  @objc optional func chatCell(_ cell: ChatCell, didTapAtPosition position: CGPoint)
  
  /**
   *  Tells the delegate that an actions has been selected from the menu of this cell.
   *  This method is automatically called for any registered actions.
   *
   *  @param cell The cell that displayed the menu.
   *  @param action The action that has been performed.
   *  @param sender The object that initiated the action.
   *
   *  @see `ChatCell`
   */
  @objc optional func chatCell(_ cell: ChatCell, didPerformAction action: Selector, withSender sender: Any)
  
  /**
   *  Tells the delegate that cell receive a tap action on text with a specific checking result.
   *
   *  @param cell               cell that received action
   *  @param textCheckingResult text checking result
   */
  @objc optional func chatCell(_ cell: ChatCell, didTapOn textCheckingResult: NSTextCheckingResult)
}

class ChatCell: UICollectionViewCell, ImageViewDelegate, UIGestureRecognizerDelegate {

  static var chatCellMenuActions: Set<AnyHashable> = []
  
  /**
   *  Returns the message container view of the cell. This view is the superview of
   *  the cell's textView, image view or other
   *
   *  @discussion You may customize the cell by adding custom views to this container view.
   *  To do so, override `collectionView:cellForItemAtIndexPath:`
   *
   *  @warning You should not try to manipulate any properties of this view, for example adjusting
   *  its frame, nor should you remove this view from the cell or remove any of its subviews.
   *  Doing so could result in unexpected behavior.
   */
    @IBOutlet private weak var containerView: ChatContainerView!
    @IBOutlet private weak var messageContainer: UIView!
  /**
   *  Property to set avatar view
   */
    @IBOutlet private weak var avatarView: ImageView!
  /**
   *  Returns chat message attributed label.
   *
   *  @warning You should not try to manipulate any properties of this view, for example adjusting
   *  its frame, nor should you remove this view from the cell or remove any of its subviews.
   *  Doing so could result in unexpected behavior.
   */
    @IBOutlet private weak var textView: TTTAttributedLabel!
  /**
   *  Returns top chat message attributed label.
   *
   *  @warning You should not try to manipulate any properties of this view, for example adjusting
   *  its frame, nor should you remove this view from the cell or remove any of its subviews.
   *  Doing so could result in unexpected behavior.
   */
    @IBOutlet private weak var topLabel: TTTAttributedLabel!
  /**
   *  Returns bottom chat message attributed label.
   *
   *  @warning You should not try to manipulate any properties of this view, for example adjusting
   *  its frame, nor should you remove this view from the cell or remove any of its subviews.
   *  Doing so could result in unexpected behavior.
   */
  @IBOutlet private weak var bottomLabel: TTTAttributedLabel!
  @IBOutlet private weak var containerWidthConstraint: NSLayoutConstraint!
  @IBOutlet private weak var messageContainerTopInsetConstraint: NSLayoutConstraint!
  @IBOutlet private weak var messageContainerLeftInsetConstraint: NSLayoutConstraint!
  @IBOutlet private weak var messageContainerBottomInsetConstraint: NSLayoutConstraint!
  @IBOutlet private weak var messageContainerRightInsetConstraint: NSLayoutConstraint!
  @IBOutlet weak var avatarContainerViewWidthConstraint: NSLayoutConstraint!
  @IBOutlet weak var avatarContainerViewHeightConstraint: NSLayoutConstraint!
  @IBOutlet weak var topLabelHeightConstraint: NSLayoutConstraint!
  @IBOutlet weak var bottomLabelHeightConstraint: NSLayoutConstraint!
  @IBOutlet weak var textViewBottomLabelVerticalSpaceConstraint: NSLayoutConstraint!
  @IBOutlet weak var topLabelTextViewVerticalSpaceConstraint: NSLayoutConstraint!
  
  /**
   *  Returns the avatar container view of the cell. This view is the superview of the cell's avatarImageView.
   *
   *  @discussion You may customize the cell by adding custom views to this container view.
   *  To do so, override `collectionView:cellForItemAtIndexPath:`
   *
   *  @warning You should not try to manipulate any properties of this view, for example adjusting
   *  its frame, nor should you remove this view from the cell or remove any of its subviews.
   *  Doing so could result in unexpected behavior.
   */
  weak var avatarContainerView: UIView?

  /**
   *  Returns the underlying gesture recognizer for tap gestures in the avatarContainerView of the cell.
   *  This gesture handles the tap event for the avatarContainerView and notifies the cell's delegate.
   */
  weak var tapGestureRecognizer: UITapGestureRecognizer?
  
  /**
   *  The object that acts as the delegate for the cell.
   */
  weak var delegate: ChatCellDelegate?

  class func registerMenuAction(_ action: Selector) {
    chatCellMenuActions.insert(NSStringFromSelector(action))
  }
  
  //MARK: - Class methods
  
  /**
   *  Returns the `UINib` object initialized for the cell.
   *
   *  @return The initialized `UINib` object or `nil` if there were errors during
   *  initialization or the nib file could not be located.
   */
  class func nib() -> UINib? {
    return ChatResources.nib(withNibName: NSStringFromClass( self))
  }
  
  /**
   *  Returns the default string used to identify a reusable cell for text message items.
   *
   *  @return The string used to identify a reusable cell.
   */
  class func cellReuseIdentifier() -> String? {
    return NSStringFromClass(self).components(separatedBy: ".").last!
  }
  
  /**
   *  Registers an action to be available in the cell's menu.
   *
   *  @param action The selector to register with the cell.
   *
   *  @discussion Non-standard or non-system actions must be added to the `UIMenuController` manually.
   *  You can do this by creating a new `UIMenuItem` and adding it via the controller's `menuItems` property.
   *
   *  @warning Note that all message cells share the all actions registered here.
   */
  class func registerMenuAction(action: Selector) {
    
  }
  
  /**
   *  Model that allows modifying layout without changing constraints directly.
   *
   *  @return ChatCellLayoutModel struct
   */
  class func layoutModel() -> ChatCellLayoutModel {
    
    let containerInsets = UIEdgeInsets(top: 4.0, left: 0.0, bottom: 4.0, right: 5.0)
    
    let defaultLayoutModel = ChatCellLayoutModel(avatarSize: CGSize(width: 30.0, height: 30.0),
                                                   containerInsets: containerInsets,
                                                   topLabelHeight: 17.0, bottomLabelHeight: 14.0,
                                                   maxWidth: 0.0, containerSize: CGSize.zero,
                                                   maxWidthMarginSpace: 20.0)

    return defaultLayoutModel
  }
  
  /**
   Registers cell for data view
   
   @param dataView data view. UITableView or UICollectionView
   */
  class func registerForReuseInView(dataView: Any) {
    let cellIdentifier = cellReuseIdentifier()
    assert(cellIdentifier != nil, "Invalid parameter not satisfying: cellIdentifier != nil")
    
    let nib = self.nib()
    assert(nib != nil, "Invalid parameter not satisfying: nib != nil")
    
    if (dataView is UITableView) {
      (dataView as? UITableView)?.register(nib, forCellReuseIdentifier: cellIdentifier ?? "")
      
    } else if (dataView is UICollectionView) {
      (dataView as? UICollectionView)?.register(nib, forCellWithReuseIdentifier: cellIdentifier ?? "")
    } else {
      assert(false, "Trying to register cell for unsupported dataView")
    }
  }
  
  override func awakeFromNib() {
    super.awakeFromNib()
    
    avatarView.delegate = self
    contentView.isOpaque = true
    translatesAutoresizingMaskIntoConstraints = false
    
    messageContainerTopInsetConstraint.constant = 0
    messageContainerLeftInsetConstraint.constant = 0
    messageContainerBottomInsetConstraint.constant = 0
    messageContainerRightInsetConstraint.constant = 0
    
    avatarContainerViewWidthConstraint.constant = 0
    avatarContainerViewHeightConstraint.constant = 0
    
    topLabelHeightConstraint.constant = 0
    bottomLabelHeightConstraint.constant = 0
    
    topLabelTextViewVerticalSpaceConstraint.constant = 0
    textViewBottomLabelVerticalSpaceConstraint.constant = 0
    
//    #if Q_DEBUG_COLORS == 0
    backgroundColor = UIColor.clear
    messageContainer.backgroundColor = UIColor.clear
    topLabel.backgroundColor = UIColor.clear
    textView.backgroundColor = UIColor.clear
    bottomLabel.backgroundColor = UIColor.clear
    containerView.backgroundColor = UIColor.clear
    avatarView.backgroundColor = UIColor.clear
//    #endif
    
    layer.drawsAsynchronously = true
    
    avatarView.imageViewType = ImageViewType.circle
    
    let tap = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture(_:)))
    tap.delegate = self
    addGestureRecognizer(tap)
    tapGestureRecognizer = tap
    
  }
  
  @objc func handleTapGesture(_ tap: UITapGestureRecognizer?) {
    
    let touchPt: CGPoint? = tap?.location(in: self)
    let touchView: UIView? = tap?.view?.hitTest(touchPt ?? CGPoint.zero, with: nil)
    
    if (touchView is TTTAttributedLabel) {
      
      let label = touchView as? TTTAttributedLabel
      let translatedPoint = label?.convert(touchPt ?? CGPoint.zero, from: tap?.view)
      
      let labelLink: TTTAttributedLabelLink? = label?.link(at: translatedPoint!)
      
      if (labelLink?.result.numberOfRanges ?? 0) > 0 {
        
        if let _ = delegate?.chatCell!(self, didTapOn: (labelLink?.result)!) {
          delegate?.chatCell!(self, didTapOn: (labelLink?.result)!)
        }
        return
      }
    }
    
    if containerView.frame.contains(touchPt!) {
      if let _ = delegate?.chatCellDidTapContainer(self) {
        delegate?.chatCellDidTapContainer(self)
      }
    } else if let _ = delegate?.chatCell!(self, didTapAtPosition: touchPt!) {
      
      delegate?.chatCell!(self, didTapAtPosition: touchPt!)
    }
  }
  
  override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
    return layoutAttributes
  }
  
  override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
    
    guard let customAttributes = layoutAttributes as? ChatCellLayoutAttributes else {
      return
    }
    
    updateConstraint(avatarContainerViewHeightConstraint, withConstant: customAttributes.avatarSize.height)
    updateConstraint(avatarContainerViewWidthConstraint, withConstant: customAttributes.avatarSize.width)
    updateConstraint(topLabelHeightConstraint, withConstant: customAttributes.topLabelHeight)
    updateConstraint(bottomLabelHeightConstraint, withConstant: customAttributes.bottomLabelHeight)
    updateConstraint(messageContainerTopInsetConstraint, withConstant: customAttributes.containerInsets.top)
    updateConstraint(messageContainerLeftInsetConstraint, withConstant: customAttributes.containerInsets.left)
    updateConstraint(messageContainerBottomInsetConstraint, withConstant: customAttributes.containerInsets.bottom)
    updateConstraint(messageContainerRightInsetConstraint, withConstant: customAttributes.containerInsets.right)
    updateConstraint(topLabelTextViewVerticalSpaceConstraint, withConstant: customAttributes.spaceBetweenTopLabelAndTextView)
    updateConstraint(textViewBottomLabelVerticalSpaceConstraint, withConstant: customAttributes.spaceBetweenTextViewAndBottomLabel)
    updateConstraint(containerWidthConstraint, withConstant: customAttributes.containerSize.width)
    
    layoutIfNeeded()
}

  func updateConstraint(_ constraint: NSLayoutConstraint, withConstant constant: CGFloat) {
    if Int(constraint.constant) == Int(constant) {
      return
    }
    constraint.constant = constant
  }
  
  override var bounds: CGRect {
    didSet {
    if UIDevice.current.systemVersion.compare("8.0", options: .numeric, range: nil, locale: .current) == .orderedAscending {
      layoutIfNeeded()
      contentView.frame = bounds
      }
    }
  }
  
  override var isSelected: Bool {
    didSet {
      containerView.highlighted = isSelected
    }
  }
  
  //MARK: - Gesture recognizers
  func imageViewDidTap(_ imageView: ImageView) {
    if let _ = delegate?.chatCellDidTapAvatar(self) {
      delegate?.chatCellDidTapAvatar(self)
    }
  }
  
  func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
    
    let touchPt: CGPoint = touch.location(in: gestureRecognizer.view)
    
    if (gestureRecognizer is UILongPressGestureRecognizer) {
      
      if (touch.view is TTTAttributedLabel) {
        
        let label = touch.view as? TTTAttributedLabel
        let translatedPoint: CGPoint? = label?.convert(touchPt, from: gestureRecognizer.view)
        
        
        let labelLink: TTTAttributedLabelLink? = label?.link(at: translatedPoint!)
        
        if (labelLink?.result.numberOfRanges ?? 0) > 0 {
          
          return false
        }
      }
      
      return containerView.frame.contains(touchPt)
    }
    
    return true
  }
  
  //MARK: - Menu actions
  
  override class func responds(to aSelector: Selector) -> Bool {
    if chatCellMenuActions.contains(NSStringFromSelector(aSelector)) {
      return true
    }
    return super.responds(to: aSelector)
  }
  
//  func forwardInvocation(_ anInvocation: NSInvocation) {
//    
//    if chatCellMenuActions.contains(NSStringFromSelector(anInvocation.selector)) {
//      
//      var sender: Any?
//      anInvocation.getArgument(&sender, atIndex: 0)
//      
//      if let _ = delegate?.chatCell(self, didPerformAction: anInvocation.selector, withSender: sender) {
//        
//        delegate.chatCell(self, didPerformAction: anInvocation.selector, withSender: sender)
//      } else {
//        
//        super.forwardInvocation(anInvocation)
//      }
//    }
//    
//  }
//    
//    func methodSignature(for aSelector: Selector) -> NSMethodSignature? {
//      
//      if ChatCell.chatCellMenuActions.contains(NSStringFromSelector(aSelector)) {
//        
//        return NSMethodSignature(objCTypes: "v@:@")
//      }
//      
//      return super.methodSignature(for: aSelector)
//    }
  
}
