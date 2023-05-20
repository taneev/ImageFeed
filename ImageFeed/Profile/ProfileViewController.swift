//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by Тимур Танеев on 11.05.2023.
//

import UIKit

final class ProfileViewController: UIViewController {

    private let leftMargin: CGFloat = 16
    private let rightMargin: CGFloat = 16

    private var profileImageView: UIImageView!
    private var logoutButton: UIButton!

    private var usernameLabel: UILabel?
    private var emailLabel: UILabel?
    private var bioLabel: UILabel?

    override func viewDidLoad() {
        super.viewDidLoad()


        addSubviewsAndConstraints()

        // проверка верстки
        usernameLabel?.text = "Екатерина Новикова"
        emailLabel?.text = "@ekaterina_nov"
        bioLabel?.text = "Hello, world!"
    }

    private func addSubviewsAndConstraints() {
        profileImageView = createProfileImageView()
        view.addSubview(profileImageView)

        logoutButton = createLogoutButton()
        view.addSubview(logoutButton)

        usernameLabel = createUserNameLabel()
        view.addSubview(usernameLabel!)

        emailLabel = createEmailLabel()
        view.addSubview(emailLabel!)

        bioLabel = createBioLabel()
        view.addSubview(bioLabel!)

        addConstraints()
    }

    private func createProfileImageView() -> UIImageView {
        let userpickStub = UIImage(systemName: "person.crop.circle.fill")
        let profileImageView = UIImageView(image: userpickStub)
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
            logoutButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -rightMargin)
        ])

        if let usernameLabel {
            NSLayoutConstraint.activate([
                usernameLabel.leadingAnchor.constraint(equalTo: profileImageView.leadingAnchor),
                usernameLabel.topAnchor.constraint(equalTo:  profileImageView.bottomAnchor, constant: 8),
                usernameLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -rightMargin)
            ])
        }

        if  let emailLabel,
            let usernameLabel
        {
            NSLayoutConstraint.activate([
                emailLabel.leadingAnchor.constraint(equalTo: profileImageView.leadingAnchor),
                emailLabel.topAnchor.constraint(equalTo:  usernameLabel.bottomAnchor, constant: 8),
                emailLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -rightMargin)
            ])
        }

        if  let bioLabel,
            let emailLabel
        {
            NSLayoutConstraint.activate([
                bioLabel.leadingAnchor.constraint(equalTo: profileImageView.leadingAnchor),
                bioLabel.topAnchor.constraint(equalTo:  emailLabel.bottomAnchor, constant: 8),
                bioLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -rightMargin)
            ])
        }
    }

    @objc private func logoutButtonTapped() {
        print("logout tapped")
    }


}
