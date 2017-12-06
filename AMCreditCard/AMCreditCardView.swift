//
//  AMCreditCardView.swift
//  AMCreditCard
//
//  Created by Artur Mkrtchyan on 11/30/17.
//  Copyright © 2017 Artur Mkrtchyan. All rights reserved.
//

import UIKit

fileprivate let kCardRatio = 1.58577 // ISO/IEC 7810 ID-1 standard
fileprivate let kCornerRadius = 9.0
fileprivate let kDefaultWidth = 243.0

@IBDesignable
open class AMCreditCardView: UIView {
    private var allNibs: [UIView]!
    private var view: UIView!
    private var backView: UIView!
    
    //MARK: - Font Sizes.
    //Consider that cardview's width is equal to 243 while setting the size of fonts
    open var cardNumberFontSize:CGFloat = 12.0
    open var cardHoldersFontSize:CGFloat = 10.0
    open var validThruTitleFontSize:CGFloat = 6.0
    open var validThruValueFontSize:CGFloat = 7.0
    open var cvvFontSize:CGFloat = 10.0
    
    open var shouldInsertSpacesEveryFourDigitsIntoString = true
    open var cardNumber:String? {
        didSet {
            guard let cardNumber = cardNumber else {
                self.cardNumberLabel.text = ""
                self.refreshCardType()
                return
            }
            if shouldInsertSpacesEveryFourDigitsIntoString {
                let cleanedNumber = cardNumber.replacingOccurrences(of: " ", with: "")
                self.cardNumberLabel.text = self.insertSpacesEveryFourDigitsIntoString(cleanedNumber)
            } else {
                self.cardNumberLabel.text = cardNumber
            }
            
            self.refreshCardType()
        }
    }
    
    open var cvv:String? {
        didSet {
            self.cvvLabel.text = cvv ?? ""
        }
    }
    
    open var cardHoldersName:String? {
        didSet {
            self.cardHoldersNameLabel.text = cardHoldersName ?? ""
        }
    }
    
    open var expirationDate:String? {
        didSet {
            self.validThruValueLabel.text = expirationDate ?? ""
        }
    }
    
    open var cardType:AMCreditCardType = .unknown {
        didSet {
            switch cardType {
            case .mastercard:
                self.cardTypeImageView.image = UIImage(named: "masterCardLogo.png")
            case .visa,
                 .visaElectron:
                self.cardTypeImageView.image = UIImage(named: "visaCardLogo.png")
            case .americanExpress:
                self.cardTypeImageView.image = UIImage(named: "amexCardLogo.png")
            case .discovery:
                self.cardTypeImageView.image = UIImage(named: "discoverCardLogo.png")
            case .maestro:
                self.cardTypeImageView.image = UIImage(named: "maestroCardLogo.png")
            default:
                self.cardTypeImageView.image = nil
            }
        }
    }
    
    //MARK: - Outlets
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var backgroundImageView: UIImageView!
    
    @IBOutlet weak var backContentView: UIView!
    @IBOutlet weak var backBackgroundView: UIView!
    @IBOutlet weak var backBackgroundImageView: UIImageView!        
    
    @IBOutlet weak var chipImageView: UIImageView!
    @IBOutlet weak var cardNumberLabel: UILabel!
    @IBOutlet weak var cardTypeImageView: UIImageView!
    @IBOutlet weak var validThruTitleLabel: UILabel!
    @IBOutlet weak var validThruValueLabel: UILabel!
    @IBOutlet weak var cardHoldersNameLabel: UILabel!
    
    @IBOutlet weak var cvvLabel: UILabel!
    
    
    init() {
        super.init(frame: CGRect(x: 0, y: 0, width: kDefaultWidth, height: kDefaultWidth * kCardRatio))
        xibLoad()
        setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        xibLoad()
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        xibLoad()
        setup()
    }
    
    //MARK: - Private methods
    private func xibLoad() {
        loadViewFromNib()
        backView = allNibs[1]
        backView.frame = bounds
        backView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(backView)
        backView.isHidden = true
        
        view = allNibs[0]
        view.frame = bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(view)
    }
    
    private func loadViewFromNib() {
        let bundle = Bundle(for: AMCreditCardView.self)
        let nib = UINib(nibName: "AMCreditCardView", bundle: bundle)
        allNibs = nib.instantiate(withOwner: self, options: nil) as? [UIView]
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        
        let multiplier = contentView.frame.size.width / 243.0
        reloadFont(label: cardNumberLabel, size: 12.0)
        reloadFont(label: cardHoldersNameLabel, size: 10.0)
        reloadFont(label: validThruTitleLabel, size: 6.0)
        reloadFont(label: validThruValueLabel, size: 7.0)
        reloadFont(label: cvvLabel, size: 10.0)
            
        backgroundView.layer.cornerRadius = CGFloat(kCornerRadius) * multiplier
        backgroundImageView.layer.cornerRadius = CGFloat(kCornerRadius) * multiplier
        
        backBackgroundView.layer.cornerRadius = CGFloat(kCornerRadius) * multiplier
        backBackgroundImageView.layer.cornerRadius = CGFloat(kCornerRadius) * multiplier
    }
    
    private func setup() {
        backgroundImageView.layer.masksToBounds = true
        backBackgroundImageView.layer.masksToBounds = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0) {
            self.setNeedsLayout()
        }
    }
    
    private func reloadFont(label: UILabel, size: CGFloat) {
        let multiplier = self.contentView.frame.size.width / 243.0
        label.font = UIFont(name: label.font.fontName, size: size * multiplier)
    }
    
    private func insertSpacesEveryFourDigitsIntoString(_ string: String) -> String {
        var result = ""
        for i in 0 ..< string.count {
            if i > 0 && (i % 4 == 0) {
                result += "  "
            }
            result.append(string[string.index(string.startIndex, offsetBy: i)])
        }
        
        return result
    }
    
    //MARK: - Public methods
    
    open func refreshUI() {
        self.setNeedsLayout()
    }
    
    @objc open func refreshCardType() {
        let cleanedNumber = (self.cardNumberLabel.text ?? "").replacingOccurrences(of: " ", with: "")
        self.cardType = AMCreditCardTypeChecker.checkType(cleanedNumber)
    }
    
    @objc open func flip() {
        let firstView = view.isHidden ? backView : view
        let secondView = view.isHidden ? view : backView
        
        let transitionOptions: UIViewAnimationOptions = [.transitionFlipFromRight, .showHideTransitionViews]
        
        UIView.transition(with: firstView!, duration: 0.5, options: transitionOptions, animations: {
            firstView!.isHidden = true
        })
        
        UIView.transition(with: secondView!, duration: 0.5, options: transitionOptions, animations: {
            secondView!.isHidden = false
        })
    }
}

public enum AMCreditCardType {
    case unknown
    case visa
    case visaElectron
    case mastercard
    case maestro
    case americanExpress
    case dinnersClub
    case discovery
    case jcb
    
    static var all: [AMCreditCardType] {
        return [
            .visa,
            .visaElectron,
            .mastercard,
            .maestro,
            .americanExpress,
            .dinnersClub,
            .discovery,
            .jcb
        ]
    }
    
    var pattern: String {
        switch self {
        case .visa: return "^4[0-9]{12}(?:[0-9]{3})?$"
        case .visaElectron: return "^(4026|417500|4508|4844|491(3|7))"
        case .mastercard: return "^5[1-5][0-9]{14}$"
        case .maestro: return "^(5018|5020|5038|6304|6759|676[1-3])"
        case .americanExpress: return "^3[47][0-9]{13}$"
        case .dinnersClub: return "^3(?:0[0-5]|[68][0-9])[0-9]{11}$"
        case .discovery: return "^6(?:011|5[0-9]{2})[0-9]{12}$"
        case .jcb: return "^(?:2131|1800|35\\d{3})\\d{11}$"
        case .unknown:
            return ""
        }
    }
}

open class AMCreditCardTypeChecker {
    static func checkType(_ cardNumber: String) -> AMCreditCardType {
        for type in AMCreditCardType.all {
            let regexp = try? NSRegularExpression(pattern: type.pattern, options: .caseInsensitive)
            if let result = regexp?.matches(in: cardNumber, options: [], range: NSMakeRange(0, cardNumber.count)), result.count > 0 {
                return type
            }
        }
        
        return .unknown
    }
}
