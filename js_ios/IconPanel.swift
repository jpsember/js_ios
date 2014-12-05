public class IconPanel : View {
  
  public var textureProvider : TextureProvider!
  public var rowHeight : CGFloat = 0
  public var rowPlotHandler : PlotHandler!
  
  private var rows = Array<IconRow> ()
  
  public var rowCount : Int {
    get {
      return rows.count
    }
  }
  
  public override init() {
    super.init()
    self.touchHandler = ourTouchHandler
  }
  
  public func getRow(index : Int) -> IconRow {
    return rows[index]
  }
  
  public func addRow() -> IconRow {
    ASSERT(rowHeight > 0,"must define rowheight")
    
    var iconRow = IconRow(self)
    iconRow.size = CGPoint(self.bounds.width,rowHeight)
    iconRow.position = CGPoint(0,CGFloat(rowCount) * rowHeight)
    if (rowPlotHandler != nil) {
      iconRow.plotHandler = rowPlotHandler
    }
    rows.append(iconRow)
    add(iconRow)
    return iconRow
  }
  
  // Layout each row 
  //
  public func layoutRows() {
    for row in rows {
      row.layout()
    }
  }

  // Find which icon, if any, is at a point (in the panel's coordinate system);
  // if found, returns (row, elementIndex, icon location - touch location); else (nil,-1,nil)
  //
  private func findIconAtPoint(location:CGPoint) -> (IconRow!, Int, CGPoint!) {
    let (row,position) = rowContainingPoint(location)
    if (row != nil) {
	    let elementIndex = row.elementAt(position)
      if elementIndex >= 0 {
        let element = row.getElement(elementIndex)
        return (row,elementIndex,CGPoint.difference(position,element.position))
      }
    }
    return (nil,-1,nil)
  }
  
  private func ourTouchHandler(event:TouchEvent, view:View) -> Bool {
    if (event.type == .Down) {
      let (row,elementIndex,touchOffset) = findIconAtPoint(event.locationRelativeToView(view))
      if elementIndex < 0 {
        return false
      }
      let oper = MoveIconOperation(row,elementIndex,touchOffset)
      oper.start(event)
      return true
    }
    return false
  }
  
  private func rowContainingPoint(point:CGPoint) -> (IconRow!,CGPoint!) {
    for row in rows {
      if (row.bounds.contains(point)) {
      	return (row,CGPoint.difference(point,row.bounds.origin))
      }
    }
    return (nil,nil)
  }
  
  // Operation for moving an icon
  //
  public class MoveIconOperation : TouchOperation {
    
    public init(_ iconRow:IconRow, _ elementIndex:Int, _ touchOffset:CGPoint) {
      self.sourceRow = iconRow
      self.elementIndex = elementIndex
      self.touchOffset = touchOffset
      self.dragElement = iconRow.getElement(elementIndex)
      super.init()
    }

    public override func start(event : TouchEvent) {
      sourceRow.removeElement(elementIndex)
      super.start(event)
    }
    
    public override func processEvent(event: TouchEvent) {
      if (event.type == .Up) {
        complete()
      } else {
        dragLocation = event.absoluteLocation
      }
    }
    
    public override func updateCursor(location: CGPoint) {
      let sprite = dragElement.sprite
      let loc = CGPoint.difference(dragLocation,touchOffset)
      sprite.render(loc)
    }
    
    private var elementIndex : Int
    private var sourceRow : IconRow
    private var touchOffset = CGPoint.zero
    private var dragLocation = CGPoint.zero
    private var dragElement : IconElement
  }
  
}
