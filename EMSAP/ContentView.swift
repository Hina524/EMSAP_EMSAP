import SwiftUI
import Combine
import CoreMotion
import CoreLocation
import UIKit

// UUID
let uniqueIdString = UIDevice.current.identifierForVendor!.uuidString
let uuid = UUID().uuidString

var latitudeNow: String = "0.0"
var longitudeNow: String = "0.0"
var currentElevation : Double = 0.0
// 国土地理院URL
let baseUrl = "https://cyberjapandata2.gsi.go.jp/general/dem/scripts/getelevation.php?"
var lonUrl: String = ""
var latUrl: String = ""
// アウトプット形式をJSONに設定する
let outtypeUrl = "&outtype=JSON"
// 国土地理院URL連結
var listUrl: String = ""
//Googlespreadsheetデータ格納先URL連結時のURL
var postdataUrl: String = ""

//アプリ使用端末判定(IOS)
let device = UIDevice.current
private let DeviceList = [
    /* -------------- iPod Touch -------------- */
    /* iPod Touch 5 */    "iPod5,1": "iPod-Touch5",
    /* iPod Touch 6 */    "iPod7,1": "iPod-Touch6",

    /* -------------- iPhone -------------- */
    /* iPhone 4 */        "iPhone3,1": "iPhone4", "iPhone3,2": "iPhone4", "iPhone3,3": "iPhone4",
    /* iPhone 4S */       "iPhone4,1": "iPhone4S",
    /* iPhone 5 */        "iPhone5,1": "iPhone5", "iPhone5,2": "iPhone5",
    /* iPhone 5C */       "iPhone5,3": "iPhone5C", "iPhone5,4": "iPhone5C",
    /* iPhone 5S */       "iPhone6,1": "iPhone5S", "iPhone6,2": "iPhone5S",
    /* iPhone 6 */        "iPhone7,2": "iPhone6",
    /* iPhone 6 Plus */   "iPhone7,1": "iPhone6-Plus",
    /* iPhone 6S */       "iPhone8,1": "iPhone6S",
    /* iPhone 6S Plus */  "iPhone8,2": "iPhone6S-Plus",
    /* iPhone SE */       "iPhone8,4": "iPhoneSE",
    /* iPhone 7 */        "iPhone9,1": "iPhone7", "iPhone9,3": "iPhone 7",
    /* iPhone 7 Plus */   "iPhone9,2": "iPhone7-Plus", "iPhone9,4": "iPhone7-Plus",
    /* iPhone 8 */        "iPhone10,1": "iPhone8", "iPhone10,4": "iPhone 8",
    /* iPhone 8 Plus */   "iPhone10,2": "iPhone8-Plus", "iPhone10,5": "iPhone8-Plus",
    /* iPhone X */        "iPhone10,3 ": "iPhoneX", "iPhone10,6": "iPhoneX",
    /* iPhone XR */       "iPhone11,8": "iPhoneXR",
    /* iPhone XS */       "iPhone11,2": "iPhoneXS",
    /* iPhone XS Max */   "iPhone11,6": "iPhoneXS Max",
    /* iPhone 11 */       "iPhone12,1": "iPhone11",
    /* iPhone 11 Pro */   "iPhone12,3": "iPhone11-Pro", "iPhone12,5": "iPhone11-ProMax",
    /* iPhone SE 2nd Generation */ "iPhone12,8": "iPhoneSE-2ndGeneration",
    /* iPhone 12 mini */  "iPhone13,1": "iPhone12-mini",
    /* iPhone 12*/        "iPhone13,2": "iPhone12",
    /* iPhone 12 Pro */   "iPhone13,3": "iPhone12-Pro", "iPhone13,4": "iPhone12-ProMax",
/* iPhone 13 mini*/       "iPhone14,4": "iPhone13-mini",
    /* iPhone 13 */       "iPhone14,5": "iPhone13",
    /* iPhone 13 Pro */   "iPhone14,2": "iPhone13-Pro", "iPhone14,3": "iPhone13-ProMax",

    /* -------------- iPad -------------- */
    /* iPad 2 */          "iPad2,1": "iPad2", "iPad2,2": "iPad2", "iPad2,3": "iPad2", "iPad2,4": "iPad2",
    /* iPad 3 */          "iPad3,1": "iPad3", "iPad3,2": "iPad3", "iPad3,3": "iPad3",
    /* iPad 4 */          "iPad3,4": "iPad4", "iPad3,5": "iPad4", "iPad3,6": "iPad4",
    /* iPad Air */        "iPad4,1": "iPad-Air", "iPad4,2": "iPad-Air", "iPad4,3": "iPad-Air",
    /* iPad Air 2 */      "iPad5,3": "iPad-Air2", "iPad5,4": "iPad-Air 2",
    /* iPad Mini */       "iPad2,5": "iPad-Mini", "iPad2,6": "iPad-Mini", "iPad2,7": "iPad-Mini",
    /* iPad Mini 2 */     "iPad4,4": "iPad-Mini2", "iPad4,5": "iPad-Mini2", "iPad4,6": "iPad-Mini2",
    /* iPad Mini 3 */     "iPad4,7": "iPad-Mini3", "iPad4,8": "iPad-Mini3", "iPad4,9": "iPad-Mini3",
    /* iPad Mini 4 */     "iPad5,1": "iPad-Mini4", "iPad5,2": "iPad-Mini4",
    /* iPad Pro(12.9) */  "iPad6,7": "iPad Pro", "iPad6,8": "iPad-Pro",
    /* iPad Pro (9.7) */  "iPad6,3": "iPad Pro (9.7)", "iPad6,4": "iPad-Pro(9.7)",
    /* iPad (5th) */      "iPad6,11": "iPad (5th)",  "iPad6,12": "iPad(5th)",
    /* iPad Pro2 (12.9) */ "iPad7,1": "iPad-Pro2(12.9)",
    /* iPad Pro (10.5) */  "iPad7,2": "iPad-Pro2 (10.5)", "iPad7,3": "iPad-Pro(10.5)",
    /* iPad (6th) */       "iPad7,4": "iPad(6th)", "iPad7,5": "iPad(6th)",
    /* iPad (7th) */       "iPad7,6": "iPad(6th)", "iPad7,11": "iPad(7th)",
    /* iPad Pro(11) */     "iPad7,12": "iPad-Pro(11)", "iPad8,1": "iPad-Pro(11)", "iPad8,2":"iPad-Pro(11)", "iPad8,3": "iPad-Pro(11)",
    /* iPad Pro(12.9)(3rd)*/ "iPad8,4": "iPad-Pro(12.9)(3rd)", "iPad8,5": "iPad-Pro(12.9)(3rd)", "iPad8,6": "iPad-Pro(12.9)(3rd)", "iPad8,7": "iPad-Pro(12.9)(3rd)",
    /* iPad Pro(11)(2th)*/ "iPad8,8": "iPad-Pro(11)(2th)", "iPad8,9": "iPad-Pro(11)(2th)",
    /* iPad Pro(12.9)(4th)*/ "iPad8,10": "iPad-Pro(12.9)(4th)", "iPad8,11": "iPad-Pro(12.9)(2th)",
    /* iPad mini(5th) */   "iPad8,12": "iPad-mini(5th)", "iPad11,1": "iPad-mini(5th)",
    /* iPad Air(3rd) */    "iPad11,2": "iPad-Air(3rd)", "iPad11,3": "iPad-Air(3rd)",
    /* iPad (8th) */       "iPad11,4": "iPad(8th)", "iPad11,6": "iPad(8th)",
    /* iPad Air(4th) */    "iPad11,7": "iPad-Air(4th)", "iPad13,1": "iPad-Air(4th)",
    /* iPad Pro(11)(3rd) */"iPad13,2": "iPad-Pro(11)(3rd)", "iPad13,4": "iPad-Pro(11)(3rd)", "iPad13,5": "iPad-Pro(11)(3rd)", "iPad13,6": "iPad-Pro(11)(3rd)",
    /* iPad Pro(12.9)(5th)*/"iPad13,7": "iPad-Pro(12.9)(5th)", "iPad13,8": "iPad-Pro(12.9)(5th)", "iPad13,9": "iPad-Pro(12.9)(5th)", "iPad13,10": "iPad-Pro(12.9)(5th)", "iPad13,11": "iPad-Pro(12.9)(5th)",
    /* Simulator */       "x86_64": "Simulator", "i386": "Simulator",
]

extension UIDevice {

    var platform: String {
        var systemInfo = utsname()
        uname(&systemInfo)

        let mirror = Mirror(reflecting: systemInfo.machine)
        var identifier = ""

        for child in mirror.children {
            if let value = child.value as? Int8, value != 0 {
                identifier.append(UnicodeScalar(UInt8(bitPattern: value)).description)
            }
        }
        return identifier
    }

    var modelName: String {
        let identifier = platform
        return DeviceList[identifier] ?? identifier
    }
}

//位置情報測定
class LocationObserver: NSObject, ObservableObject, CLLocationManagerDelegate {
    
  @Published private(set) var location = CLLocation()
  
  private let locationManager: CLLocationManager
  
  override init() {
    self.locationManager = CLLocationManager()
    
    super.init()
    
    self.locationManager.delegate = self
    self.locationManager.requestAlwaysAuthorization()
    self.locationManager.startUpdatingLocation()
    // バックグラウンドでの位置情報更新を許可
    self.locationManager.allowsBackgroundLocationUpdates = true
  }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last!
        let latitude = location.coordinate.latitude
        let longitude = location.coordinate.longitude
        // 位置情報を格納する
        latitudeNow = String(latitude)
        longitudeNow = String(longitude)
        // 現在位置でクエリを設定する
        latUrl = "&lat=" + latitudeNow.description
        lonUrl = "&lon=" + longitudeNow.description
        listUrl = baseUrl + lonUrl + latUrl + outtypeUrl
        
        guard let url = URL(string: listUrl) else { return }
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if error != nil {
                print("json convert failed in JSONDecoder." + error!.localizedDescription)
            }
            guard let data = data else { return }
            // JSONを取得する
            let json = try? JSONDecoder().decode(JsonElevation.self, from: data)
            if nil != json {
                // mainスレッドで処理する
                DispatchQueue.main.async {
                    // JSONから標高を取得する
                    currentElevation = (json?.elevation)!
                }}
            }.resume()
        
        //print(currentElevation)
        //print(location.coordinate)
    }
}

struct JsonElevation: Hashable, Codable{
   var elevation: Double
   var hsrc: String
}


//気圧測定・データ送信関連
class AltimatorManager: NSObject, ObservableObject, URLSessionDelegate {
    let willChange = PassthroughSubject<Void, Never>()

    var altimeter:CMAltimeter?

    @Published var pressureString:String = ""
    // @Published var altitudeString:String = ""
    @Published var groundpressureString:String = ""
    @Published var pressureString2:String = ""
    @Published var groundpressureString2:String = ""
    
    
    override init() {
        super.init()
        altimeter = CMAltimeter()
        startUpdate()
        time()
    }
    
    func startUpdate() {
        if(CMAltimeter.isRelativeAltitudeAvailable()) {
            altimeter!.startRelativeAltitudeUpdates(to: OperationQueue.main, withHandler:
                {data, error in
                    if error == nil {
                        let pressure:Double = data!.pressure.doubleValue
                        //let altitude:Double = data!.relativeAltitude.doubleValue
                        let elevation:Double = currentElevation
                        self.pressureString = String(format: "%.16f", pressure * 10)
                        self.pressureString2 = String(format: "%.4f", pressure * 10)
                        //)self.altitudeString = String(format: "%.2f m",altitude)
                        self.groundpressureString = String(format: "%.16f", (elevation/10)*1.176+(pressure*10))
                        self.groundpressureString2 = String(format: "%.4f", (elevation/10)*1.176+(pressure*10))
                        
                        //self.pressureString2 = String(format: "%.2f", pressure * 10)
                        //self.groundpressureString2 = String(format: "%.2f", (elevation/10)*1.26714+(pressure*10))
                        
                        // self.willChange.send()
                        //print("\(Date()),\(latitudeNow),\(longitudeNow),\(currentElevation),\(self.pressureString),\(self.groundpressureString)")
                        self.makepostUrl()
                    }
            })
        }
    }
    
    
    func makepostUrl(){
        //Googlespreadsheetデータ格納先URL材料
        let postbaseUrl = "https://script.google.com/macros/s/AKfycbzZRNokUDLALR2KeaiZ4OUf5ZHKS8jGXilHe8mXocMdTgUEf84bRsfbZt3EsaaRL51Byg/exec?"
        let idUrl = "dataid=" +  uuid
        let id2Url = "&deviceid=" + uniqueIdString
        var londataUrl: String = ""
        var latdataUrl: String = ""
        var elevationUrl: String = ""
        var locationdataUrl: String = ""
        var pressureUrl: String = ""
        var groundpressureUrl: String = ""
        var pressuredataUrl: String = ""
        var modelUrl: String = ""
        
        //dateUrl = "date=" + date
        londataUrl = "&longitude=" + longitudeNow
        latdataUrl = "&latitude=" + latitudeNow
        elevationUrl = "&elevation=" + String(currentElevation)
        pressureUrl = "&pressure=" + self.pressureString
        groundpressureUrl = "&groundpressure=" + self.groundpressureString
        locationdataUrl = londataUrl + latdataUrl + elevationUrl
        pressuredataUrl = pressureUrl + groundpressureUrl
        modelUrl = "&model=" + device.modelName.description
        
        postdataUrl = postbaseUrl + idUrl + locationdataUrl + pressuredataUrl + modelUrl + id2Url + outtypeUrl
        //print(postdataUrl)
        //print(device.modelName)
    }
    
    
    
    func time(){
        Timer.scheduledTimer(timeInterval: 60.0, target: self, selector: #selector(self.posting), userInfo: nil, repeats: true)
    }
    
    @objc func posting(){
        URLSession.shared.dataTask(with: URL(string: postdataUrl)!) { data, response, error in
            guard let d = data, let s = String(data: d, encoding: .utf8) else { return }
            print(s)
        }.resume()
    }
}


struct ContentView: View {
    @ObservedObject var manager = AltimatorManager()
    @ObservedObject var locationObserver = LocationObserver()
    @State private var showAlert = false
    @State private var showAlert2 = false
    //@ObservedObject var getele = LocationElevation()
    
    let availabe = CMAltimeter.isRelativeAltitudeAvailable()
    var body: some View {
        VStack(spacing: 30) {
            VStack(spacing: 10) {
                Text("【現地気圧(hPa)】")
                Text(availabe ? manager.pressureString2 : "----")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                Text("【海面気圧(hPa)】")
                Text(availabe ? manager.groundpressureString2 : "----")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                //Text("【相対高度】")
                //Text(availabe ? manager.altitudeString : "----")
                Text("【緯度,経度】")
                Text("\(latitudeNow), \(longitudeNow)")
                    .font(.title)
                    .fontWeight(.bold)
                Text("【標高】")
                Text("\(currentElevation)"+"m")
                    .font(.title)
                    .fontWeight(.bold)
                Text("【データID】")
                Text(uuid)
                //Text(uniqueIdString)
            }
                
                
            Button(action: {
                self.showAlert2.toggle()
            }) {
                Text("データを保存する（要Googleアカウント）")
                    .fontWeight(.bold)
            }
            .alert(isPresented: $showAlert2) {
                Alert(
                    title: Text("データ保存にはGoogleアカウントが必要です"),
                    message: Text("「OK」を押すとブラウザページに移動します。この先データを保存・閲覧するにはGoogleアカウントが必要です。画面の指示に従ってログインし、途中で許可を求められた場合は「許可」してください。（途中、「安全ではないページです」と警告が出た場合は、画面中の「詳細」をクリックし、「アクセスする」をクリックしてください。）なお気圧測定はバックグラウンドでも継続され、完全にアプリを終了するまで測定されます。"),
                    primaryButton: .default(Text("OK"), action: {
                    if let url = URL(string:"https://script.google.com/macros/s/AKfycbxcj6Nl81nT7XaMacgrsOJGTS4-aHRv71IBZyZwEBNr81ZKLWVInIIg__NG2zNIatXA/exec?" + "dataid=" + uuid) {
                        UIApplication.shared.open(url)
                        print(url)
                    }
                    }),
                    secondaryButton: .destructive(Text("キャンセル"))
                )
            }
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
