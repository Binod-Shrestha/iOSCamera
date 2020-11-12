// StEP08: Codes for PhotoViewController

import UIKit

// implement UIScrollViewDelegate to enable zoom
class PhotoViewController: UIViewController, UIScrollViewDelegate
{
    // properties
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageView: UIImageView!
    var image: UIImage? = nil



    //=========================================================================
    override func viewDidLoad()
    {
        super.viewDidLoad()

        // set image
        self.imageView.image = image

        // set scrollview
        self.scrollView.delegate = self
        self.scrollView.maximumZoomScale = 10.0
    }



    //=========================================================================
    // delegates for scroll view
    func viewForZooming(in scrollView: UIScrollView) -> UIView?
    {
        // return nil, if you do not want to zoom
        return self.imageView
    }
}
