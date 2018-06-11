//
//  ViewController.swift
//  PlayingCard
//
//  Created by kevinhe on 2018/2/13.
//  Copyright © 2018年 kevinhe. All rights reserved.
//

import UIKit
import Darwin

class ViewController: UIViewController {
    
    var deck = PlayingCardDeck()
    
    
    @IBOutlet var cardViews: [PlayingCardView]!
    
    lazy var animator = UIDynamicAnimator(referenceView: view)  //1
    
    lazy var cardBehavior = CardBehavior(in: animator)
    
    @IBOutlet weak var playCardView: PlayingCardView!{
        didSet{
            let swipe = UISwipeGestureRecognizer(target: self, action: #selector(nextCard))
            swipe.direction = [.left, .right, .up, .down]
            playCardView.addGestureRecognizer(swipe)
            
            let pinch = UIPinchGestureRecognizer(target: playCardView, action: #selector(playCardView.adustFaceCardScale(byHandlingGestureRecognizer:)))
            playCardView.addGestureRecognizer(pinch)
        }
    }
    @objc func nextCard() {
        if let card = deck.draw() {
            playCardView.rank = card.rank.order
            playCardView.suit = card.suit.rawValue
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var cards = [PlayingCard]()
        for _ in 1...((cardViews.count + 1) / 2) {
            let card = deck.draw()!
            cards += [card, card]
        }
        for cardView in cardViews {
            cardView.isFaceUp = false
            let card = cards.remove(at: cards.count.arc4random)
            cardView.rank = card.rank.order
            cardView.suit = card.suit.rawValue
            cardView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(flipCard(_:))))
            cardBehavior.addItem(cardView)   //3

            
        }
    }
    
    private var faceUpCardView: [PlayingCardView] {
        return cardViews.filter{ $0.isFaceUp && !$0.isHidden && $0.transform != CGAffineTransform.identity.scaledBy(x: 3.0, y: 3.0) && $0.alpha == 1}
    }
    
    private var faceUpCardViewsMatch: Bool {
        return faceUpCardView.count == 2 &&
            faceUpCardView[0].rank == faceUpCardView[1].rank &&
            faceUpCardView[0].suit == faceUpCardView[1].suit
    }
    
    var lastChosenCardView: PlayingCardView?
    @objc func flipCard(_ recognizer: UITapGestureRecognizer) {
        switch recognizer.state {
        case .ended:
            if let chosenCardView = recognizer.view as? PlayingCardView, faceUpCardView.count < 2 {
                lastChosenCardView = chosenCardView
                cardBehavior.removeItem(chosenCardView)
                UIView.transition(with: chosenCardView,
                                  duration: 0.6,
                                  options: .transitionFlipFromLeft,
                                  animations: { chosenCardView.isFaceUp = !chosenCardView.isFaceUp },
                                  completion: { finished in
                                    let cardsToAnimate = self.faceUpCardView
                                    if self.faceUpCardViewsMatch {
                                        UIViewPropertyAnimator.runningPropertyAnimator(
                                            withDuration: 3.0,
                                            delay: 0,
                                            options: [],
                                            animations: {
                                                cardsToAnimate.forEach {
                                                    $0.transform = CGAffineTransform.identity.scaledBy(x: 3.0, y: 3.0)
                                                }
                                        },
                                            completion: { position in
                                                UIViewPropertyAnimator.runningPropertyAnimator(
                                                    withDuration: 2.0,
                                                    delay: 0,
                                                    options: [],
                                                    animations: {
                                                        cardsToAnimate.forEach {
                                                            $0.transform = CGAffineTransform.identity.scaledBy(x: 0.1, y: 0.1)
                                                            $0.alpha = 0
                                                        }
                                                },
                                                completion: { position in
                                                    cardsToAnimate.forEach {
                                                        $0.isHidden = true
                                                        $0.alpha = 1
                                                        $0.transform = .identity
                                                    }
                                                }
                                                )
                                        })
                                    } else if cardsToAnimate.count == 2 {
                                        if chosenCardView == self.lastChosenCardView {
                                            cardsToAnimate.forEach { cardViews in
                                                UIView.transition(with: cardViews,
                                                                  duration: 0.6,
                                                                  options: .transitionFlipFromLeft,
                                                                  animations: { cardViews.isFaceUp = false },
                                                                  completion: { finished in
                                                                  self.cardBehavior.addItem(cardViews)
                                                    }
                                                )
                                            }
                                        } // 按tab 向前缩进
                                    } else {
                                        if !chosenCardView.isFaceUp {
                                            self.cardBehavior.addItem(chosenCardView)
                                        }
                                    }
                            }
                        )
                    }
        default: break
        }
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

extension CGFloat {
    var arc4random:CGFloat{
        if self > 0 {
            return CGFloat(arc4random_uniform(UInt32(self)))
        }else if self < 0{
            return -CGFloat(arc4random_uniform(UInt32(abs(self))))
        }else{
            return 0
        }
    }
}

