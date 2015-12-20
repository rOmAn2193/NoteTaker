import UIKit
import AVFoundation
import CoreData

class NewNoteViewController: UIViewController {

    required init?(coder aDecoder: NSCoder) {

        let baseString : String = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)[0] as String   //1
        self.audioURL = NSUUID().UUIDString + ".m4a"
        let pathComponents = [baseString, self.audioURL]
        let audioNSURL = NSURL.fileURLWithPathComponents(pathComponents)!
        let session = AVAudioSession.sharedInstance()

        let recordSettings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000.0,
            AVNumberOfChannelsKey: 2 as NSNumber,
            AVEncoderAudioQualityKey: AVAudioQuality.High.rawValue]

        do {
            try session.setCategory(AVAudioSessionCategoryPlayAndRecord)
            self.audioRecorder = try AVAudioRecorder(URL: audioNSURL, settings: recordSettings)
        } catch let initError as NSError {
            print("Initialization error: \(initError.localizedDescription)")
        }

        self.audioRecorder.meteringEnabled = true
        self.audioRecorder.prepareToRecord()

        super.init(coder: aDecoder)
    }

    @IBOutlet weak var noteTextField: UITextField!
    @IBOutlet weak var recordOutlet: UIButton!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var peakImageView: UIImageView!
    @IBOutlet weak var averageImageView: UIImageView!


    var audioRecorder: AVAudioRecorder!
    var audioURL: String
    var audioPlayer = AVAudioPlayer()

    let timeInterval: NSTimeInterval = 0.5

    override func viewDidLoad() {
        super.viewDidLoad()

        recordOutlet.layer.shadowOpacity = 1.0
        recordOutlet.layer.shadowOffset = CGSize(width: 5.0, height: 4.0)
        recordOutlet.layer.shadowRadius = 5.0
        recordOutlet.layer.shadowColor = UIColor.blackColor().CGColor
    }


    @IBAction func cancel(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func save(sender: AnyObject) {

        if noteTextField.text != "" {
            let context = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
            let note = NSEntityDescription.insertNewObjectForEntityForName("Note", inManagedObjectContext: context) as! Note
            note.name = noteTextField.text!
            note.url = audioURL

            do {
                try context.save()
            } catch let saveError as NSError {
                print("Saving error: \(saveError.localizedDescription)")
            }
        }
        self.dismissViewControllerAnimated(true, completion: nil)  

    }

    @IBAction func record(sender: AnyObject) {

        let mic = UIImage(named: "pinkbuttonRecord.png") as UIImage!
        recordOutlet.setImage(mic, forState: .Normal)

        recordOutlet.layer.shadowOpacity = 0.9
        recordOutlet.layer.shadowOffset = CGSize(width: 3.0, height: 2.0)
        recordOutlet.layer.shadowRadius = 5.0
        recordOutlet.layer.shadowColor = UIColor.blackColor().CGColor

        if audioRecorder.recording {
            audioRecorder.stop()

            let mic = UIImage(named: "whitebuttonNormal.png") as UIImage!
            recordOutlet.setImage(mic, forState: .Normal)

        } else {
            let session = AVAudioSession.sharedInstance()

            do {
                try session.setActive(true)
                audioRecorder.record()
            } catch let recordError as NSError {
                print("Recording error: \(recordError.localizedDescription)")
            }
        }
    }


    @IBAction func touchDownRecord(sender: AnyObject) {

        audioPlayer = getAudioPlayerFile("startRecordSound", type: "m4a")
        audioPlayer.play()

        let timer = NSTimer.scheduledTimerWithTimeInterval(timeInterval, target: self,
            selector: "updateAudioMeter:",
            userInfo: nil,
            repeats: true)
        timer.fire()

        recordOutlet.layer.shadowOpacity = 0.9
        recordOutlet.layer.shadowOffset = CGSize(width: -2.0, height: -2.0)
        recordOutlet.layer.shadowRadius = 1.0
        recordOutlet.layer.shadowColor = UIColor.blackColor().CGColor

    }

    // A function to update the meters and to update the label to

    func updateAudioMeter(timer: NSTimer){
        if audioRecorder.recording {

            let dFormat = "%02d"
            let min:Int = Int(audioRecorder.currentTime / 60)
            let sec:Int = Int(audioRecorder.currentTime % 60)
            let timeString = "\(String(format: dFormat, min)):\(String(format: dFormat, sec))"
            timeLabel.text = timeString
            audioRecorder.updateMeters()
            let averageAudio = audioRecorder.averagePowerForChannel(0) * -1
            let peakAudio = audioRecorder.peakPowerForChannel(0) * -1
            let progressView1Average = Int(averageAudio)    //   / 100.0  divide if using a float
            let progressView2Peak = Int(peakAudio) //   / 100.0  divide if using a float

            averageRadial(progressView1Average, peak: progressView2Peak)

        } else if !audioRecorder.recording {

            averageImageView.image = UIImage(named: "average0radial.png")
            peakImageView.image = UIImage(named: "peak0radial.png")
            crossfadeTransition()
        }
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

    func averageRadial (average: Int, peak: Int) {

        switch average {
        case average: averageImageView.image = UIImage(named: "average\(String(average))radial")
        crossfadeTransition()

        default: averageImageView.image = UIImage(named: "average10radial.png")
        crossfadeTransition()
        }

        switch peak {
        case peak:
            peakImageView.image = UIImage(named: "peak\(String(peak))radial")
            crossfadeTransition()

        default: peakImageView.image = UIImage(named: "peak10radial.png")
        crossfadeTransition()
        }
        
    }
    
    func crossfadeTransition() {
        let transition = CATransition()
        transition.type = kCATransitionFade
        transition.duration = 0.2
        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        view.layer.addAnimation(transition, forKey: nil)
    }
    
}