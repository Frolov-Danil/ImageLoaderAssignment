import ImageLoadingKit
import UIKit

struct PhotoCellViewState: Equatable {
    let id: String
    let url: URL
    let subtitle: String
}

final class PhotoCell: UITableViewCell {
    private let thumbnailImageView: AsyncImageView = {
        let imageView = AsyncImageView(
            url: nil,
            placeholder: Constants.placeholderImage
        )
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.backgroundColor = .tertiarySystemFill
        imageView.tintColor = .tertiaryLabel
        imageView.layer.cornerRadius = Constants.thumbnailCornerRadius
        imageView.layer.masksToBounds = true
        return imageView
    }()

    private let idLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .headline)
        label.textColor = .label
        label.numberOfLines = 1
        label.adjustsFontForContentSizeCategory = true
        return label
    }()

    private let urlLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .subheadline)
        label.textColor = .secondaryLabel
        label.numberOfLines = 2
        label.lineBreakMode = .byTruncatingMiddle
        label.adjustsFontForContentSizeCategory = true
        return label
    }()

    private let textStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.spacing = Constants.textSpacing
        return stackView
    }()

    private let containerStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = Constants.contentSpacing
        return stackView
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        thumbnailImageView.cancelLoading()
        thumbnailImageView.image = Constants.placeholderImage
        idLabel.text = nil
        urlLabel.text = nil
    }

    func configure(with viewState: PhotoCellViewState) {
        idLabel.text = viewState.id
        urlLabel.text = viewState.subtitle
        thumbnailImageView.setImage(
            from: viewState.url,
            placeholder: Constants.placeholderImage
        )
    }
}

// MARK: - Private

private extension PhotoCell {
    func setupUI() {
        setupView()
        setupHierarchy()
        setupConstraints()
    }

    func setupView() {
        backgroundColor = .systemBackground
        selectionStyle = .none
        separatorInset = Constants.separatorInset
        contentView.directionalLayoutMargins = Constants.contentMargins
    }

    func setupHierarchy() {
        textStackView.addArrangedSubview(idLabel)
        textStackView.addArrangedSubview(urlLabel)

        containerStackView.addArrangedSubview(thumbnailImageView)
        containerStackView.addArrangedSubview(textStackView)

        contentView.addSubview(containerStackView)
    }

    func setupConstraints() {
        NSLayoutConstraint.activate([
            thumbnailImageView.widthAnchor.constraint(equalToConstant: Constants.thumbnailSize),
            thumbnailImageView.heightAnchor.constraint(equalToConstant: Constants.thumbnailSize)
        ])

        NSLayoutConstraint.activate([
            containerStackView.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),
            containerStackView.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            containerStackView.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
            containerStackView.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor)
        ])
    }
}

// MARK: - Constants

private extension PhotoCell {
    enum Constants {
        static let placeholderImage = UIImage(systemName: "photo.fill")
        static let thumbnailSize: CGFloat = 80
        static let thumbnailCornerRadius: CGFloat = 8
        static let textSpacing: CGFloat = 4
        static let contentSpacing: CGFloat = 12
        static let contentMargins = NSDirectionalEdgeInsets(
            top: 12,
            leading: 16,
            bottom: 12,
            trailing: 16
        )
        static let separatorInset = UIEdgeInsets(
            top: 0,
            left: 108,
            bottom: 0,
            right: 16
        )
    }
}
