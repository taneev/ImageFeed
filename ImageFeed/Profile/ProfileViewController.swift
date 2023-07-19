//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by Тимур Танеев on 11.05.2023.
//

import UIKit
import Kingfisher

public protocol ProfileViewControllerProtocol: AnyObject {
    var presenter: ProfilePresenterProtocol! { get set }
    func updateAvatar(from url: URL?)
    func updateProfileDetails(profile: Profile)
}

final class ProfileViewController: UIViewController {

    var presenter: ProfilePresenterProtocol!
    private let leftMargin: CGFloat = 16
    private let rightMargin: CGFloat = 16
    private let avatarCornerRadius: CGFloat = 35

    private lazy var profileImageView: UIImageView = { createProfileImageView() }()
    private lazy var logoutButton: UIButton = { createLogoutButton() }()

    private lazy var usernameLabel: UILabel = { createUserNameLabel() }()
    private lazy var emailLabel: UILabel = { createEmailLabel() }()
    private lazy var bioLabel: UILabel = { createBioLabel() }()

    override func viewDidLoad() {
        super.viewDidLoad()

        addSubviewsAndConstraints()
        presenter.viewDidLoad()
    }

    @objc private func logoutButtonTapped() {
        let alertPresenter = AlertPresenter(controller: self)

        let approveButtonText = "Да"
        let cancelButtonText = "Нет"

        let alertModel = AlertModel(title: "Пока, пока!",
                                    message: "Уверены, что хотите выйти?",
                                    cancelButtonText: cancelButtonText,
                                    approveButtonText: approveButtonText)

        alertPresenter.showAlert(alert: alertModel) { [weak self] action  in
            if action.title == approveButtonText {
                self?.presenter.logout()
            }
        }
    }
}

// MARK: ProfileViewControllerProtocol
extension ProfileViewController: ProfileViewControllerProtocol {

    func updateAvatar(from url: URL?) {
        guard let url else { return }

        let placeholder = UIImage(systemName: "person.crop.circle.fill")
        let processor = RoundCornerImageProcessor(cornerRadius: avatarCornerRadius)
        profileImageView.kf.setImage(with: url,
                                     placeholder: placeholder,
                                     options: [.processor(processor), .forceRefresh])
    }

    func updateProfileDetails(profile: Profile) {
        self.usernameLabel.text = profile.name
        self.emailLabel.text = profile.loginName
        self.bioLabel.text = profile.bio
    }
}

// MARK: верстка
extension ProfileViewController {
    private func addSubviewsAndConstraints() {
        view.backgroundColor = .ypBlack
        view.addSubview(profileImageView)
        view.addSubview(logoutButton)
        view.addSubview(usernameLabel)
        view.addSubview(emailLabel)
        view.addSubview(bioLabel)

        addConstraints()
    }

    private func createProfileImageView() -> UIImageView {
        let profileImageView = UIImageView()
        profileImageView.tintColor = .ypGray
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(profileImageView)

        return profileImageView
    }

    private func createLogoutButton() -> UIButton {
        let buttonImage = UIImage(named: "ipad.and.arrow.forward")!
        let button = UIButton.systemButton(with: buttonImage,
                                           target: self,
                                           action: #selector(Self.logoutButtonTapped))
        button.tintColor = .ypRed
        button.translatesAutoresizingMaskIntoConstraints = false
        button.accessibilityIdentifier = "logoutButton"
        view.addSubview(button)

        return button
    }

    private func createUserNameLabel() -> UILabel {
        let usernameLabel = UILabel()
        usernameLabel.font = UIFont.systemFont(ofSize: 23, weight: .bold)
        usernameLabel.textColor = .ypWhite
        usernameLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(usernameLabel)
        return usernameLabel
    }

    private func createEmailLabel() -> UILabel {
        let emailLabel = UILabel()
        emailLabel.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        emailLabel.textColor = .ypGray
        emailLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(emailLabel)
        return emailLabel
    }

    private func createBioLabel() -> UILabel {
        let bioLabel = UILabel()
        bioLabel.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        bioLabel.textColor = .ypWhite
        bioLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bioLabel)
        return bioLabel
    }

    private func addConstraints() {
        NSLayoutConstraint.activate([
            profileImageView.heightAnchor.constraint(equalToConstant: 70),
            profileImageView.widthAnchor.constraint(equalTo: profileImageView.heightAnchor),
            profileImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: leftMargin),
            profileImageView.topAnchor.constraint(equalTo:  view.safeAreaLayoutGuide.topAnchor, constant: 40),

            logoutButton.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor),
            logoutButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -rightMargin),

            usernameLabel.leadingAnchor.constraint(equalTo: profileImageView.leadingAnchor),
            usernameLabel.topAnchor.constraint(equalTo:  profileImageView.bottomAnchor, constant: 8),
            usernameLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -rightMargin),

            emailLabel.leadingAnchor.constraint(equalTo: profileImageView.leadingAnchor),
            emailLabel.topAnchor.constraint(equalTo:  usernameLabel.bottomAnchor, constant: 8),
            emailLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -rightMargin),

            bioLabel.leadingAnchor.constraint(equalTo: profileImageView.leadingAnchor),
            bioLabel.topAnchor.constraint(equalTo:  emailLabel.bottomAnchor, constant: 8),
            bioLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -rightMargin)
        ])
    }
}
