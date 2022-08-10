# MakeAPIDocumentation

A package for generating Rest API documentation of all APIs which called by using this library.

**Output**

- A PDF document

**Requirements**

- Swift 5

### Installation

Drag & drop MakeAPIDocumentation.framework file to the Frameworks, Libraries, and Embedded Content and select Embed as Embed & Sign



### Usage

Add setUp in AppDelegate class

```swift
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        BNMakeAPIDoc.shared.setUP()
        
        return true
    }
    
```

Use BNAPIProvider for API calling like below. 

```swift
enum API: RawRepresentable {
    typealias RawValue = String
    
    init?(rawValue: String) {
        fatalError()
    }
    
    var rawValue: String {
        return String(describing: self)
    }
    
    // get IP related info API
    case getIPDetails
    
}

extension API: ServiceProtocol {
    
    var baseURL: URL {
        return URL(string: "http://ip-api.com")!
    }
    
    var path: String {
        return "/json"
    }
    
    var method: HTTPMethod {
        return .get
    }
    
    var task: HTTPTask {
        return .requestPlain
    }
    
    var headers: Headers? {
        return ["Content-Type": "application/json"]
    }
    
    var parametersEncoding: ParametersEncoding {
        return .json
    }
}

struct APIResponse: Decodable {
    var status: String?
    var country: String?
    var countryCode: String?
    var region: String?
    var regionName: String?
    var city: String?
    var zip: String?
}

fileprivate func callAPI() {
    BNAPIProvider.shared.request(type: APIResponse.self, service: API.getIPDetails) { result in
        switch result {
        case .success(let reposne):
            print("test - \(reposne.countryCode)")
            break
        case .failure(let error):
            break
        }
    }
}
```

After adding BNMakeAPIDoc.shared.setUP() in AppDelegate class, it will be showing Share API button on every screen and tap action will be able to share a PDF document which includes all APIs URL, Request, Responses. 

    
