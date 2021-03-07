import UIKit

extension Double {
    func toRadian() -> CGFloat {
        return CGFloat(self) * CGFloat.pi/180
    }
}

class StarIcon: UIView {
    
    var color: UIColor = .yellow {
        didSet { setNeedsDisplay() }
    }
    
    init() {
        super.init(frame: .zero)
        backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        let points = pointsInRect(rect)
        let path = UIBezierPath()
        path.lineWidth = 1
        
        path.move(to: points[0])
        path.addLine(to: points[2])
        path.addLine(to: points[4])
        path.addLine(to: points[1])
        path.addLine(to: points[3])
        path.addLine(to: points[0])
        path.close()
        
        color.setFill()
        path.fill()
    }
    
    func pointsInRect(_ rect: CGRect) -> [CGPoint] {
        let centerPoint = CGPoint(x: rect.width/2, y: rect.height/2)
        let radius = rect.width/2
        let angle: Double = 72
        
        var points: [CGPoint] = []
        
        var startAngle = -CGFloat.pi/2
        for _ in 0..<5 {
            let x = centerPoint.x + radius * cos(startAngle)
            let y = centerPoint.y + radius * sin(startAngle)
            let point = CGPoint(x: x, y: y)
            points.append(point)
            
            startAngle += angle.toRadian()
        }
        
        return points
    }
}
