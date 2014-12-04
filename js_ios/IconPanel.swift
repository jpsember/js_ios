
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
  
  public override init(_ size:CGPoint, opaque:Bool = true, cacheable:Bool = true) {
    super.init(size,opaque:opaque,cacheable:cacheable)
    self.touchHandler = ourTouchHandler
    self.plotHandler = ourPlotHandler
  }
  
  public func getRow(index : Int) -> IconRow {
    return rows[index]
  }
  
  public func addRow() -> IconRow {
    ASSERT(rowHeight > 0,"must define rowheight")
    
    var iconRow = IconRow(CGPoint(self.bounds.width,rowHeight))
    iconRow.position = CGPoint(0, CGFloat(rowCount) * rowHeight)
    if (rowPlotHandler != nil) {
      iconRow.plotHandler = rowPlotHandler
    }
    iconRow.textureProvider = textureProvider
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

  private func ourTouchHandler(event:TouchEvent, view:View) -> Bool {
    if (event.type == .Down) {
      puts("touchHandler \(event)")
      let (row,position) = rowContainingPoint(event.location)
      puts("row containing point = \(row), position \(position)")
      if (row == nil) {
        return false
      }
      
      let elementIndex = row.elementAt(position)
      puts("element index \(elementIndex)")
      if elementIndex < 0 {
        return false
      }
      
      dragIndex = elementIndex
      dragRow = row
      return true
      
    } else {
      if (dragIndex < 0) {
        return false
      }
      puts("touchHandler \(event)")
      
      if (event.type == .Up) {
        dragIndex = -1
      } else {
        dragLocation = event.location
      }
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
  
  private func ourPlotHandler(view : View) {
    puts("IconPanel ourPlotHandler")
    
    defaultPlotHandler(view)
    if (dragIndex >= 0) {
      let element = dragRow.getElement(dragIndex)
      let sprite = element.sprite
      ASSERT(sprite != nil,"sprite is nil")
      sprite.render(dragLocation)
    }
  }
  
  private var dragIndex = -1
  private var dragRow : IconRow!
  private var dragLocation = CGPoint.zero
}

