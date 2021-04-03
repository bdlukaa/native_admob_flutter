class PaddedImageView: UIImageView {
    var UIEI = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)

    init(data: [String: Any]) {
        super.init(frame: .zero)
        let paddingRight = CGFloat(data["paddingRight"] as? Float ?? 0)
        let paddingLeft = CGFloat(data["paddingLeft"] as? Float ?? 0)
        let paddingTop = CGFloat(data["paddingTop"] as? Float ?? 0)
        let paddingBottom = CGFloat(data["paddingBottom"] as? Float ?? 0)

        UIEI = UIEdgeInsets(top: -paddingTop, left: -paddingLeft, bottom: -paddingBottom, right: -paddingRight)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var alignmentRectInsets: UIEdgeInsets {
        return UIEI
    }
}
