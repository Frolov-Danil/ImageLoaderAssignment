import UIKit

final class PhotoListViewController: UIViewController {
    private let viewModel: PhotoListViewModel

    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = Constants.estimatedRowHeight
        tableView.backgroundColor = .systemBackground
        tableView.separatorInset = Constants.separatorInset
        tableView.tableFooterView = UIView()
        tableView.register(PhotoCell.self, forCellReuseIdentifier: Constants.cellIdentifier)
        return tableView
    }()

    private let activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.hidesWhenStopped = true
        return activityIndicator
    }()

    private let emptyStateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .preferredFont(forTextStyle: .body)
        label.textAlignment = .center
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        label.isHidden = true
        return label
    }()

    private var photos: [PhotoCellViewState] = []

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
        setupUI()
        bindViewModel()
        viewModel.loadPhotos()
    }
}

// MARK: - Private

private extension PhotoListViewController {
    func setupUI() {
        setupView()
        setupNavigationItem()
        setupHierarchy()
        setupConstraints()
    }

    func setupView() {
        title = Constants.title
        view.backgroundColor = .systemBackground
        navigationController?.navigationBar.prefersLargeTitles = true
        tableView.dataSource = self
    }

    func setupNavigationItem() {
        navigationItem.largeTitleDisplayMode = .automatic
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: Constants.clearCacheImageName),
            style: .plain,
            target: self,
            action: #selector(didTapClearCacheButton)
        )
        navigationItem.rightBarButtonItem?.accessibilityLabel = Constants.clearCacheAccessibilityLabel
    }

    func setupHierarchy() {
        view.addSubview(tableView)
        view.addSubview(activityIndicator)
        view.addSubview(emptyStateLabel)
    }

    func setupConstraints() {
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])

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

        case let .empty(message):
            photos = []
            tableView.reloadData()
            emptyStateLabel.text = message
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
        alert.addAction(UIAlertAction(title: Constants.alertConfirmationTitle, style: .default))
        present(alert, animated: true)
    }

    @objc
    func didTapClearCacheButton() {
        navigationItem.rightBarButtonItem?.isEnabled = false
        viewModel.clearCache()
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

// MARK: - Constants

private extension PhotoListViewController {
    enum Constants {
        static let title = "Photos"
        static let clearCacheImageName = "trash"
        static let clearCacheAccessibilityLabel = "Clear cache"
        static let alertConfirmationTitle = "OK"
        static let cellIdentifier = "PhotoCell"
        static let estimatedRowHeight: CGFloat = 96
        static let separatorInset = UIEdgeInsets(
            top: 0,
            left: 108,
            bottom: 0,
            right: 16
        )
    }
}
