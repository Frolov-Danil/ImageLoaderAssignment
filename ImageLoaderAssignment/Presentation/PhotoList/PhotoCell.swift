import ImageLoadingKit
import UIKit

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

    func configure(with viewModel: PhotoCellViewModel) {
        idLabel.text = viewModel.id
        urlLabel.text = viewModel.subtitle
        thumbnailImageView.setImage(
            from: viewModel.url,
            placeholder: Constants.placeholderImage
        )
    }
}

// MARK: - Private

private extension PhotoCell {
    func configureView() {
        selectionStyle = .none

        configureThumbnailImageView()
        configureLabels()
        configureStackViews()
    }

    func configureThumbnailImageView() {
        thumbnailImageView.translatesAutoresizingMaskIntoConstraints = false
        thumbnailImageView.backgroundColor = .secondarySystemBackground
        thumbnailImageView.layer.cornerRadius = 8
        thumbnailImageView.layer.masksToBounds = true

        NSLayoutConstraint.activate([
            thumbnailImageView.widthAnchor.constraint(equalToConstant: 72),
            thumbnailImageView.heightAnchor.constraint(equalToConstant: 72)
        ])
    }

    func configureLabels() {
        idLabel.font = .preferredFont(forTextStyle: .headline)
        idLabel.textColor = .label
        idLabel.numberOfLines = 1

        urlLabel.font = .preferredFont(forTextStyle: .subheadline)
        urlLabel.textColor = .secondaryLabel
        urlLabel.numberOfLines = 2
        urlLabel.lineBreakMode = .byTruncatingMiddle
    }

    func configureStackViews() {
        textStackView.axis = .vertical
        textStackView.alignment = .fill
        textStackView.spacing = 4
        textStackView.addArrangedSubview(idLabel)
        textStackView.addArrangedSubview(urlLabel)

        containerStackView.translatesAutoresizingMaskIntoConstraints = false
        containerStackView.axis = .horizontal
        containerStackView.alignment = .center
        containerStackView.spacing = 12
        containerStackView.addArrangedSubview(thumbnailImageView)
        containerStackView.addArrangedSubview(textStackView)

        contentView.addSubview(containerStackView)

        NSLayoutConstraint.activate([
            containerStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            containerStackView.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            containerStackView.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
            containerStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
        ])
    }

    enum Constants {
        static let placeholderImage = UIImage(systemName: "photo")
    }
}
