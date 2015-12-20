import UIKit
import AVFoundation
import CoreData

class NoteTakerViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var notesArray: [Note] = []

    var audioPlayer = AVAudioPlayer()

    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.rowHeight = 65.0

        tableView.delegate = self
        tableView.dataSource = self
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)

        let context = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
        let request = NSFetchRequest(entityName: "Note")
        self.notesArray = (try! context.executeFetchRequest(request)) as! [Note]

        self.tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notesArray.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        let sound = notesArray[indexPath.row]
        let cell = UITableViewCell()
        cell.textLabel!.text = sound.name

        let font = UIFont(name: "BaskerVille-BoldItalic", size: 28)
        cell.textLabel?.font = font
        return cell
    }




    // A function that grabs any audio file path and creates the audio player

    func getAudioPlayerFile(file: String, type: String) -> AVAudioPlayer  {
        let path = NSBundle.mainBundle().pathForResource(file as String, ofType: type as String)
        let url = NSURL.fileURLWithPath(path!)
        var audioPlayer:AVAudioPlayer?

        do {
            try audioPlayer = AVAudioPlayer(contentsOfURL: url)
        } catch let audioPlayerError as NSError {
            print("Failed to initialize player error: \(audioPlayerError.localizedDescription)")
        }
        return audioPlayer!
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

        let sound = notesArray[indexPath.row]
        let baseString : String = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)[0] as String
        let pathComponents = [baseString, sound.url]
        let audioNSURL = NSURL.fileURLWithPathComponents(pathComponents)!
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(AVAudioSessionCategoryPlayback)
            self.audioPlayer = try AVAudioPlayer(contentsOfURL: audioNSURL)
        }  catch let fetchError as NSError {
            print("Fetch error: \(fetchError.localizedDescription)")
        }
        self.audioPlayer.play()
        tableView.deselectRowAtIndexPath(indexPath, animated: true)

        let section = indexPath.section
        let numberOfRows = tableView.numberOfRowsInSection(section)
        for row in 0..<numberOfRows {
            if let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: row, inSection: section)) {
                let image : UIImage = UIImage(named: "Check Mark2")!
                cell.imageView!.image = image
            }
        }
    }

    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        switch editingStyle {
        case .Delete:

            let appDel:AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            let context: NSManagedObjectContext = appDel.managedObjectContext
            context.deleteObject(notesArray[indexPath.row] as NSManagedObject)
            notesArray.removeAtIndex(indexPath.row)

            do {
                try context.save()

            } catch let deleteError as NSError {
                print("Delete error: \(deleteError.localizedDescription)")
            }
            self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade) 
        default:
            return
        }
    }
}
