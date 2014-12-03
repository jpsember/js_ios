import Foundation

// TODO: Figure out how to have class-level constants
let PADDING = CGFloat(10)

public class IconRow : NSObject {


  private var elements = Array<IconElement> ()
  
  private var gapPosition = -1
  
  public var bounds = CGRect(0,0,0,0)
  public var container:View!
  
  public func addElement(element: IconElement) {
  	elements.append(element)
  }
  
  private func hasGap() -> Bool {
    return gapPosition >= 0
  }
  
  private func gapWidth() -> CGFloat {
    if !hasGap() {
      return 0
    }
    return PADDING*3
  }
  
  // Layout elements according to their target positions (without any animation)
  //
  public func layout() {
  	let targetPos = calcTargetElementPositions()
    for var i = 0; i < elements.count; i++ {
      let pos = targetPos[i]
      let e = elements[i]
    	e.position = pos
      e.velocity = CGPoint.zero
    }
  }
  
  // Determine element positions given current elements, gap position
  //
  private func calcTargetElementPositions() -> Array<CGPoint> {
  	ASSERT(bounds.width > 0)
    
    var elemPos = Array<CGPoint>()
    
    if elements.count > 0 {
      
	    var totalWidth = totalElementWidth()
      totalWidth += PADDING * CGFloat(elements.count-1)
    
      var x = (bounds.width - totalWidth) / 2
      
      for var i = 0; i < elements.count; i++ {
				let e = elements[i]
        if i == gapPosition {
          x += gapWidth()
        }
        
        let pos = CGPoint(x,bounds.midY - e.size.y/2)
        elemPos.append(pos)
        x += PADDING + e.size.x
      }
    }
    
    return elemPos
  
  }
  
  private func totalElementWidth() -> CGFloat {
  	var w = CGFloat(0)
    for e in elements {
    	w += e.size.x
    }
    return w
  }
  
  public func render() {
    for e in elements {
      e.sprite.render(e.position)
    }
  }
  
}

