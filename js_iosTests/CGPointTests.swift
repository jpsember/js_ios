import XCTest

import js_ios

class Unit_Test_ExampleTests: JSTestCase {
  
  func testConstructors() {
    var p : CGPoint
    var q : CGPoint
    
    p = CGPoint.zero
    XCTAssertEqual(p.x,CGFloat(0))
    XCTAssertEqual(p.y,CGFloat(0))
    
    q = CGPoint(Int(5),Int(7))
    XCTAssertEqual(q.x,CGFloat(5))
    
    p = CGPoint(CGFloat(3),CGFloat(5.2))
    XCTAssertEqual(p.y,CGFloat(5.2))
    
    q = CGPoint(Double(12),Double(5.2))
    XCTAssertEqualWithAccuracy(Double(q.y),Double(5.2),1e-5)
    
    q = CGPoint(p)
    XCTAssertEqual(p,q)
  }
  
  func testMutating() {
    var p = CGPoint.zero
    XCTAssertTrue(p.x == 0)
    p.x = 13
    XCTAssertTrue(p.x == 13)
    
    let p2 = CGPoint(12.5, 5.3)
    p.setTo(p2)
    XCTAssert(p.x == 12.5)
    XCTAssertEqual(p.ix, 12)
  }
  
  func testIntegerAccessors() {
    var p = CGPoint(12.5, 5.3)
    XCTAssertEqual(p.ix, 12)
    XCTAssertEqual(p.iy, 5)
    
    p = CGPoint(-12.5, -5.3)
    XCTAssertEqual(p.ix, -12)
    XCTAssertEqual(p.iy, -5)
  }
  
  func testDump() {
    let p = 453.14159273285723
    
    IORecorder.start()
    let a = [CGPoint(p,p),CGPoint(-p,-p)]
    for q in a {
      puts("Point: \(q)")
    }
    IORecorder.stop()
  }

}
