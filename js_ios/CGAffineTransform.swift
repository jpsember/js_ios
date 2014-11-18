import GLKit

extension CGAffineTransform:  Printable {
  
  static func identity() -> CGAffineTransform {
    return CGAffineTransformIdentity
  }
  
  init() {
    self = CGAffineTransformIdentity
  }
  
  init(a: CGFloat, b: CGFloat, c: CGFloat, d: CGFloat, tx: CGFloat, ty: CGFloat) {
    self = CGAffineTransformMake(a, b, c, d, tx, ty)
  }
  
  init(tx: CGFloat, ty: CGFloat) {
    self = CGAffineTransformMakeTranslation(tx, ty)
  }
  
  init(sx: CGFloat, sy: CGFloat) {
    self = CGAffineTransformMakeScale(sx, sy)
  }
  
  init(angle:CGFloat) {
    self = CGAffineTransformMakeRotation(angle)
  }
  
  // Why is 'public' not required on these methods?  Because it's an extension?
  func translated(# tx:CGFloat, ty:CGFloat) -> CGAffineTransform {
    return CGAffineTransformTranslate(self, tx, ty)
  }
  
  func scaled(# sx:CGFloat, sy:CGFloat) -> CGAffineTransform  {
    return CGAffineTransformScale(self, sx, sy)
  }
  
  func rotated(angle:CGFloat) -> CGAffineTransform  {
    return CGAffineTransformRotate(self, angle)
  }
  
  mutating func translate(tx:CGFloat, _ ty:CGFloat) -> CGAffineTransform {
    self = translated(tx:tx, ty:ty)
    return self
  }
  
  mutating func scale(sx:CGFloat, _ sy:CGFloat) -> CGAffineTransform  {
    self = scaled(sx:sx, sy:sy)
    return self
  }
  
  mutating func rotate(angle:CGFloat) -> CGAffineTransform  {
    self = rotated(angle)
    return self
  }
  
  func concated(other:CGAffineTransform) -> CGAffineTransform {
    return CGAffineTransformConcat(self, other)
  }
  
  mutating func concat(other:CGAffineTransform) -> CGAffineTransform {
    self = concated(other)
    return self
  }
  
  var inverted : CGAffineTransform { get { return CGAffineTransformInvert(self) } }
  
  mutating func invert() -> CGAffineTransform {
    self = self.inverted
    return self
  }
  
  var isIdentity : Bool { get { return CGAffineTransformIsIdentity(self) } }
  
  public var description : String {
    
    let f = "8.4f"
    var s = "[ "
    // We need to add 'js_ios.' since d is actually a property name as well
    s += js_ios.d(a,f)
    s += "   "
    s += js_ios.d(b,f)
    s += "   "
    s += js_ios.d(0.0,f)
    s += " ]\n[ "
    s += js_ios.d(c,f)
    s += "   "
    s += js_ios.d(d,f)
    s += "   "
    s += js_ios.d(0.0,f)
    s += " ]\n[ "
    s += js_ios.d(tx,f)
    s += "   "
    s += js_ios.d(ty,f)
    s += "   "
    s += js_ios.d(1.0,f)
    s += " ]\n"
   	return s
  }
 
}


// MARK: Equatable

extension CGAffineTransform : Equatable {
}

public func == (lhs:CGAffineTransform, rhs:CGAffineTransform) -> Bool {
  return CGAffineTransformEqualToTransform(lhs, rhs)
}

// MARK: Concatination via the + and += operators

public func + (lhs:CGAffineTransform, rhs:CGAffineTransform) -> CGAffineTransform {
  return lhs.concated(rhs)
}

public func += (inout lhs:CGAffineTransform, rhs:CGAffineTransform) {
  lhs.concat(rhs)
}

// MARK: Applying transforms to CG types

public func * (lhs:CGPoint, rhs:CGAffineTransform) -> CGPoint {
  return CGPointApplyAffineTransform(lhs, rhs)
}

public func *= (inout lhs:CGPoint, rhs:CGAffineTransform) {
  lhs = CGPointApplyAffineTransform(lhs, rhs)
}

public func * (lhs:CGSize, rhs:CGAffineTransform) -> CGSize {
  return CGSizeApplyAffineTransform(lhs, rhs)
}

public func *= (inout lhs:CGSize, rhs:CGAffineTransform) {
  lhs = CGSizeApplyAffineTransform(lhs, rhs)
}

public func * (lhs:CGRect, rhs:CGAffineTransform) -> CGRect {
  return CGRectApplyAffineTransform(lhs, rhs)
}

public func *= (inout lhs:CGRect, rhs:CGAffineTransform) {
  lhs = CGRectApplyAffineTransform(lhs, rhs)
}

// MARK: Converting transforms to/from arrays

public extension CGAffineTransform {
  init(v:[CGFloat]) {
    assert(v.count == 6)
    self = CGAffineTransformMake(v[0], v[1], v[2], v[3], v[4], v[5])
  }
  
  var values:[CGFloat] {
    get {
      return [a,b,c,d,tx,ty]
    }
    set(v) {
      assert(v.count == 6)
      (a, b, c, d, tx, ty) = (v[0], v[1], v[2], v[3], v[4], v[6])
    }
  }
}

