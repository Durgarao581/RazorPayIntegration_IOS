//
//  ViewController.swift
//  RozarPayIntegration
//
//
//

import UIKit
import Razorpay
import Alamofire

class ViewController: UIViewController{

// typealias Razorpay = RazorpayCheckout
    @IBOutlet weak var amountLabel: UITextField!
    var razorpay: RazorpayCheckout!
    override func viewDidLoad() {
        super.viewDidLoad()
        razorpay = RazorpayCheckout.initWithKey("rzp_test_jUWsCYo5BoosYd", andDelegate: self)
    }
    override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
           
    }
    func callApi(amount: String, completion: @escaping (_ orderid: String?) -> Void){
        let url = "https://api.razorpay.com/v1/orders"
        let parameters = ["amount":amount,"currency":"INR"]
        let headers: HTTPHeaders = [.authorization(username: "rzp_test_jUWsCYo5BoosYd", password: "oE2XmcF6JwQJsWubWkl1TkY4")]
        AF.request(url,method: .post,parameters: parameters,headers: headers).responseJSON { (response) in
            if let data = response.data{
                do{
                    let decoder = JSONDecoder()
                    let finalData = try decoder.decode(OrderModel.self, from: data)
                    completion(finalData.id)
                    
                }catch{
                    completion(nil)
                }
                
            }
        
        }
        
    }
    internal func showPaymentForm(orderid: String,amount: String){
        let options: [String:Any] = [
                    "amount": amount, //This is in currency subunits. 100 = 100 paise= INR 1.
                    "currency": "INR",//We support more that 92 international currencies.
                    "description": "purchase description",
                    "order_id": orderid,
                    "image": "https://url-to-image.png",
                    "name": "business or product name",
                    "prefill": [
                        "contact": "9797979797",
                        "email": "foo@bar.com"
                    ],
                    "theme": [
                        "color": "#F37254"
                      ]
                ]
        razorpay.open(options)
    }
  
    @IBAction func payTapped(_ sender: UIButton) {
        guard let amount = amountLabel.text else { return }
        let paise = Int(amount)
        let rupees = String((paise ?? 0) * 100)
        callApi(amount: rupees) { isId in
            if let id = isId{
            self.showPaymentForm(orderid: id, amount: rupees)
            }
        }
    }
}
//extension ViewController : RazorpayPaymentCompletionProtocol {
//
//    func onPaymentError(_ code: Int32, description str: String) {
//        print("error: ", code, str)
//       // self.presentAlert(withTitle: "Alert", message: str)
//    }
//
//    func onPaymentSuccess(_ payment_id: String) {
//        print("success: ", payment_id)
//       // self.presentAlert(withTitle: "Success", message: "Payment Succeeded")
//    }
//}
extension ViewController: RazorpayPaymentCompletionProtocolWithData {
    
    func onPaymentError(_ code: Int32, description str: String, andData response: [AnyHashable : Any]?) {
        print("error: ", code)
        //self.presentAlert(withTitle: "Alert", message: str)
    }
    
    func onPaymentSuccess(_ payment_id: String, andData response: [AnyHashable : Any]?) {
        print("success: ", payment_id)
    }
}
struct OrderModel: Decodable {
    var id : String
}
