import UIKit

@MainActor
protocol ImagesListDisplayLogic: AnyObject {
    func displayImages(viewModel: ImagesList.LoadImages.ViewModel)
    func displayCacheCleared(viewModel: ImagesList.ClearCache.ViewModel)
}

final class ImagesListViewController: UIViewController {
    var interactor: ImagesListBusinessLogic?

    private let tableView = UITableView(frame: .zero, style: .plain)
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    private let emptyStateLabel = UILabel()

    private var displayedImages: [ImagesList.DisplayedImage] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        interactor?.loadImages(request: .init())
    }

    private func configureView() {
        title = "Images"
        view.backgroundColor = .systemBackground

        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "trash"),
            style: .plain,
            target: self,
            action: #selector(didTapClearCacheButton)
        )
        navigationItem.rightBarButtonItem?.accessibilityLabel = "Clear cache"

        configureTableView()
        configureActivityIndicator()
        configureEmptyStateLabel()
    }

    private func configureTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 72
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: Constants.cellIdentifier)

        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func configureActivityIndicator() {
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.hidesWhenStopped = true

        view.addSubview(activityIndicator)

        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    private func configureEmptyStateLabel() {
        emptyStateLabel.translatesAutoresizingMaskIntoConstraints = false
        emptyStateLabel.font = .preferredFont(forTextStyle: .body)
        emptyStateLabel.textAlignment = .center
        emptyStateLabel.textColor = .secondaryLabel
        emptyStateLabel.numberOfLines = 0
        emptyStateLabel.isHidden = true

        view.addSubview(emptyStateLabel)

        NSLayoutConstraint.activate([
            emptyStateLabel.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            emptyStateLabel.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            emptyStateLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    @objc
    private func didTapClearCacheButton() {
        interactor?.clearCache(request: .init())
    }

    private enum Constants {
        static let cellIdentifier = "ImageCell"
    }
}

// MARK: - ImagesListDisplayLogic

extension ImagesListViewController: ImagesListDisplayLogic {
    func displayImages(viewModel: ImagesList.LoadImages.ViewModel) {
        switch viewModel.state {
        case .loading:
            emptyStateLabel.isHidden = true
            activityIndicator.startAnimating()

        case let .content(images):
            activityIndicator.stopAnimating()
            emptyStateLabel.isHidden = true
            displayedImages = images
            tableView.reloadData()

        case .empty:
            activityIndicator.stopAnimating()
            displayedImages = []
            tableView.reloadData()
            emptyStateLabel.text = "No images available yet."
            emptyStateLabel.isHidden = false

        case let .error(message):
            activityIndicator.stopAnimating()
            displayedImages = []
            tableView.reloadData()
            emptyStateLabel.text = message
            emptyStateLabel.isHidden = false
        }
    }

    func displayCacheCleared(viewModel: ImagesList.ClearCache.ViewModel) {
        let alert = UIAlertController(
            title: nil,
            message: viewModel.message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDataSource

extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        displayedImages.count
    }

    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: Constants.cellIdentifier,
            for: indexPath
        )
        let image = displayedImages[indexPath.row]

        var content = cell.defaultContentConfiguration()
        content.text = image.id
        content.secondaryText = image.subtitle
        content.secondaryTextProperties.numberOfLines = 2
        cell.contentConfiguration = content
        cell.selectionStyle = .none

        return cell
    }
}
