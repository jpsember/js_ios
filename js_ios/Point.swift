import Foundation
import UIKit

public struct Point {
	public var x = CGFloat(0.0)
	public var y = CGFloat(0.0)
  
  public static let zero = Point(0,0)
  
  init(_ x:CGFloat = 0, _ y:CGFloat = 0) {
    self.x = x
    self.y = y
  }
  
  init(_ point: Point) {
    self.init(point.x,point.y)
  }
  
  init(_ x:Int, _ y:Int) {
    self.x = CGFloat(x)
    self.y = CGFloat(y)
  }
  
  init(_ point: CGPoint) {
    self.init(point.x,point.y)
  }
  
  init(_ size: CGSize) {
    self.init(size.width,size.height)
  }
  

  public mutating func setTo(x:CGFloat, _ y:CGFloat) {
    self.x = x
    self.y = y
  }
  
  public mutating func clear() {
    self.x = 0
    self.y = 0
  }
  
  public mutating func setTo(source:Point) {
    setTo(source.x,source.y)
  }
  
  public mutating func add(other:Point) {
  	x += other.x
    y += other.y
  }
 
  public func magnitude() -> CGFloat {
    return sqrt(x*x + y*y)
  }
  
  public var description : String {
    return "\(x) \(y) "
  }

  public mutating func apply(t: CGAffineTransform) {
  	let tx = x * t.a + y * t.b + t.tx
    let ty = x * t.c + y * t.d + t.ty
    setTo(tx,ty)
  }
  
}
