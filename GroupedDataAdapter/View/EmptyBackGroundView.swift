//
//  EmptyBackGroundView.swift
//  GroupedDataAdapter
//
//  Created by APPLE on 29/10/20.
//

import UIKit

class EmptyBackGroundView: UIView {

    @IBOutlet var contentView: UIView!
    @IBOutlet var ivIcon : UIImageView!
    @IBOutlet var btnAction : UIButton!
    @IBOutlet var lblInfo : UILabel!
    
    typealias ActionButtonClickedBlock = (_ button: UIButton)->()
    var buttonClickedBlock: ActionButtonClickedBlock?
    
    var nibName: String {
        return String(describing: type(of: self))
    }
    
    //MARK:
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        loadViewFromNib()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        loadViewFromNib()
    }
    
    init(_ imgICon : UIImage?,_ btnActionText : String) {
        super.init(frame : .zero)
        loadViewFromNib()
        self.ivIcon.image = imgICon?.withTintColor(.black, renderingMode: .alwaysTemplate)
        self.lblInfo.text = btnActionText
        
    }
    
    //MARK:
    func loadViewFromNib() {
        contentView = Bundle.main.loadNibNamed(nibName, owner: self, options: nil)?[0] as? UIView
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        contentView.frame = bounds
        self.backgroundColor = .clear
        self.contentView.backgroundColor = .clear
        addSubview(contentView)
    }
    
    //Custom Method
    @IBAction func btnActionClicked(_ sender: UIButton) {
        self.buttonClickedBlock?(sender)
    }
    
    func changeBackgroundColor(_ color : UIColor) {
        self.lblInfo.textColor = color
        self.ivIcon.tintColor = color
    }

}
