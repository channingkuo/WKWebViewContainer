//
//  ViewController.swift
//  WKWebViewContainer
//
//  Created by Channing Kuo on 2020/10/15.
//

import UIKit
import WebKit
import SwiftyJSON
import CoreLocation

class ViewController: UIViewController, UINavigationControllerDelegate {
    
    @IBOutlet weak var progressView: ProgressView!
    @IBOutlet weak var kWKWebView: KWKWebView!
    
    fileprivate var statusView: UIView!
    
    fileprivate var downloadingView: ProgressBar!
    fileprivate var downloadingViewPresented: Bool = false
    
    // iOS13.0以上专有的WKWebView与js回调
    fileprivate var replyHandler: ((Any?, String?) -> Void)?
    
    // TODO 设计一个Class保存请求的所有记录
    fileprivate var snapShotsArray: Array<Any>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        downloadingView = ProgressBar(progress: 0.0)
        
        self.navigationController?.navigationBar.isHidden = true
        
        let statusBarFrame: CGRect?
        if #available(iOS 13, *) {
            statusBarFrame = UIApplication.shared.windows.first?.windowScene?.statusBarManager?.statusBarFrame
        } else {
            statusBarFrame = UIApplication.shared.statusBarFrame
        }
        statusView = UIView(frame: statusBarFrame!)
        self.view.addSubview(statusView)
        
        kWKWebView.webConfig = KWKWebViewConfig()
        kWKWebView.delegate = self
        kWKWebView.progressDelegate = self
        kWKWebView.load(self, .HTML(fileName: nil))
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(viewDismissNotification), name: NSNotification.Name(rawValue: "viewDismiss"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(htmlVersionUpdateProgress), name: NSNotification.Name(rawValue: "htmlVersionUpdateProgress"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(htmlVersionUpdated), name: NSNotification.Name(rawValue: "htmlVersionUpdated"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(htmlVersionUpdateFailed), name: NSNotification.Name(rawValue: "htmlVersionUpdateFailed"), object: nil)
        
        DispatchQueue.global().async() {
            WwwUtils.checkHtmlVersion()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @objc func viewDismissNotification() {
        kWKWebView.reload()
    }
    
    @objc func htmlVersionUpdateProgress(_ notification: NSNotification) {
        let progress = notification.object as! Double
        #if DEBUG
        print("Download Progress: \(progress)")
        #endif
        
        downloadingView.setProgress(Float(progress), animation: true)

        if !downloadingViewPresented {
            self.present(downloadingView.bar, animated: true, completion: nil)

            downloadingViewPresented = true
        }
    }
    
    @objc func htmlVersionUpdated() {
        let alert = UIAlertController(title: "温馨提示", message: "新版本已更新，是否加载", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确定", style: .default, handler: { (_) -> Void in
            self.dismiss(animated: true, completion: nil)
            
            self.kWKWebView.reload()
        }))
        alert.addAction(UIAlertAction(title: "取消", style: .cancel) { (_) -> Void in
            self.dismiss(animated: true, completion: nil)
        })
        downloadingView.bar.present(alert, animated: true, completion: nil)
    }
    
    @objc func htmlVersionUpdateFailed() {
        let alert = UIAlertController(title: "检查版本更新异常", message: "", preferredStyle: .alert)
        self.present(alert, animated: true, completion: nil)

        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.dismiss(animated: true, completion: nil)
        }
    }
}

// MARK: - ProgressDelegate
extension ViewController: ProgressDelegate {
    
    func estimatedProgress(_ webView: WKWebView, estimatedProgress progress: Double) {
        if progress >= 1.0 && progressView != nil {
            // TODO 从HTML读取状态栏的颜色
            statusView.backgroundColor = UIColor(red: 236 / 255, green: 128 / 255, blue: 13 / 255, alpha: 1)
            // 延迟1秒移除——为了遮挡HTML加载瞬间的"白屏"
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.progressView.removeFromSuperview()
            }
        }
    }
}

// MARK: - WKWebViewDelegate
extension ViewController: WKWebViewDelegate {
    
    /// 服务器开始请求的时候调用——桥接html请求变化链接
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        decisionHandler(.allow)
//        let navigationURL = navigationAction.request.url?.absoluteString
//        if let requestURL = navigationURL?.removingPercentEncoding {
//            //拨打电话
//            //兼容安卓的服务器写法:<a class = "mobile" href = "tel://电话号码"></a>
//            //或者:<a class = "mobile" href = "tel:电话号码"></a>
//            if requestURL.hasPrefix("tel://") {
//                //取消WKWebView 打电话请求
//                decisionHandler(.cancel);
//                //用openURL 这个API打电话
//                if let mobileURL:URL = URL(string: requestURL) {
//                    UIApplication.shared.openURL(mobileURL)
//                }
//            }
//            // 支付宝支付
//            if requestURL.hasPrefix("alipay://") {
//
//                var urlString = requestURL.mySubString(from: 23)
//                urlString = urlString.replacingOccurrences(of: "alipays", with: webConfig!.aliPayScheme)
//
//                if let strEncoding = urlString.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) {
//
//                    let payString = "alipay://alipayclient/?\(strEncoding)"
//
//                    if let urlalipayURL:URL = URL(string: payString) {
//                        if #available(iOS 10.0, *) {
//                            UIApplication.shared.open(urlalipayURL, options: [:], completionHandler: { result in
//                                self.webView.reload()
//                            })
//                        } else {
//                            UIApplication.shared.openURL(urlalipayURL)
//                        }
//                    }
//                }
//            }
//        }
//        switch navigationAction.navigationType {
//        case WKNavigationType.linkActivated:
//            pushCurrentSnapshotView(navigationAction.request as NSURLRequest)
//            break
//        case WKNavigationType.formSubmitted:
//            pushCurrentSnapshotView(navigationAction.request as NSURLRequest)
//            break
//        case WKNavigationType.backForward:
//            break
//        case WKNavigationType.reload:
//            break
//        case WKNavigationType.formResubmitted:
//            break
//        case WKNavigationType.other:
//            pushCurrentSnapshotView(navigationAction.request as NSURLRequest)
//            break
//        }
//        decisionHandler(.allow)
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        #if DEBUG
        print("开始加载")
        #endif
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        #if DEBUG
        print("加载完成!")
        #endif
        
        let js = """
            return localStorage['userInfo'];
        """
        if #available(iOS 14.0, *) {
            kWKWebView.callAsyncJavaScript(javaScript: js) {
                result in
                switch result {
                case .success(let resp):
                    let userInfo = JSON(parseJSON: resp as? String ?? "")
                    print(userInfo["token"].stringValue)
                    break
                case .failure(_):
                    // TODO 拿不到token信息，看情况需不需要跳到登录页面
                    break
                }
            }
        } else {
            // TODO 获取web localStorage中token信息
            kWKWebView.excuteJavaScript(javaScript: js)
        }
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        #if DEBUG
        print("加载失败!")
        #endif
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        #if DEBUG
        print(error)
        #endif
    }
    
    func webViewUserContentController(_ scriptMessageHandlerArray: [String], didReceive message: WKScriptMessage) {
        #if DEBUG
        print("JS 执行 Swift 代码")
        print(message.body)
        #endif
        scriptMessageHandle(didReceive: JSON(message.body)["body"])
    }
    
    func webViewEvaluateJavaScript(_ result: Any?, error: Error?) {
        #if DEBUG
        print("Swift 执行 JS 到 WKWebview")
        print(result as Any)
        #endif
    }
    
    @available(iOS 13.0, *)
    func webView(_ scriptMessageHandlerArray: [String], didReceive message: WKScriptMessage, resolve replyHandler: @escaping (Any?, String?) -> Void) {
        self.replyHandler = replyHandler
        
        scriptMessageHandle(didReceive: JSON(message.body)["body"])
    }
}

// MARK: - ScriptMessageHandlerArray
extension ViewController {
    /// 桥接JS与Swift
    func scriptMessageHandle(didReceive message: JSON) {
        let action = ViewActionMode(rawValue: message["action"].stringValue)
        
        switch action {
        case .OpenSettings:
            let settingsStoryboard = UIStoryboard.init(name: "Settings", bundle: nil)
            let settingsViewCtrl = settingsStoryboard.instantiateViewController(identifier: "Settings") as SettingsViewController
            
            /// 默认打开方式为模态窗形式 => 0:modal、1:NavigationController push
            let type = message["type"].intValue
            if type == 0 {
                self.present(settingsViewCtrl, animated: true, completion: nil)
            } else {
                settingsViewCtrl.type = 1
                self.navigationController?.pushViewController(settingsViewCtrl, animated: true)
            }
            break
        case .Reload:
            kWKWebView.reload()
            break
        case .Back:
            kWKWebView.goBack()
            break
        case .Forward:
            kWKWebView.goForward()
            break
        case .Location:
            let distance = message["distance"].doubleValue
            
            let locationManager = LocationManager.sharedInstance
            locationManager.delegate = self
            locationManager.startUpdatingLocation(self, distanceFilter: distance)
            break
        case .Image:
            let type = message["type"].intValue
            let allowsEditing = message["allowsEditing"].boolValue
            
            if type == 0 {
                presentImagePickerController(.camera, allowsEditing: allowsEditing)
            } else if type == 1 {
                presentImagePickerController(.photoLibrary, allowsEditing: allowsEditing)
            } else if type == 2 {
                let actionSheetCtrl = UIAlertController()
                let cancelButton = UIAlertAction(title: "取消", style: .cancel, handler: { _ in })
                let cameraButton = UIAlertAction(title: "拍照", style: .destructive, handler: {
                    _ in
                    self.presentImagePickerController(.camera, allowsEditing: allowsEditing)
                })
                let photoButton = UIAlertAction(title: "相册", style: .default, handler: {
                    _ in
                    self.presentImagePickerController(.photoLibrary, allowsEditing: allowsEditing)
                })
                actionSheetCtrl.addAction(cancelButton)
                actionSheetCtrl.addAction(cameraButton)
                actionSheetCtrl.addAction(photoButton)
                
                self.present(actionSheetCtrl, animated: true, completion: nil)
            } else {
                presentImagePickerController(.camera, allowsEditing: allowsEditing)
            }
            break
        case .Preview:
            if !message["data"].stringValue.isEmpty {
                let previewStoryboard = UIStoryboard.init(name: "Preview", bundle: nil)
                let previewCtrl = previewStoryboard.instantiateViewController(identifier: "Preview") as PreviewController
                previewCtrl.imageData = message["data"].stringValue
                previewCtrl.modalTransitionStyle = .crossDissolve
                previewCtrl.modalPresentationStyle = .overFullScreen
                self.present(previewCtrl, animated: true, completion: nil)
            }
            break
        case .Call:
//            let callWebView = WKWebView()
//            callWebView.load(URLRequest(url: URL(string: "tel:\(message["phoneNumber"].stringValue)")!))
//            UIApplication.shared.keyWindow?.addSubview(callWebView)
            break
        default: break
        }
    }
}

// MARK: - CLLocationManagerDelegate
extension ViewController: LocationProtocol {
    
    func coordinateUpdated(latitude: Double, longitude: Double, placemarks: [CLPlacemark]?) {
        let json = JSON(["latitude": latitude, "longitude": longitude, "placemarks": placemarks ?? []] as [String : Any])
        
        if replyHandler != nil {
            // 直接返回Promise
            replyHandler!(json.rawString(), nil)
        } else {
            // TODO 传递经纬度信息到web
            kWKWebView.excuteJavaScript(javaScript: "")
        }
    }
}

// MARK: - UIImagePickerControllerDelegate
extension ViewController: UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        picker.dismiss(animated: true, completion: nil)
        
        let image: UIImage
        let url = info[UIImagePickerController.InfoKey.imageURL] as! NSURL
        #if DEBUG
        print(url)
        #endif
        if picker.allowsEditing {
            image = info[UIImagePickerController.InfoKey.editedImage] as! UIImage
        } else {
            image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        }
        
        let json = JSON(["url": url.absoluteString, "base64": ImageUtils.imageToBase64String(image: image)] as [String : String?])
        
        if replyHandler != nil {
            // 直接返回Promise
            replyHandler!(json.rawString(), nil)
        } else {
            kWKWebView.excuteJavaScript(javaScript: "")
        }
    }
    
    fileprivate func presentImagePickerController(_ sourceType: UIImagePickerController.SourceType, allowsEditing: Bool) {
        let imagePickerCtrl = UIImagePickerController()
        imagePickerCtrl.allowsEditing = allowsEditing
        imagePickerCtrl.sourceType = sourceType
        imagePickerCtrl.delegate = self
        
        self.present(imagePickerCtrl, animated: true, completion: nil)
    }
}

enum ViewActionMode: String {
    
    /// js 打开原生页面
    case OpenSettings = "openSettings"
    
    /// 重新加载WKWebView
    case Reload = "reload"
    
    /// WKWebView返回
    case Back = "goBack"
    
    /// WKWebView前进
    case Forward = "goForward"
    
    /// 获取定位经纬度
    case Location = "location"
    
    /// 打开箱机拍照或选取相册照片
    case Image = "image"
    
    /// 预览图片
    case Preview = "preview"
    
    /// 呼叫电话
    case Call = "call"
}
