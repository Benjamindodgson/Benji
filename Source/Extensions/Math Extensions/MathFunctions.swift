//
//  MathFunctions.swift
//  Benji
//
//  Created by Benji Dodgson on 6/30/19.
//  Copyright © 2019 Benjamin Dodgson. All rights reserved.
//

import Foundation

func pow(_ lhs: Int, _ rhs: Int) -> Int {
    return Int(powf(Float(lhs), Float(rhs)))
}

func clamp(_ value: CGFloat, _ min: CGFloat, _ max: CGFloat) -> CGFloat {
    return (min...max).clamp(value)
}

func clamp(_ value: CGFloat, min: CGFloat) -> CGFloat {
    return (min...CGFloat.infinity).clamp(value)
}

func clamp(_ value: CGFloat, max: CGFloat) -> CGFloat {
    return (-CGFloat.infinity...max).clamp(value)
}

// MARK: Linear Interpolation

// Linearly interpolate between two values given a normalized value between 0 and 1
// Example: lerp(0.2, min 1, max 3) = 1.4
func lerp(_ normalized: CGFloat, min: CGFloat, max: CGFloat) -> CGFloat {
    return min + normalized * (max - min)
}

// Linearly interpolate between two values. The normalized value is clamped between 0 and 1 so
// the result will never be outside the range of the min and max
func lerpClamped(_ normalized: CGFloat, min: CGFloat, max: CGFloat) -> CGFloat {
    return lerp((0...1).clamp(normalized), min: min, max: max)
}

// MARK: Trig Functions

let halfPi: CGFloat = CGFloat.pi * 0.5
let twoPi: CGFloat = CGFloat.pi * 2

func sin(degrees: Double) -> Double {
    return __sinpi(degrees/180.0)
}

func sin(degrees: Float) -> Float {
    return __sinpif(degrees/180.0)
}

func sin(degrees: CGFloat) -> CGFloat {
    return CGFloat(sin(degrees: degrees.native))
}
