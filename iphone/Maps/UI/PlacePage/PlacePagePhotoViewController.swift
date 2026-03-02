import UIKit

class PlacePagePhotoViewController: UIViewController {
  private let imageView = UIImageView()
  var imageUrl: String? {
    didSet {
      updateImage()
    }
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    view.addSubview(imageView)
    imageView.contentMode = .scaleAspectFill
    imageView.clipsToBounds = true
    imageView.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      imageView.topAnchor.constraint(equalTo: view.topAnchor),
      imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
      imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      view.heightAnchor.constraint(equalToConstant: 200)
    ])
  }

  private func updateImage() {
    guard let imageUrl = imageUrl, let url = URL(string: imageUrl) else {
      view.isHidden = true
      return
    }
    view.isHidden = false
    MWMWebImage.defaultWebImage().image(with: url) { [weak self] image, _ in
      self?.imageView.image = image
    }
  }
}
