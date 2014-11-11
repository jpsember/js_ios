import GLKit
import OpenGLES

public class JSGLView: GLKView {

    override public var description: String {
        return "frame=\(self.frame)"
    }

    // Factory constructor
    public class func build(#frame:CGRect) -> JSGLView {
        let view = JSGLView(frame:frame)
        puts("Built JSGLView \(view)")
        return view
    }

    public override init(frame:CGRect) {
        let c = EAGLContext(API:EAGLRenderingAPI.OpenGLES2)
        super.init(frame:frame, context:c)
    }
    
    public required init(coder decoder: NSCoder) {
        super.init(coder: decoder)
    }
    

}
