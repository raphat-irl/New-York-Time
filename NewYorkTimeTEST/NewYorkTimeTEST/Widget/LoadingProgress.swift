import UIKit

var aView: UIView?

extension UIViewController {
    
    func startLoading() {
        aView = UIView(frame: self.view.bounds)
        //aView?.backgroundColor = UIColor.init(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5)
        aView?.backgroundColor = .clear
        let ai = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.large)
        ai.layer.cornerRadius = 6
        ai.center = aView!.center
        ai.startAnimating()
        aView?.addSubview(ai)
        self.view.addSubview(aView!)
    }
    
    func stopLoading() {
        aView?.removeFromSuperview()
        aView = nil
    }
}
