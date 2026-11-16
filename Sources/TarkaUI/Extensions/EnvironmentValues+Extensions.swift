//
//  EnvironmentValues+Extensions.swift
//  EAM360
//
//  Created by Gopinath on 20/11/25.
//  Copyright © 2025 Sedin Technologies. All rights reserved.
//

import SwiftUI

public extension EnvironmentValues {
  @Entry var tuiSafeAreaInsets: EdgeInsets = .init()
  /// `true` when `TUIMobileButtonBlock` is pinned to the screen bottom, above the home indicator.
  @Entry var tuiButtonBlockAtScreenBottom: Bool = false
}
