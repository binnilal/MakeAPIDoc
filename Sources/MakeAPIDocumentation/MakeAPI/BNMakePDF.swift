//
//  BNMakePDF.swift
//  MakeAPIDocumentation
//
//  Created by Binnilal on 06/08/2022.
//

import Foundation
import UIKit

struct HTML {
    static let firstHTML: String =
        """
        <!DOCTYPE html><html><head></head>
           <body><table style="width: 650px;border-spacing:0;border-color: #858585;border-style:solid;border-width:1px;font-family:Roboto;
             padding:10px 10px;word-break:break-word;border-collapse: collapse;"><tbody>
           <tr><td colspan="2" style="border-style:none;padding:5px 5px;text-align:center;font-size:55px;font-weight: 500;height:120px;"> API DOCUMENTATION </td></tr>
        """
    
    static let lastHTML =
        """
        </tbody></table></body></html>
        """
}

class BNMakePDF {
    
    init() {
        
    }
    
    func makePDF() {
        let html = self.makeHTML()
        let fmt = UIMarkupTextPrintFormatter(markupText: html)
        
        let render = UIPrintPageRenderer()
        render.addPrintFormatter(fmt, startingAtPageAt: 0)
        
        let printableRect = CGRect(x: 0, y: 0, width: 595.2, height: 841.8)
        let page = CGRect(x: 0, y: 0, width: 595.2, height: 841.8) // A4, 72 dpi
        render.setValue(page, forKey: "paperRect")
        render.setValue(printableRect, forKey: "printableRect")
        
        let pdfData = NSMutableData()
        UIGraphicsBeginPDFContextToData(pdfData, render.paperRect, nil)
        render.prepare(forDrawingPages: NSMakeRange(0, render.numberOfPages))

        for pdfPage in 0..<render.numberOfPages {
            UIGraphicsBeginPDFPage()
            render.drawPage(at: pdfPage, in: UIGraphicsGetPDFContextBounds())
        }

        UIGraphicsEndPDFContext()
        
        guard let outputURL = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("API_Doc").appendingPathExtension("pdf")
            else { fatalError("Destination URL not created") }

        pdfData.write(to: outputURL, atomically: true)
        
//        guard let outputURL1 = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("output1").appendingPathExtension("html")
//            else { fatalError("Destination URL not created") }
//        guard let htmlData = html.data(using: .utf8) else {
//            return
//        }
//        do {
//            try htmlData.write(to: outputURL1)
//        } catch {
//            
//        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.sharePDF(outputURL)
        }
    }
    
    fileprivate func sharePDF(_ pdfURL: URL) {
        guard let vc = UIApplication.topWindow.rootViewController else {
            return
        }
        if FileManager.default.fileExists(atPath: pdfURL.path) {
            let activityViewController = UIActivityViewController(activityItems: [pdfURL], applicationActivities: nil)
            let excludeActivities = [UIActivity.ActivityType.airDrop,
                                     UIActivity.ActivityType.print,
                                     UIActivity.ActivityType.assignToContact,
                                     UIActivity.ActivityType.saveToCameraRoll,
                                     UIActivity.ActivityType.addToReadingList,
                                     UIActivity.ActivityType.postToFlickr,
                                     UIActivity.ActivityType.postToVimeo,
                                     UIActivity.ActivityType.postToWeibo,
                                     UIActivity.ActivityType.copyToPasteboard]
            activityViewController.excludedActivityTypes = excludeActivities
            activityViewController.completionWithItemsHandler = { activity, completed, items, error in
                if completed {
                    vc.dismiss(animated: true) {
                        
                    }
                }
            }
            vc.present(activityViewController, animated: true, completion: nil)
        }
    }
    
    fileprivate func makeHTML() -> String {
        let allAPIs = CoreDataManager.getAllRestAPIs()
        var dynamicHTML = ""
        for api in allAPIs {
            dynamicHTML +=
                """
                  <tr>
                    <td class="tg-data" style="border-style:solid;border-width:1px;padding: 12px 12px;border-spacing:0;" width=30%>URL</td>
                    <td class="tg-data" style="border-style:solid;border-width:1px;padding: 12px 12px;border-spacing:0;" width=70%>\(api.url ?? "")</td>
                  </tr>
                  <tr>
                    <td class="tg-data" style="border-style:solid;border-width:1px;padding: 12px 12px;border-spacing:0;" width=30%>Method</td>
                    <td class="tg-data" style="border-style:solid;border-width:1px;padding: 12px 12px;border-spacing:0;" width=70%>\(api.requestType ?? "")</td>
                  </tr>
                  <tr>
                    <td class="tg-data" style="border-style:solid;border-width:1px;padding: 12px 12px;border-spacing:0;" width=30%>Header</td>
                    <td class="tg-data" style="border-style:solid;border-width:1px;padding: 12px 12px;border-spacing:0;" width=70%>\(api.header ?? "")</td>
                  </tr>
                  <tr>
                    <td class="tg-data" style="border-style:solid;border-width:1px;padding: 12px 12px;border-spacing:0;" width=30%>Request</td>
                    <td class="tg-data" style="border-style:solid;border-width:1px;padding: 12px 12px;border-spacing:0;" width=70%>\(api.request ?? "")</td>
                  </tr>
                  <tr>
                    <td class="tg-data" style="border-style:solid;border-width:1px;padding: 12px 12px;border-spacing:0;" width=30%>Response</td>
                    <td class="tg-data" style="border-style:solid;border-width:1px;padding: 12px 12px;border-spacing:0;" width=70%>\(api.response ?? "")</td>
                  </tr>
                
                  <tr><td colspan="2" style="border-style:none;padding:5px 5px;height: 40px;"></td></tr>
                """
        }
        
        return "\(HTML.firstHTML)\(dynamicHTML)\(HTML.lastHTML)"
    }
}




