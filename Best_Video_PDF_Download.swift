import UIKit
import AVKit
import PDFKit
class ViewController: UIViewController, URLSessionDownloadDelegate {
    

    
    // MARK: IBOutlets
    @IBOutlet weak var progressView: UIProgressView!
    
    // MARK: View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: IBActions
    @IBAction func startDownload(_ sender: Any) {
        guard let url = URL(string: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4") else { return }
        let urlSession = URLSession(configuration: .default, delegate: self, delegateQueue: OperationQueue())
        let downloadTask = urlSession.downloadTask(with: url)
        downloadTask.resume()
//VIDEO
//        File moved to: file:///var/mobile/Containers/Data/Application/F8F51FF4-05B0-4D15-829B-3E974B23CE5D/Documents/ForBiggerEscapes.mp4
//        File moved to: file:///var/mobile/Containers/Data/Application/0F7AFC7E-2225-470C-AB1A-B37A00FF080D/Documents/ElephantsDream.mp4
//        let videoURL = getVideoURL(fileName: "ForBiggerEscapes.mp4")
//                playVideo(at: videoURL)

//        PDF
//        File moved to: file:///var/mobile/Containers/Data/Application/921D8082-E609-4969-BD42-103FF3C69F37/Documents/TestPDFfile.pdf
        //        let pdfURL = getVideoURL(fileName: "TestPDFfile.pdf")
        //               PDFViewer(at: pdfURL)
    }
    func getVideoURL(fileName: String) -> URL {
         return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(fileName)
     }
    
    func PDFViewer(at filePath: URL) {
         do {
             let pdfData = try Data(contentsOf: filePath)
             let pdfView = PDFView(frame: view.bounds)
             pdfView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
             pdfView.document = PDFDocument(data: pdfData)
             view.addSubview(pdfView)
             
         } catch {
             print("Error loading PDF file: \(error.localizedDescription)")
         }
     }
    
    
    func playVideo(at filePath: URL) {
           let player = AVPlayer(url: filePath)
           let playerViewController = AVPlayerViewController()
           playerViewController.player = player
           present(playerViewController, animated: true) {
               player.play()
           }
       }
    
    // MARK: URLSessionDownloadDelegate
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        // Move the downloaded file from temporary location to the desired location
        guard let url = downloadTask.originalRequest?.url else { return }
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        
        let destinationURL = documentsDirectory.appendingPathComponent(url.lastPathComponent)
        try? FileManager.default.moveItem(at: location, to: destinationURL)
        print("File moved to: \(destinationURL)")
        // Play the video
        DispatchQueue.main.async {
            let player = AVPlayer(url: destinationURL)
            let playerViewController = AVPlayerViewController()
            playerViewController.player = player
            self.present(playerViewController, animated: true) {
                player.play()
            }
        }
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        let progress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
        DispatchQueue.main.async {
            self.progressView.progress = progress
        }
    }
}
