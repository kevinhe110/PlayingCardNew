//
//  PlayingCardView.swift
//  PlayingCard
//
//  Created by kevinhe on 2018/2/14.
//  Copyright © 2018年 kevinhe. All rights reserved.
//

import UIKit

@IBDesignable
class PlayingCardView: UIView {

    @IBInspectable
    var rank:Int = 11 { didSet { setNeedsDisplay(); setNeedsLayout()} }
    @IBInspectable
    var suit:String = "♥️" { didSet { setNeedsDisplay(); setNeedsLayout() } }
    @IBInspectable
    var isFaceUp:Bool = true { didSet { setNeedsDisplay(); setNeedsLayout() } }
    
    var faceCardScale: CGFloat = SizeRatio.faceCardImageSizeToBoundsSize { didSet { setNeedsDisplay()} }
    
    @objc func adustFaceCardScale(byHandlingGestureRecognizer recognizer: UIPinchGestureRecognizer) {
        switch recognizer.state {
        case .changed, .ended:
            faceCardScale *= recognizer.scale
            recognizer.scale = 1.0
        default: break
        }
    }
    
    private func centeredAttributedString(_ string: String, fontSize:CGFloat) -> NSAttributedString{
        var font = UIFont.preferredFont(forTextStyle: .body).withSize(fontSize)
        font = UIFontMetrics(forTextStyle: .body).scaledFont(for: font)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        return NSAttributedString(string: string, attributes: [.paragraphStyle: paragraphStyle, .font: font])
    }
    
    private var cornerString: NSAttributedString{
        return centeredAttributedString(rankString+"\n"+suit, fontSize: fontFontSize)
    }
    
    private func creatCornLabel() -> UILabel {
        let label = UILabel()
        label.numberOfLines = 0
        addSubview(label)
        return label
    }
    
    private lazy var leftUpCornLabel: UILabel = creatCornLabel()
    private lazy var rightDownCornLabel: UILabel = creatCornLabel()
    
    private func configureLabel(_ label: UILabel){
        label.attributedText = cornerString
        label.frame.size = CGSize.zero
        label.sizeToFit()
        label.isHidden = !isFaceUp
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        setNeedsDisplay()
        setNeedsLayout()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        configureLabel(leftUpCornLabel)
        leftUpCornLabel.frame.origin = bounds.origin.offsetBy(dx: cornerOffset, dy: cornerOffset)
        
        configureLabel(rightDownCornLabel)
        rightDownCornLabel.frame.origin = CGPoint(x: bounds.maxX, y: bounds.maxY)
            .offsetBy(dx: -cornerOffset, dy: -cornerOffset)
            .offsetBy(dx: -rightDownCornLabel.frame.size.width, dy: -rightDownCornLabel.frame.size.height)
        rightDownCornLabel.transform = CGAffineTransform.identity
//            .translatedBy(x: rightDownCornLabel.frame.size.width, y: rightDownCornLabel.frame.size.height)
              .rotated(by: CGFloat.pi)
        // func draw pips

        
        
    }
    
    
    override func draw(_ rect: CGRect) {
        //        let path = UIBezierPath()
        //        path.addArc(withCenter: CGPoint(x: bounds.midX, y: bounds.midY), radius: 50, startAngle: 0, endAngle: 2*CGFloat.pi, clockwise: true)
        //        path.lineWidth = 100
        //        UIColor.red.setStroke()
        //        UIColor.green.setFill()
        //        path.stroke()
        //        path.fill()
        //step 1
        let roundRect = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius)
        roundRect.addClip()
        UIColor.white.setFill()
        roundRect.fill()
        
        // make photo
        if isFaceUp {
            if let faceCardImage = UIImage(named: rankString+suit, in: Bundle(for: self.classForCoder), compatibleWith: traitCollection){
                faceCardImage.draw(in: bounds.zoom(by: faceCardScale))
            }else{
                drawPips()
            }
        }else{
            if let cardBackImage = UIImage(named: "cardback", in: Bundle(for: self.classForCoder), compatibleWith: traitCollection) {
                cardBackImage.draw(in: bounds)
            }
        }
    }
    private func drawPips() {
        let pipsPerRowForRank = [[0],[1],[1,1],[1,1,1],[2,2],[2,1,2],[2,2,2],[2,1,2,2],[2,2,2,2],[2,2,1,2,2],[2,2,2,2,2]]
        
        func creatPipString(thatFits pipRect: CGRect) -> NSAttributedString{
            //最大行数
            let maxVerticalPipCount = CGFloat(pipsPerRowForRank.reduce(0){max($1.count, $0) })
            //最大列数
            let maxHorizontalPipCount = CGFloat(pipsPerRowForRank.reduce(0){max($1.max() ?? 0, $0) })
            let verticalPipRowSpacing = pipRect.size.height / maxVerticalPipCount
            let attemptedPipString = centeredAttributedString(suit, fontSize: verticalPipRowSpacing)
            let probablyOkayPipsStringFontSize = verticalPipRowSpacing / (attemptedPipString.size().height / verticalPipRowSpacing)
            let probablyOkayPipString = centeredAttributedString(suit, fontSize: probablyOkayPipsStringFontSize)
            if probablyOkayPipString.size().width > pipRect.size.width / maxHorizontalPipCount {
                return centeredAttributedString(suit, fontSize: probablyOkayPipsStringFontSize / (probablyOkayPipString.size().width / (pipRect.size.width / maxHorizontalPipCount)))
            }else{
                return probablyOkayPipString
            }
        }
        
        if pipsPerRowForRank.indices.contains(rank){
            let pipsPerRow = pipsPerRowForRank[rank]
            var pipRect = bounds.insetBy(dx: cornerOffset, dy: cornerOffset)
                .insetBy(dx: cornerString.size().width, dy: cornerString.size().height / 2)
            let pipString = creatPipString(thatFits:pipRect)
            let pipRowSpacing = pipRect.size.height / CGFloat(pipsPerRow.count)
            pipRect.size.height = pipString.size().height
            pipRect.origin.y += (pipRowSpacing - pipRect.size.height) / 2
            for pipCount in pipsPerRow{
                switch pipCount {
                case 1: pipString.draw(in: pipRect)
                case 2:
                    pipString.draw(in: pipRect.leftHalf)
                    pipString.draw(in: pipRect.rightHalf)
                default: break
                }
                pipRect.origin.y += pipRowSpacing
            }
            
        }
    }
}
extension PlayingCardView{
    
    private struct SizeRatio {
        static let cornerFontSizeToBoundsHeight: CGFloat = 0.085
        static let cornerRatiusToBoundsHeight: CGFloat = 0.06
        static let cornerOffsetToCornerRadius: CGFloat = 0.33
        static let faceCardImageSizeToBoundsSize: CGFloat = 0.75
    }
    private var fontFontSize: CGFloat{
        return bounds.size.height*SizeRatio.cornerFontSizeToBoundsHeight
    }
    
    private var cornerRadius: CGFloat{
        return bounds.size.height*SizeRatio.cornerRatiusToBoundsHeight
    }
    
    private var cornerOffset: CGFloat{
        return cornerRadius*SizeRatio.cornerOffsetToCornerRadius
    }
    
    private var rankString: String {
        switch rank {
        case 1: return "A"
        case 2...10: return String(rank)
        case 11: return "J"
        case 12: return "Q"
        case 13: return "K"
        default: return "?"
        }
    }
}


extension CGRect{
    var leftHalf: CGRect{
        return  CGRect(x: minX, y: minY, width: width/2, height: height)
    }
    var  rightHalf: CGRect{
        return  CGRect(x: midX, y: minY, width: width/2, height: height)
    }
    
    func zoom(by scale: CGFloat) -> CGRect{
        let newWidth = width * scale
        let newHeight = height * scale
        return insetBy(dx: (width - newWidth) / 2, dy: (height - newHeight) / 2)
    }
    
}


extension CGPoint{
    func offsetBy(dx: CGFloat,dy: CGFloat) -> CGPoint{
        return CGPoint(x: x+dx, y: y+dy)
    }
}
