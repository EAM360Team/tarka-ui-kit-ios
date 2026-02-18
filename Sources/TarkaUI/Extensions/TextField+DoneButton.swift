//
//  TextField+DoneButton.swift
//  TarkaUI
//
//  Created by Gopinath on 10/02/26.
//

import SwiftUI
import UIKit
@_spi(Advanced) import SwiftUIIntrospect

public extension View {
  
  /// Adds done button on keyboard tool bar if it finds textField and resigns its responder when clicked
  ///
  /// It uses SwiftUIIntrospect package API to iterate among this view's subviews and
  /// if any textfield is found, it adds done button on keyboard toolbar.
  /// When the done button is clicked, it resigns its responder and the callback would be triggered
  ///
  /// - Parameter onClicked: Callback that would trigger when done button is clicked
  /// - Returns: View
  ///
  func addDoneButtonOnKeyboard(
    onClicked: (() -> Void)? = nil
  ) -> some View {
    
    self
    // Adds introspection for textField
      .introspect(
        .textField,
        on: .iOS(.v16...)
      ) { textField in
        
        warnIfUntested()
        
        textField.addDoneButtonOnKeyboard {
          onClicked?()
        }
      }
    // Adds introspection for textView
      .introspect(
        .textEditor,
        on: .iOS(.v16...)
      ) { textView in
        
        warnIfUntested()
        
        textView.addDoneButtonOnKeyboard {
          onClicked?()
        }
      }
  }
  
  
  /// Warns developer if the iOS version is not tested with this feature
  private func warnIfUntested() {
    IOSCompatibilityGuard.warnIfUntested(
      feature: .keyboardDoneBar,
      maxTestedMajor: .v26
    )
  }
}

private protocol KeyboardDoneAttachable: UIResponder {
  var inputAccessoryView: UIView? { get set }
  func resignFirstResponder() -> Bool
}

extension UITextField: KeyboardDoneAttachable {}
extension UITextView: KeyboardDoneAttachable {}

private extension KeyboardDoneAttachable {
  
  private static var doneToolbarTag: Int { 987654 }
  
  /// Adds a toolbar with a Done button to the keyboard
  /// - Parameter onClicked: Optional callback executed when Done is tapped
  func addDoneButtonOnKeyboard(
    onClicked: (() -> Void)? = nil
  ) {
    
    // iOS 26+ specific configuration to avoid decimal keypad popover in iPad
    if #available(iOS 26.0, *) {
      if let textField = self as? UITextField {
        textField.allowsNumberPadPopover = false
      }
      if let textView = self as? UITextView {
        textView.allowsNumberPadPopover = false
      }
    }
    
    // Prevent multiple injections
    if let toolbar = inputAccessoryView as? UIToolbar,
       toolbar.tag == Self.doneToolbarTag {
      return
    }
    
    let toolbar = KeyboardDoneToolbar { [weak self] in
      onClicked?()
      // Hide keyboard
      self?.resignFirstResponder()
    }
    
    toolbar.tag = Self.doneToolbarTag
    inputAccessoryView = toolbar
  }
}

private final class KeyboardDoneToolbar: UIToolbar {
  
  private let doneAction: () -> Void
  
  init(doneAction: @escaping () -> Void) {
    self.doneAction = doneAction
    super.init(frame: .zero)
    
    sizeToFit()
    setupItems()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func setupItems() {
    
    let flexSpace = UIBarButtonItem(
      barButtonSystemItem: .flexibleSpace,
      target: nil,
      action: nil
    )
    
    let doneButton = UIBarButtonItem(
      title: "Done".localized,
      style: .done,
      target: self,
      action: #selector(doneTapped)
    )
        
    items = [flexSpace, doneButton]
  }
  
  @objc
  private func doneTapped() {
    doneAction()
  }
}
