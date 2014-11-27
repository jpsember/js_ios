import Foundation
import UIKit

extension CGPoint :  Printable {

  public var ix : Int {return Int(x)}
  public var iy : Int {return Int(y)}
  
  public static let zero = CGPointZero
  
  public init(_ x:Double, _ y:Double) {
    self.x = CGFloat(x)
    self.y = CGFloat(y)
  }

  public init(_ x:CGFloat = 0, _ y:CGFloat = 0) {
    self.x = x
    self.y = y
  }
  
  public init(_ point: CGPoint) {
    self.init(point.x,point.y)
  }
  
  public init(_ x:Int, _ y:Int) {
    self.x = CGFloat(x)
    self.y = CGFloat(y)
  }
  
  public init(_ size: CGSize) {
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
  
  public mutating func setTo(source:CGPoint) {
    setTo(source.x,source.y)
  }
  
  public mutating func add(other:CGPoint) {
  	x += other.x
    y += other.y
  }
 
  public func magnitude() -> CGFloat {
    return sqrt(x*x + y*y)
  }
  
  public var description : String {
    return "(x:\(d(x))y:\(d(y)))"
  }

  public mutating func apply(t: CGAffineTransform) {
  	let tx = x * t.a + y * t.b + t.tx
    let ty = x * t.c + y * t.d + t.ty
    setTo(tx,ty)
  }
  
  public static func sum(first:CGPoint,_ second:CGPoint) -> CGPoint {
    return CGPoint(first.x+second.x,first.y+second.y)
  }
  
}
