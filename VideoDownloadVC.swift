//MARK: - Xml
//<key>NSAppTransportSecurity</key>
//<dict>
//    <key>NSExceptionDomains</key>
//    <dict>
//        <key>commondatastorage.googleapis.com</key>
//        <dict>
//            <key>NSIncludesSubdomains</key>
//            <true/>
//            <!-- Optional: Add this key if needed -->
//            <key>NSExceptionAllowsInsecureHTTPLoads</key>
//            <true/>
//        </dict>
//    </dict>
//</dict>


import UIKit
import AVKit
import CoreData
import UserNotifications

class VideoDownloadVC: UIViewController {
   
    var container: NSPersistentContainer{
        let appdeledate = UIApplication.shared.delegate as! AppDelegate
        return appdeledate.persistentContainer
    }
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    @IBAction func downloaded(_ sender: Any) {
        // Replace "YourVideoURL" with the actual video URL
        let videoURLString = "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4"
        if let videoURL = URL(string: videoURLString) {
            downloadAndSaveVideo(videoURL: videoURL)
        }
    }
    @IBAction func play(_ sender: Any) {
        fetchAndPlayVideo()
    }
    
    func downloadAndSaveVideo(videoURL: URL) {
        downloadVideo(from: videoURL) { data in
            if let data = data {
                self.saveVideoToCoreData(videoData: data)
            }
        }
    }
//MARK: - saveVideoToCoreData
    func saveVideoToCoreData(videoData: Data) {
       
        let videoEntity = NSEntityDescription.insertNewObject(forEntityName: "Student", into: container.viewContext) as! Student

        videoEntity.name = "BigBuckBunny1"
        videoEntity.videoData = videoData

        do {
            try container.viewContext.save()
            showDownloadNotification()
        } catch {
            print("Error saving video to Core Data: \(error.localizedDescription)")
        }
    }
//MARK: - showDownloadNotification
    func showDownloadNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Video Downloaded"
        content.body = "The video has been successfully downloaded."

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false) // Display the notification after 1 second

        let request = UNNotificationRequest(identifier: "DownloadNotification", content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { (error) in
            if let error = error {
                print("Error displaying notification: \(error.localizedDescription)")
            }
        }
    }
//    MARK: - fetchAndPlayVideo
    func fetchAndPlayVideo() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }

        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<Student>(entityName: "Student")

        do {
            let students = try context.fetch(fetchRequest)
            
            if let student = students.last, let videoData = student.videoData {
                playVideo(with: videoData)
                print(videoData)
            }
        } catch {
            print("Error fetching videos from Core Data: \(error.localizedDescription)")
        }
    }
//MARK: - playVideo
    func playVideo(with data: Data) {
        do {
            // Save video data to a temporary file
            let tempURL = try saveVideoDataToTemporaryFile(data: data)

            // Create AVPlayer with the file URL
            let player = AVPlayer(url: tempURL)

            // Create AVPlayerViewController
            let playerViewController = AVPlayerViewController()
            playerViewController.player = player

            // Present the player view controller
            present(playerViewController, animated: true) {
                player.play()
            }
        } catch {
            print("Error playing video: \(error.localizedDescription)")
        }
    }
//MARK: - saveVideoDataToTemporaryFile
    func saveVideoDataToTemporaryFile(data: Data) throws -> URL {
        let temporaryDirectory = FileManager.default.temporaryDirectory
        let tempURL = temporaryDirectory.appendingPathComponent(UUID().uuidString).appendingPathExtension("mp4")

        do {
            try data.write(to: tempURL)
            return tempURL
        } catch {
            throw error
        }
    }
//MARK: - downloadVideo
    func downloadVideo(from url: URL, completion: @escaping (Data?) -> Void) {
        DispatchQueue.main.async {
            URLSession.shared.dataTask(with: url) { (data, response, error) in
                guard let data = data, error == nil else {
                    print("Error downloading video: \(error?.localizedDescription ?? "Unknown error")")
                    completion(nil)
                    return
                }
                completion(data)
            }.resume()
        }
    }
}
