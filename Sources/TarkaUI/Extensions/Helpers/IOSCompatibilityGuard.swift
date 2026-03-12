//
//  IOSCompatibilityGuard.swift
//  TarkaUI
//
//  Created by MAHESHWARAN on 12/03/26.
//

import Foundation

enum IOSCompatibilityGuard {
  
  enum Feature {
    case keyboardDoneBar
  }
  
  enum Version: Int {
    case v18 = 18
    case v26 = 26
  }
  
  private static var warnedFeatures = Set<Feature>()
  
  /// Emits a runtime warning if the current iOS major version
  /// exceeds the max tested version for a feature.
  static func warnIfUntested(
    feature: Feature,
    maxTestedMajor: Version,
    file: StaticString = #fileID,
    line: UInt = #line
  ) {
    let currentMajor =
    ProcessInfo.processInfo.operatingSystemVersion.majorVersion
    
    guard currentMajor > maxTestedMajor.rawValue else { return }
    
    // Warn once per feature per launch
    guard !warnedFeatures.contains(feature) else { return }
    warnedFeatures.insert(feature)
    
    let message = """
    \n
    ⚠️ iOS COMPATIBILITY WARNING
    Feature        : \(feature)
    Running on     : iOS \(currentMajor)
    Max tested     : iOS \(maxTestedMajor)
    Location       : \(file):\(line)
    Action required: Re-test this feature on the new iOS version.
    \n
    """
    
#if DEBUG
    assertionFailure(message)
#else
    NSLog(message)
#endif
  }
}
