import UIKit

class DuetPatternViewController: UIViewController, UITextFieldDelegate, UIViewControllerId, ChromaColorPickerDelegate {
    @IBOutlet weak var mainStackView: UIStackView!
    var textFieldDict = [Int : UITextField]()
    var sliderDict = [Int : UISlider]()
    var textFieldInputCancelled = false
    var color1 : Bool = true
    
    @IBOutlet weak var button1: UIButton!
    @IBOutlet weak var button2: UIButton!
    
    var colorPicker: ChromaColorPicker!
    
    var connect: ChirpConnect?
    var id: Int = 0
    
    @IBAction func onButton1Click(_ sender: UIButton) {
        colorPicker.adjustToColor(sender.backgroundColor!)
        color1 = true
    }
    
    @IBAction func onButton2Click(_ sender: UIButton) {
        colorPicker.adjustToColor(sender.backgroundColor!)
        color1 = false
    }
    
    @IBAction func sendButton(_ sender: UIBarButtonItem) {
        var data = Data()
        data.append(UInt8(id))
        for slider in sliders{
            data.append(UInt8(slider.value))
        }
        
        var fRed : CGFloat = 0
        var fGreen : CGFloat = 0
        var fBlue : CGFloat = 0
        var fAlpha: CGFloat = 0
        
        button1.backgroundColor?.getRed(&fRed, green: &fGreen, blue: &fBlue, alpha: &fAlpha)
        data.append(UInt8(fRed * 255.0))
        data.append(UInt8(fGreen * 255.0))
        data.append(UInt8(fBlue * 255.0))
        
        button2.backgroundColor?.getRed(&fRed, green: &fGreen, blue: &fBlue, alpha: &fAlpha)
        data.append(UInt8(fRed * 255.0))
        data.append(UInt8(fGreen * 255.0))
        data.append(UInt8(fBlue * 255.0))
        
        connect?.send(data)
    }
    
    @IBOutlet var fields: [UITextField]!
        {
        didSet {
            for field in fields {
                field.addDoneCancelToolbar(tag: field.tag,
                                           onDone: (target: self, action: #selector(doneButtonTapped)),
                                           onCancel :(target: self, action: #selector(cancelButtonTapped)))
                field.delegate = self
            }
        }
    }
    
    @IBOutlet var sliders: [UISlider]!
    
    @IBAction func SliderChange(_ sender: UISlider) {
        let tag: Int = sender.tag
        let field: UITextField = fields[tag]
        field.text = String(Int(sender.value))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if sliders.count != fields.count {
            return
        }
        
        // Ensure the tag are synchronized and ordered
        for index in 0..<sliders.count {
            sliders[index].tag = index
            fields[index].tag = index
        }
        
        // Get the connect instance
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        connect = appDelegate.connect
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if sliders.count != fields.count {
            let alertController = UIAlertController(title: "Alert", message: "Slider list size different than field list size.", preferredStyle: .alert)
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    override func viewDidLayoutSubviews() {
        if (colorPicker == nil) {
            loadColorPicker()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func doneButtonTapped(sender: UIBarButtonItem)
    {
        let tag: Int = sender.tag
        let field: UITextField = fields[tag]
        let slider : UISlider = sliders[tag]
        slider.value = Float(Int(field.text!)!)
        if slider.value == slider.maximumValue {
            field.text = String(Int(slider.maximumValue))
        }
        field.resignFirstResponder()
    }
    
    @objc func cancelButtonTapped(sender: UIBarButtonItem)
    {
        let tag: Int = sender.tag
        let field: UITextField = fields[tag]
        let slider: UISlider = sliders[tag]
        field.text = String(Int(slider.value))
        textFieldInputCancelled = true
        field.resignFirstResponder()
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if !textFieldInputCancelled {
            let tag: Int = textField.tag
            let slider: UISlider = sliders[tag]
            slider.value = Float(textField.text!)!
            textFieldInputCancelled = false
        }
    }
    
    func loadColorPicker() {
        var margin : CGFloat = 0
        
        for c in view.constraints {
            if (c.firstItem as? UIStackView == mainStackView && c.secondAttribute == .leading)
            {
                margin  = c.constant
                break
            }
        }
        
        let areaWidth = self.view.bounds.width - 2 * margin
        let areaHeight =  self.view.frame.maxY - (self.mainStackView.frame.maxY + self.mainStackView.spacing) - margin
        
        let areaSize = min(areaWidth, areaHeight)
        
        let pickerX = self.view.frame.midX - areaSize / 2
        let pickerY = self.mainStackView.frame.maxY + margin

        /* Calculate relative size and origin in bounds */
        let pickerSize = CGSize(width: areaSize,
                                height: areaSize)
        
        let pickerOrigin = CGPoint(x: pickerX,
                                   y: pickerY)
        
        /* Create Color Picker */
        colorPicker = ChromaColorPicker(frame: CGRect(origin: pickerOrigin, size: pickerSize))
        colorPicker.delegate = self
        
        /* Customize the view (optional) */
        colorPicker.padding = 0
        colorPicker.stroke = 5 //stroke of the rainbow circle
        colorPicker.currentAngle = Float.pi
        
        /* Customize for grayscale (optional) */
        //colorPicker.supportsShadesOfGray = true // false by default
        //colorPicker.colorToggleButton.grayColorGradientLayer.colors = [UIColor.lightGray.cgColor, UIColor.gray.cgColor] // You can also override gradient colors
        
        
        colorPicker.hexLabel.textColor = UIColor.black
        
        /* Don't want an element like the shade slider? Just hide it: */
        //colorPicker.shadeSlider.hidden = true
        
        self.view.addSubview(colorPicker)
    }
    
    func colorPickerDidChooseColor(_ colorPicker: ChromaColorPicker, color: UIColor) {
        if color1 {
            button1.backgroundColor = color
            color1 = false
        }
        else {
            button2.backgroundColor = color
            color1 = true
        }
    }
}
