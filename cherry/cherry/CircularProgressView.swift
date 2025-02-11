import UIKit

class CircularProgressView: UIView {
    
    private var progressLayer = CAShapeLayer()
    private var trackLayer = CAShapeLayer()
    private let imageView = UIImageView()
    private let scoreLabel = UILabel()

    var setProgressColor: UIColor = UIColor.red {
        didSet { progressLayer.strokeColor = setProgressColor.cgColor }
    }

    var setTrackColor: UIColor = UIColor.white {
        didSet { trackLayer.strokeColor = setTrackColor.cgColor }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupSubviews()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        configureProgressViewToBeCircular()
        layoutImageView()
        layoutScoreLabel()
    }
    
    private func layoutImageView() {
        let imageSize = bounds.width * 0.23  // Adjusted to be larger and centered
        imageView.frame = CGRect(x: (bounds.width - imageSize) / 2,
                                 y: (bounds.height - imageSize) / 2,
                                 width: imageSize,
                                 height: imageSize)
    }

    private func layoutScoreLabel() {
        scoreLabel.frame = CGRect(x: 0,
                                  y: bounds.midY + bounds.width * 0.25,
                                  width: bounds.width,
                                  height: 30)
    }

    func setImage(_ image: UIImage?) {
        imageView.image = image
    }

    func setScore(_ score: Int) {
        scoreLabel.text = "\(score)/42"
    }

    func setProgress(_ value: Int) {
        let progress = CGFloat(value) / 42.0  // Normalize to a value between 0 and 1
        setProgressWithAnimation(duration: 1.0, value: progress)
        setScore(value) // Update label
    }

    private func setupSubviews() {
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "Cherry 1.4")
        addSubview(imageView)
        
        scoreLabel.textAlignment = .center
        scoreLabel.textColor = .black
        scoreLabel.font = UIFont.boldSystemFont(ofSize: 18)
        addSubview(scoreLabel)
    }

    private func configureProgressViewToBeCircular() {
        trackLayer.removeFromSuperlayer()
        progressLayer.removeFromSuperlayer()

        let diameter = min(bounds.width, bounds.height)
        let lineWidth: CGFloat = diameter * 0.1
        let radius = (diameter - lineWidth) / 2

        let centerPoint = CGPoint(x: bounds.midX, y: bounds.midY)
        let circularPath = UIBezierPath(arcCenter: centerPoint,
                                        radius: radius,
                                        startAngle: -CGFloat.pi / 2,
                                        endAngle: 1.5 * CGFloat.pi,
                                        clockwise: true)

        trackLayer.path = circularPath.cgPath
        trackLayer.fillColor = UIColor.clear.cgColor
        trackLayer.strokeColor = setTrackColor.cgColor
        trackLayer.lineWidth = lineWidth
        trackLayer.strokeEnd = 1.0
        layer.addSublayer(trackLayer)

        progressLayer.path = circularPath.cgPath
        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.strokeColor = setProgressColor.cgColor
        progressLayer.lineWidth = lineWidth
        progressLayer.strokeEnd = 0.0
        layer.addSublayer(progressLayer)
    }

    func setProgressWithAnimation(duration: TimeInterval, value: CGFloat) {
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.duration = duration
        animation.fromValue = progressLayer.strokeEnd
        animation.toValue = value
        animation.timingFunction = CAMediaTimingFunction(name: .linear)
        progressLayer.strokeEnd = value
        progressLayer.add(animation, forKey: "animateCircle")
    }
}

