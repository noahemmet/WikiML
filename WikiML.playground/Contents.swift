import WikipediaKit

class FormattingDelegate: WikipediaTextFormattingDelegate {
    func format(context: WikipediaTextFormattingDelegateContext, rawText: String, title: String?, language: WikipediaLanguage, isHTML: Bool) -> String {
        // Do something to rawText before returning…
        //        print(rawText)
        return rawText
    }
}
let formatter = FormattingDelegate()
//Wikipedia.sharedFormattingDelegate = formatter

let wikipedia = Wikipedia()
WikipediaNetworking.appAuthorEmailForAPI = "wikisaurus@gmail.com"

let language = WikipediaLanguage("en")
let title = "Outline of academic disciplines"
let request = wikipedia.requestArticle(language: language, title: title, imageWidth: 100) { article, error in
    guard let article = article else { 
        print(error!)
        return
    }
    for toc in article.toc {
        //        print(toc.anchor)
    }
    
    let urls = article.displayText.extractURLs()
    //    print(article.displayText)
    //    print("\n\n\n")
    print("matching…")
    //    a href=\"(.*?)\"
    //    let links = article.rawText.slices(from: "a href=\"", to: "\"")
    let titles = article.rawText.slices(from: "title=\"", to: "\"")
    //    let links = article.rawText.slices(from: "a href=\"", to: "\"")
    let first10 = titles.prefix(10)
    print(first10)
    for title in first10 {
        let _ = wikipedia.requestArticle(language: language, title: title, imageWidth: 100) { titleArticle, titleError in
            guard let titleArticle = titleArticle else {
                print(titleError!)
                return
            }
            print(titleArticle.rawText)
        }
    }
    //    print("\n\n\n\n\n\n")
    //    print(article.displayText)
}

extension String {
    
    func matches(for regex: String) -> [String] {
        let regex = try! NSRegularExpression(pattern: regex, options: [])
        var results: [String] = []
        regex.enumerateMatches(in: self, options: [], range: NSMakeRange(0, self.utf16.count)) { result, flags, stop in
            if let r = result?.range(at: 1), let range = Range(r, in: self) {
                results.append(String(self[range]))
            }
        }
        return results
    }
    
    func slices(from: String, to: String) -> [String] {
        return matches(for: "\(from)(.*?)\(to)")
    }
    
    func extractURLs() -> [URL] {
        var urls : [URL] = []
        do {
            let detector = try NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
            detector.enumerateMatches(in: self, options: [], range: NSMakeRange(0, self.characters.count), using: { (result, _, _) in
                if let match = result, let url = match.url {
                    urls.append(url)
                }
            })
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        return urls
    }
}
