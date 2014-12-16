public class IconPanel : View, LogicProtocol, TouchListener {
  
  // Public properties
  
  public var textureProvider : TextureProvider!
  public var rowHeight : CGFloat = 0
  
  // Public methods
  
  public override init() {
    super.init()
    self.touchHandler = ourTouchHandler
    
    // Add ourselves as a listener to the singleton MoveIconOperation 
    unimp("remove listener if panel is removed")
    MoveIconOperation.sharedInstance().addListener(self)
    
    // Replace the existing plot handler with our own version
    originalPlotHandler = replacePlotHandlerWith(){ (view : View) in
      // Call instance method of supplied view, which we can assume is an IconPanel instance
      let iconPanel = view as IconPanel
      iconPanel.ourPlotHandlerAux()
    }
  }
  
  private func ourPlotHandlerAux() {
  	originalPlotHandler(self)
    for row in rows {
      row.plotElements()
    }
  }
  
  public func addRow() -> IconRow {
    ASSERT(rowHeight > 0,"must define rowheight")
    
    let rowBounds = CGRect(0,CGFloat(rowCount)*rowHeight,self.bounds.width,rowHeight)
    
    var iconRow = IconRow(self,bounds:rowBounds)
    rows.append(iconRow)
    return iconRow
  }

  // Update the IconPanel model; move icons along their paths, request redraw if necessary
  //
  public func updateLogic() {
    var refreshView = false
    for row in rows {
      if row.updateElements() {
      	refreshView = true
      }
    }
    if refreshView {
      invalidate()
    }
  }
  
  // Private properties and methods
  
  private var originalPlotHandler : PlotHandler!
  
  // Find which icon, if any, is at a touch location; returns Touch.none if none
  //
  private func findTouchedIcon(event:TouchEvent) -> Touch {
		let position = event.locationRelativeToView(self)
    let rowIndex = rowContainingPoint(position)
    var elementIndex = -1
    var iconFlag = false
    if (rowIndex >= 0) {
      let row = rows[rowIndex]
      elementIndex = row.elementAt(position,omitPadding:true)
      if elementIndex >= 0 {
        let element = row.getElement(elementIndex)
        return Touch(view:self, rowIndex: rowIndex, elementIndex: elementIndex, touchOffset: CGPoint.difference(position,element.position))
      }
    }
    return Touch.none()
  }
  
  // Find which icon, if any, is at a touch location; if none, returns Touch.none
  //
  private func findTouchedCell(event:TouchEvent) -> Touch {
		let position = event.locationRelativeToView(self)
    let rowIndex = rowContainingPoint(position)
    if (rowIndex >= 0) {
      let row = rows[rowIndex]
      let elementIndex = row.elementAt(position,omitPadding:false)
      if (elementIndex >= 0) {
        return Touch(view:self,rowIndex:rowIndex, elementIndex:elementIndex)
      }
    }
    return Touch.none()
  }
  
  private var rows = Array<IconRow> ()
  
  private var rowCount : Int {
    get {
      return rows.count
    }
  }
  
  private func row(index : Int) -> IconRow {
    return rows[index]
  }
  
  private func ourTouchHandler(event:TouchEvent, view:View) -> Bool {
    if (event.type == .Down) {
      let oper = MoveIconOperation.constructForTouchEvent(event,self)
      if (oper == nil)  {
        return false
      }
      oper.start(event)
      return true
    }
    return false
  }
  
  private func rowContainingPoint(point:CGPoint) -> Int {
    for (index,row) in enumerate(rows) {
      if (row.bounds.contains(point)) {
      	return index
      }
    }
    return -1
  }
  
  // Encompasses information about which icon is under touch location
  //
  internal class Touch : Printable {
    
    private struct S {
      static var nullTouch = Touch(view:nil,rowIndex:-1,elementIndex:-1)
    }

    var description : String {
      return defined ? "Touch\(rowIndex)/\(elementIndex)" : "Touch.none"
    }
    
    let view : View!
    let rowIndex : Int
    let elementIndex : Int
    let touchOffset : CGPoint
    var defined : Bool {
      get {
        return !(self === S.nullTouch)
      }
    }

    class func none() -> Touch {
      return S.nullTouch
    }
    
    init(view:View!, rowIndex:Int, elementIndex:Int, touchOffset:CGPoint = CGPoint.zero) {
      self.view = view
      self.rowIndex = rowIndex
      self.elementIndex = elementIndex
      self.touchOffset = touchOffset
    }
    
  }

  // TouchListener interface
  //
  public func processTouchEvent(event: TouchEvent) {
    // Have the singleton MoveIconOperation handle the event
    let oper = MoveIconOperation.sharedInstance()
    oper.processTouchEvent(event, iconPanel:self)
  }
  
  // Operation for moving an icon
  //
  public class MoveIconOperation : TouchOperation {
    
    public class func sharedInstance() -> MoveIconOperation {
      return S.singleton
    }

    // Public overrides of TouchOperation methods
    
    public override func start(event : TouchEvent) {
      // Ignore the event passed in, since we've already constructed initialTouch from it
      
      activeTouch = initialTouch
      
      let iconPanel = initialTouch.view as IconPanel
      let row = iconPanel.row(activeTouch.rowIndex)
      let dragElement = DragElement.sharedInstance()
      let element = row.removeElement(activeTouch.elementIndex)
      dragElement.startDrag(event, element: element, touchOffset: initialTouch.touchOffset)
      insertGapAtActiveTouch()
      
      super.start(event)
    }
    
    public override func cancel() {
      if (running) {
        stopAux(true)
      }
      super.cancel()
    }
    
    public override func complete() {
      if (running) {
        stopAux(false)
      }
      super.complete()
    }
    
    public override func processEvent(touchEvent: TouchEvent) {
      // Call default implementation to notify listeners
    	super.processEvent(touchEvent)
      // If event is Up, and hasn't been handled, we're outside of all views; cancel
      if touchEvent.type == .Up && running {
          cancel()
      }
    }
    
    private func stopAux(cancelFlag: Bool) {
      if (!running) {
        return
      }
      let dragElement = DragElement.sharedInstance()
			
      // Get rid of gap placeholder
      removeElement(activeTouch)
      
      let targetTouch = cancelFlag ? initialTouch : activeTouch
      
      if !targetTouch.defined {
      	warning("no target touch defined!")
        return
      }
      
      // Put drag element's position at its actual drag location, relative to the target icon panel;
      // the DragElement class has been rendering it at that location, but hasn't been changing
      // its position property
      
      let iconPanel = targetTouch.view as IconPanel
      let pos = CGPoint.difference(dragElement.cursorPosition,iconPanel.position)
      dragElement.element.setActualPosition(pos)
      
      insertElement(targetTouch, dragElement.element)
      dragElement.stopDrag(nil)
    }
    
    public func processTouchEvent(event:TouchEvent, iconPanel:IconPanel) {
      let loc = event.locationRelativeToView(iconPanel)
      let within = iconPanel.localBounds.contains(loc)

      // Two distinct cases: touch is within our view, or not
      
      if within {
        
        if (event.type == .Up) {
          complete()
          return
        }
        
				let touchedCell = iconPanel.findTouchedCell(event)

        if (touchedCell.rowIndex != activeTouch.rowIndex) {
          // Remove gap, if one exists
          removeElement(activeTouch)
          activeTouch = Touch.none()
        }
        
        if !touchedCell.defined {
          return
        }
        
        if touchedCell.elementIndex != activeTouch.elementIndex {
          // Don't allow user to attempt to move last element in a row to its right
          if activeTouch.defined && activeTouch.elementIndex == iconPanel.row(touchedCell.rowIndex).count - 1
            && touchedCell.elementIndex > activeTouch.elementIndex {
              return
          }
          
          removeElement(activeTouch)
          
          activeTouch = touchedCell
          insertGapAtActiveTouch()
        }
        
			} else {
        if activeTouch.view === iconPanel {
          // Remove gap, if one exists
          removeElement(activeTouch)
          activeTouch = Touch.none()
        }
      }
    }
    
    // Insert a gap that's the same width as the dragged element, at the activeTouch location
    //
    private func insertGapAtActiveTouch() {
      let dragElement = DragElement.sharedInstance()
      let newElement = IconElement("",CGPoint(dragElement.element.size.x,20))
      insertElement(activeTouch,newElement)
    }
    
    // Construct an operation, if possible, for a DOWN event in an IconPanel
    // Returns operation, or nil
    //
    private class func constructForTouchEvent(event:TouchEvent, _ iconPanel:IconPanel) -> MoveIconOperation! {
      var ret : MoveIconOperation! = nil
      let touchedIcon = iconPanel.findTouchedIcon(event)
      if touchedIcon.defined {
        ret = S.singleton
        ret.prepare(touchedIcon)
      }
      return ret
    }
    
    private func prepare(initialTouch:Touch) {
    	self.initialTouch = initialTouch
      self.activeTouch = Touch.none()
    }
    
    private func removeElement(touch:Touch) {
      if !touch.defined {
        return
      }
      let iconPanel = touch.view as IconPanel
      let row = iconPanel.row(touch.rowIndex)
      if (touch.elementIndex < row.count) {
        row.removeElement(touch.elementIndex)
      }
    }
    
    private func insertElement(touch:Touch, _ newElement:IconElement) {
      if !touch.defined {
        return
      }
      let iconPanel = touch.view as IconPanel
      let row = iconPanel.row(touch.rowIndex)
      row.insert(newElement, atIndex: touch.elementIndex)
    }
    
    // Touch associated with initial Down event
    private var initialTouch = Touch.none()
    private var activeTouch = Touch.none()
    
    private struct S {
      static var singleton = MoveIconOperation()
    }

  }
  
}
