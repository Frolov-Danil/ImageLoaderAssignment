import ImageLoadingKit
import UIKit

struct PhotoCellViewState: Equatable {
    let id: String
    let url: URL
    let subtitle: String
}

final class PhotoCell: UITableViewCell {
    private let thumbnailImageView = AsyncImageView()
    private let idLabel = UILabel()
    private let urlLabel = UILabel()
    private let textStackView = UIStackView()
    private let containerStackView = UIStackView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureView()
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
    func configureView() {
        backgroundColor = .systemBackground
        selectionStyle = .none
        separatorInset = Constants.separatorInset
        contentView.directionalLayoutMargins = Constants.contentMargins

        configureThumbnailImageView()
        configureLabels()
        configureStackViews()
    }

    func configureThumbnailImageView() {
        thumbnailImageView.translatesAutoresizingMaskIntoConstraints = false
        thumbnailImageView.backgroundColor = .tertiarySystemFill
        thumbnailImageView.tintColor = .tertiaryLabel
        thumbnailImageView.layer.cornerRadius = Constants.thumbnailCornerRadius
        thumbnailImageView.layer.masksToBounds = true

        NSLayoutConstraint.activate([
            thumbnailImageView.widthAnchor.constraint(equalToConstant: Constants.thumbnailSize),
            thumbnailImageView.heightAnchor.constraint(equalToConstant: Constants.thumbnailSize)
        ])
    }

    func configureLabels() {
        idLabel.font = .preferredFont(forTextStyle: .headline)
        idLabel.textColor = .label
        idLabel.numberOfLines = 1
        idLabel.adjustsFontForContentSizeCategory = true

        urlLabel.font = .preferredFont(forTextStyle: .subheadline)
        urlLabel.textColor = .secondaryLabel
        urlLabel.numberOfLines = 2
        urlLabel.lineBreakMode = .byTruncatingMiddle
        urlLabel.adjustsFontForContentSizeCategory = true
    }

    func configureStackViews() {
        textStackView.axis = .vertical
        textStackView.alignment = .fill
        textStackView.spacing = Constants.textSpacing
        textStackView.addArrangedSubview(idLabel)
        textStackView.addArrangedSubview(urlLabel)

        containerStackView.translatesAutoresizingMaskIntoConstraints = false
        containerStackView.axis = .horizontal
        containerStackView.alignment = .center
        containerStackView.spacing = Constants.contentSpacing
        containerStackView.addArrangedSubview(thumbnailImageView)
        containerStackView.addArrangedSubview(textStackView)

        contentView.addSubview(containerStackView)

        NSLayoutConstraint.activate([
            containerStackView.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),
            containerStackView.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            containerStackView.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
            containerStackView.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor)
        ])
    }

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
