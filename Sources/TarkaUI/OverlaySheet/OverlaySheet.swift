//
//  OverlaySheet.swift
//
//
//  Created by MAHESHWARAN on 22/09/23.
//

import SwiftUI

/// A View Modifier that shows overlay view as popup on iPad(when not in split screen) and
/// as bottom sheet on iPhones
public struct OverlaySheet<V: View>: ViewModifier {
  
  @Binding var isPresented: Bool
  private var contentView: () -> V
  private let isPad = UIDevice.current.userInterfaceIdiom == .pad
  
  public init(isPresented: Binding<Bool>, contentView: @autoclosure @escaping () -> V) {
    _isPresented = isPresented
    self.contentView = contentView
  }
  
  public func body(content: Content) -> some View {
    content
      .sheet(isPresented: $isPresented) {
        DestinationView(
          isPresented: $isPresented,
          contentView: contentView,
          needColor: !isPad
        )
      }
  }
  
  struct DestinationView: View {
    
    @Binding var isPresented: Bool
    var contentView: () -> V
    var needColor: Bool = false
    
    var body: some View {
      contentView()
        .backgroundView(withColor: needColor ? .surface : .clear) {
          isPresented = false
        }
    }
  }
}


