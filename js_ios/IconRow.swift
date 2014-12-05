import Foundation

// TODO: Figure out how to have class-level constants
let PADDING = CGFloat(10)

public typealias TextureProvider = (String, CGPoint) -> Texture

public class IconRow : View {

  private var elements = Array<IconElement> ()
  
  private(set) var panel : IconPanel
  
  // Temporarily made public
  public var gapPosition = -1

  public init(_ panel:IconPanel) {
    self.panel = panel
  }
  
  public func addElement(element: IconElement) {
  	elements.append(element)
  }
  
  public func removeElement(index:Int) -> IconElement {
    return elements.removeAtIndex(index)
  }
  
  // Determine which element, if any, is at a location;
  // returns index of element, or -1
  public func elementAt(location:CGPoint) -> Int {
    for var i = 0; i < elements.count; i++ {
      let e = elements[i]
      let r = CGRect(origin:e.position,size:e.size)
      if r.contains(location) {
        return i
      }
    }
    return -1
  }
  
  public func getElement(index : Int) -> IconElement {
    return elements[index]
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
    var elemPos = Array<CGPoint>()
    
    if elements.count > 0 {
	    var totalWidth = totalElementWidth()
      totalWidth += PADDING * CGFloat(elements.count-1)
      if (gapPosition >= 0) {
        totalWidth += gapWidth() + PADDING
      }
    
      var x = (bounds.width - totalWidth) / 2
      for var i = 0; i < elements.count; i++ {
				let e = elements[i]
        if i == gapPosition {
          x += gapWidth() + PADDING
        }
        let pos = CGPoint(x,(bounds.height - e.size.y)/2)
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
  
  // Default plot handler; plots the elements in their current positions
  //
  public override func defaultPlotHandler(view : View) {
    super.defaultPlotHandler(view)
    for e in elements {
      e.render(panel.textureProvider)
    }
  }

}
