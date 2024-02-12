import UIKit
import CoreData
import UserNotifications
import PDFKit // Import PDFKit framework for working with PDFs

class PDFDownloadVC: UIViewController {

    var container: NSPersistentContainer {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func downloadButtonPressed(_ sender: Any) {
        let pdfURLString = "https://d3f4i5flr9o011.cloudfront.net/ramsschool-818YFC5S685L/ay2023-2024_165U70K95DDM/class7th-B_H72MSQ621Y51/books/pdf_file/1678273376396.pdf"
        if let pdfURL = URL(string: pdfURLString) {
            downloadAndSavePDF(pdfURL: pdfURL)
        }
    }
    
    @IBAction func viewButtonPressed(_ sender: Any) {
        displayPDF()
    }
    
    func downloadAndSavePDF(pdfURL: URL) {
        downloadPDF(from: pdfURL) { data in
            if let data = data {
                self.savePDFToCoreData(pdfData: data)
            }
        }
    }
    
    func downloadPDF(from url: URL, completion: @escaping (Data?) -> Void) {
        DispatchQueue.main.async {
            URLSession.shared.dataTask(with: url) { (data, response, error) in
                guard let data = data, error == nil else {
                    print("Error downloading PDF: \(error?.localizedDescription ?? "Unknown error")")
                    completion(nil)
                    return
                }
                completion(data)
            }.resume()
        }
    }
    
    func savePDFToCoreData(pdfData: Data) {
        let pdfEntity = NSEntityDescription.insertNewObject(forEntityName: "Student", into: container.viewContext) as! Student
        pdfEntity.pdfname = "DownloadedPDF2"
        pdfEntity.pdfurl = pdfData
        
        do {
            try container.viewContext.save()
            showDownloadNotification()
        } catch {
            print("Error saving PDF to Core Data: \(error.localizedDescription)")
        }
    }
    
    func displayPDF() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Student")
        
        do {
            let pdfDocuments = try context.fetch(fetchRequest) as? [Student]
            if let pdfDocument = pdfDocuments?.last, let pdfData = pdfDocument.pdfurl {
                let pdfView = PDFView(frame: view.bounds)
//                pdfView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                pdfView.document = PDFDocument(data: pdfData)
                view.addSubview(pdfView)
                
                // Add back button
                let backButton = UIButton(type: .system)
                backButton.setTitle("Back", for: .normal)
                
                
                backButton.frame = CGRect(x: 20, y: 20, width: 60, height: 30)
                backButton.addTarget(self, action: #selector(backButtonPressed), for: .touchUpInside)
                view.addSubview(backButton)
                
                // Add zoom in button
                let zoomInButton = UIButton(type: .system)
                zoomInButton.setTitle("Zoom In", for: .normal)
                zoomInButton.frame = CGRect(x: view.bounds.width - 80, y: 20, width: 80, height: 30)
                zoomInButton.addTarget(self, action: #selector(zoomInButtonPressed), for: .touchUpInside)
                view.addSubview(zoomInButton)
                
                // Add zoom out button
                let zoomOutButton = UIButton(type: .system)
                zoomOutButton.setTitle("Zoom Out", for: .normal)
                zoomOutButton.frame = CGRect(x: view.bounds.width - 160, y: 20, width: 80, height: 30)
                zoomOutButton.addTarget(self, action: #selector(zoomOutButtonPressed), for: .touchUpInside)
                view.addSubview(zoomOutButton)
            }
        } catch {
            print("Error fetching PDF documents from Core Data: \(error.localizedDescription)")
        }
    }

    @objc func backButtonPressed() {
            // Remove pdfView from its superview
            if let pdfView = view.subviews.compactMap({ $0 as? PDFView }).first {
                pdfView.removeFromSuperview()
            }
            // Go back to the previous screen
            navigationController?.popViewController(animated: true)
    }

    @objc func zoomInButtonPressed() {
        guard let pdfView = view.subviews.compactMap({ $0 as? PDFView }).first else {
            return
        }
        
        let scaleFactor: CGFloat = 1.2 // You can adjust the zoom factor as needed
        
        let newScale = min(pdfView.scaleFactor * scaleFactor, pdfView.maxScaleFactor)
        pdfView.scaleFactor = newScale
    }

    @objc func zoomOutButtonPressed() {
        guard let pdfView = view.subviews.compactMap({ $0 as? PDFView }).first else {
            return
        }
        
        let scaleFactor: CGFloat = 0.8 // You can adjust the zoom factor as needed
        
        let newScale = max(pdfView.scaleFactor * scaleFactor, pdfView.minScaleFactor)
        pdfView.scaleFactor = newScale
    }


    
    func showDownloadNotification() {
        let content = UNMutableNotificationContent()
        content.title = "PDF Downloaded"
        content.body = "The PDF document has been successfully downloaded."
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        
        let request = UNNotificationRequest(identifier: "DownloadNotification", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { (error) in
            if let error = error {
                print("Error displaying notification: \(error.localizedDescription)")
            }
        }
    }
}
