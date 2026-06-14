import UIKit

final class PhotoListViewController: UIViewController {
    private let viewModel: PhotoListViewModel

    private let tableView = UITableView(frame: .zero, style: .plain)
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    private let emptyStateLabel = UILabel()

    private var photos: [PhotoCellViewModel] = []

    init(viewModel: PhotoListViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        bindViewModel()
        viewModel.loadPhotos()
    }
}

// MARK: - Private

private extension PhotoListViewController {
    func configureView() {
        title = "Photos"
        view.backgroundColor = .systemBackground
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .automatic

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

    func configureTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 96
        tableView.backgroundColor = .systemBackground
        tableView.separatorInset = Constants.separatorInset
        tableView.tableFooterView = UIView()
        tableView.register(PhotoCell.self, forCellReuseIdentifier: Constants.cellIdentifier)

        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    func configureActivityIndicator() {
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.hidesWhenStopped = true

        view.addSubview(activityIndicator)

        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    func configureEmptyStateLabel() {
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

    func bindViewModel() {
        viewModel.onStateChange = { [weak self] state in
            self?.render(state)
        }

        viewModel.onCacheCleared = { [weak self] message in
            self?.showCacheClearedAlert(message: message)
        }
    }

    func render(_ state: PhotoListState) {
        switch state {
        case .loading:
            photos = []
            tableView.reloadData()
            emptyStateLabel.isHidden = true
            activityIndicator.startAnimating()

        case let .content(photos):
            self.photos = photos
            tableView.reloadData()
            emptyStateLabel.isHidden = true
            activityIndicator.stopAnimating()

        case .empty:
            photos = []
            tableView.reloadData()
            emptyStateLabel.text = "No images available yet."
            emptyStateLabel.isHidden = false
            activityIndicator.stopAnimating()

        case let .error(message):
            photos = []
            tableView.reloadData()
            emptyStateLabel.text = message
            emptyStateLabel.isHidden = false
            activityIndicator.stopAnimating()
        }
    }

    func showCacheClearedAlert(message: String) {
        navigationItem.rightBarButtonItem?.isEnabled = true

        let alert = UIAlertController(
            title: nil,
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    @objc
    func didTapClearCacheButton() {
        navigationItem.rightBarButtonItem?.isEnabled = false
        viewModel.clearCache()
    }

    enum Constants {
        static let cellIdentifier = "PhotoCell"
        static let separatorInset = UIEdgeInsets(
            top: 0,
            left: 108,
            bottom: 0,
            right: 16
        )
    }
}

// MARK: - UITableViewDataSource

extension PhotoListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        photos.count
    }

    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: Constants.cellIdentifier,
            for: indexPath
        )

        guard let photoCell = cell as? PhotoCell else {
            return cell
        }

        photoCell.configure(with: photos[indexPath.row])
        return photoCell
    }
}
