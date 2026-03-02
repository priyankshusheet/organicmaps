import Foundation

@objc class PlacePagePhotoService: NSObject {
  @objc static let shared = PlacePagePhotoService()
  
  private let cache = NSCache<NSString, NSString>()
  
  @objc func fetchPhotoUrl(wikidata: String?, wikipedia: String?, completion: @escaping (String?) -> Void) {
    if let wikidata = wikidata, !wikidata.isEmpty {
      fetchFromWikidata(wikidata: wikidata, completion: completion)
    } else if let wikipedia = wikipedia, !wikipedia.isEmpty {
      fetchFromWikipedia(wikipedia: wikipedia, completion: completion)
    } else {
      completion(nil)
    }
  }
  
  private func fetchFromWikidata(wikidata: String, completion: @escaping (String?) -> Void) {
    if let cached = cache.object(forKey: wikidata as NSString) {
      completion(cached as String)
      return
    }
    
    let urlString = "https://www.wikidata.org/w/api.php?action=wbgetclaims&entity=\(wikidata)&property=P18&format=json"
    guard let url = URL(string: urlString) else {
      completion(nil)
      return
    }
    
    URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
      guard let data = data,
            let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
            let claims = json["claims"] as? [String: Any],
            let p18 = claims["P18"] as? [[String: Any]],
            let mainsnak = p18.first?["mainsnak"] as? [String: Any],
            let datavalue = mainsnak["datavalue"] as? [String: Any],
            let value = datavalue["value"] as? String else {
        completion(nil)
        return
      }
      
      let imageUrl = self?.constructCommonsUrl(filename: value)
      if let imageUrl = imageUrl {
        self?.cache.setObject(imageUrl as NSString, forKey: wikidata as NSString)
      }
      dispatch_async(dispatch_get_main_queue(), {
        completion(imageUrl)
      })
    }.resume()
  }
  
  private func fetchFromWikipedia(wikipedia: String, completion: @escaping (String?) -> Void) {
    // Wikipedia string is usually "lang:PageTitle"
    let components = wikipedia.components(separatedBy: ":")
    guard components.count == 2 else {
      completion(nil)
      return
    }
    let lang = components[0]
    let title = components[1]
    
    if let cached = cache.object(forKey: wikipedia as NSString) {
      completion(cached as String)
      return
    }
    
    let encodedTitle = title.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? title
    let urlString = "https://\(lang).wikipedia.org/w/api.php?action=query&titles=\(encodedTitle)&prop=pageimages&format=json&pithumbsize=500"
    guard let url = URL(string: urlString) else {
      completion(nil)
      return
    }
    
    URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
      guard let data = data,
            let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
            let query = json["query"] as? [String: Any],
            let pages = query["pages"] as? [String: [String: Any]],
            let page = pages.values.first,
            let thumbnail = page["thumbnail"] as? [String: Any],
            let source = thumbnail["source"] as? String else {
        completion(nil)
        return
      }
      
      self?.cache.setObject(source as NSString, forKey: wikipedia as NSString)
      dispatch_async(dispatch_get_main_queue(), {
        completion(source)
      })
    }.resume()
  }
  
  private func constructCommonsUrl(filename: String) -> String? {
    let internalName = filename.replacingOccurrences(of: " ", with: "_")
    let md5 = (internalName as NSString).md5String()
    let prefix1 = String(md5.prefix(1))
    let prefix2 = String(md5.prefix(2))
    let encodedFilename = internalName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? internalName
    return "https://upload.wikimedia.org/wikipedia/commons/thumb/\(prefix1)/\(prefix2)/\(encodedFilename)/500px-\(encodedFilename)"
  }
}

private func dispatch_async(_ queue: dispatch_queue_t, _ block: @escaping () -> Void) {
  queue.async(execute: block)
}

private func dispatch_get_main_queue() -> DispatchQueue {
  return DispatchQueue.main
}
