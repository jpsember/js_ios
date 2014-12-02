import Foundation

public let pi : CGFloat = 3.14159265359

public func pointOnCircle(origin:CGPoint, radius:CGFloat, angle:CGFloat) -> CGPoint {
  let x : CGFloat = origin.x + cos(angle) * radius
  let y : CGFloat = origin.y + sin(angle) * radius
  return CGPoint(x, y)
}

public func degrees(radians:CGFloat) -> CGFloat {
	return radians * (pi / 180)
}

public func clamp<T : Comparable>(value : T, min: T, max : T) -> T {
  var v = value
  if (v < min) {
    v = min
  } else if (v > max) {
    v = max
  }
  return v
}
