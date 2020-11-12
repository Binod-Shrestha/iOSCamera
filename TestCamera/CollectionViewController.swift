// STEP06: Code for CollectionViewController

import UIKit
import MobileCoreServices   // for kUTTypeImage & kUTTypeMovie


class CollectionViewController: UICollectionViewController,
                                UICollectionViewDelegateFlowLayout, // for resizing cell
                                UIImagePickerControllerDelegate,    // for camera
                                UINavigationControllerDelegate      // for push/pop imagepicker
{
    // properties
    var imageUrls = [URL]()
    var hasCamera = false
    var hasPhotoLibrary = false



    //=========================================================================
    override func viewDidLoad()
    {
        super.viewDidLoad()

        // get existing files in app's document folder
        imageUrls = getImageFileNames()
        print(imageUrls)    // debug

        // check device capabilities
        hasCamera = UIImagePickerController.isSourceTypeAvailable(.camera)
        hasPhotoLibrary = UIImagePickerController.isSourceTypeAvailable(.photoLibrary)
    }



    //=========================================================================
    // open camera using UIImagePickerController
    @IBAction func openCamera(_ sender: Any)
    {
        // check device capability
        if !hasCamera
        {
            self.showAlert(message: "Device has no camera.")
            return
        }

        // open camera window
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .camera
        //picker.mediaTypes = [kUTTypeImage as String, kUTTypeMovie as String] // to capture movie as well
        picker.allowsEditing = true
        self.present(picker, animated: true, completion: nil)
    }



    //=========================================================================
    // open photo library using UIImagePickerController
    @IBAction func openAlbum(_ sender: Any)
    {
        // check device capability
        if !hasPhotoLibrary
        {
            self.showAlert(message: "Device has no photo library.")
            return
        }

        // open library window
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        self.present(picker, animated: true, completion: nil)
    }



    //=========================================================================
    func showAlert(title:String = "Error", message:String)
    {
        // create alert controller
        let alert = UIAlertController(title:title, message:message, preferredStyle:.alert)

        // add default button
        alert.addAction(UIAlertAction(title:"OK", style:.default, handler:nil))

        // show it
        self.present(alert, animated:true, completion:nil)
    }



    //=========================================================================
    // generate a date string
    func dateToString(_ date: Date) -> String
    {
        let df = DateFormatter()
        df.timeZone = TimeZone(secondsFromGMT: 0)
        df.dateFormat = "yyyy-MM-dd-HHmmss"
        return df.string(from: date)
    }



    //=========================================================================
    // get list of jpg images in app's document folder
    func getImageFileNames() -> [URL]
    {
        var files = [URL]()
        let dfm = FileManager.default
        let docUrl = dfm.urls(for: .documentDirectory, in: .userDomainMask)[0]
        do
        {
            let urls = try dfm.contentsOfDirectory(at: docUrl,
                                                   includingPropertiesForKeys: nil,
                                                   options: [])
            // filter only jpeg files
            files = urls.filter { $0.pathExtension == "jpg" || $0.pathExtension == "jpeg" }
        }
        catch
        {
            print(error.localizedDescription)
        }
        return files
    }



    //=========================================================================
    func saveJpg(_ image: UIImage, _ filename: String, _ quality: CGFloat = 0.8)
    {
        let dfm = FileManager.default
        let docUrl = dfm.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let url = docUrl.appendingPathComponent(filename)
        //print(docPath)

        // convert image to data
        if let data = image.jpegData(compressionQuality: quality)
        {
            do
            {
                // write data to file
                try data.write(to: url)
            }
            catch
            {
                print(error.localizedDescription)
            }
        }
    }



    //=========================================================================
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.identifier == "seguePhoto"
        {
            if let vc = segue.destination as? PhotoViewController
            {
                // get tapped cell first
                if let cell = sender as? PhotoCell
                {
                    // pass image to destination
                    vc.image = cell.imageView.image
                }
            }
        }
    }



    //=========================================================================
    // delegates for UIImagePickerController
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any])
    {
        // get image from picker: .originalImage or .editedImage
        if let image = info[.editedImage] as? UIImage
        {
            // generate a unique filename
            //let filename = "image-" + UUID().uuidString + ".jpg"
            let filename = "image-" + dateToString(Date()) + ".jpg"
            saveJpg(image, filename, 0.5)

            // save new file to the list
            let docUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let url = docUrl.appendingPathComponent(filename)
            imageUrls.append(url)
            collectionView.reloadData()
            //print(filename)
        }

        // must close the picker by yourself
        picker.dismiss(animated: true, completion: nil)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController)
    {
        picker.dismiss(animated: true, completion: nil)
    }



    //=========================================================================
    // delegates for UICollectionViewDelegate, UICollectionViewDataSource
    override func numberOfSections(in collectionView: UICollectionView) -> Int
    {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return imageUrls.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCell", for: indexPath) as! PhotoCell

        // load an image
        let index = indexPath.row
        let url = imageUrls[index]
        // load file -> Data -> UIImage
        if let data = try? Data(contentsOf: url),
           let image = UIImage(data: data)
        {
            cell.imageView.image = image
        }
        return cell
    }



    // EXTRA CODES for CollectionViewDelegate
    /*
    // override this to resize cell width/height dynamically
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayoyt: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        var cellWidth = 100 // default size
        return CGSize(width: cellWidth, height: cellWidth)
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool
    {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool
    {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool
    {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool
    {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?)
    {
    }
    */

}
