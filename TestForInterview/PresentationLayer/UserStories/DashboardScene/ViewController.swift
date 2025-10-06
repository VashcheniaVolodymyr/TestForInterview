//
//  DashboardScene.swift
//  TestForInterview
//
//  Created by Sam Titovskyi on 18.08.2025.
//

import UIKit
import SwiftUI
import Combine

class DashboardScene: UIViewController {
    // MARK: Private
    private var cancellables: Set<AnyCancellable> = []
    private var viewModel: any DashboardSceneVMP = DashboardSceneViewModel()
    private var searchButton: UIButton?
    private var modeButton: UIButton?
    
    private lazy var averageLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = UIColor(resource: .txt)
        return label
    }()
    
    // MARK: Injection
    @Injected private var navigation: Navigation

    // MARK: - IBOutlets
    @IBOutlet private weak var collectionView: UICollectionView!
    
    // MARK: Data Source
    private lazy var dataSource = CombineCollectionViewDataSource<MovieItem> { collectionView, indexPath, movie in
        let cell: PosterHostingCell = collectionView.dequeueCell(with: PosterHostingCell.self, for: indexPath)
        cell.configure(in: self, movie: movie)
        return cell
    } action: { [weak self] item in
        self?.navigation.navigate(builder: Scenes.movieDetails(movieId: Int32(item.id)))
    }
    
    // MARK: - Lifecycle
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        navigationController?.hidesBarsOnSwipe = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
        navigationController?.hidesBarsOnSwipe = true
        viewModel.viewWillAppear()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.viewDidLoad()
        
        setupUI()
        
        viewModel.movies
            .removeDuplicates()
            .sink { [weak self] items in
                guard let self = self else { return }
                self.dataSource.pushItems(items, to: self.collectionView)
            }
            .store(in: &cancellables)
        
        viewModel.isLoadingState
            .sink(receiveValue: { [weak self] isLoading in
                guard let self = self else { return }
                if isLoading {
                    self.showLoader()
                } else {
                    self.hideLoader()
                    self.collectionView.refreshControl?.endRefreshing()
                }
            })
            .store(in: &cancellables)
        
        
        viewModel.averageRating
            .removeDuplicates()
            .map { String(format: NSLocalizedString("average_rating", comment: ""), $0) }
            .sink { [weak self] text in
                guard let self = self else { return }
                self.averageLabel.text = text
            }
            .store(in: &cancellables)
    }
    // MARK: - UI Setup
    private lazy var refreshControl: UIRefreshControl = {
        let rc = UIRefreshControl()
        rc.tintColor = UIColor(resource: .txt)
        rc.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        return rc
    }()
    
    private func setupUI() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(resource: .bg)
        appearance.shadowColor = .clear
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        
        // CollectionView
        collectionView.register(PosterHostingCell.self, forCellWithReuseIdentifier: PosterHostingCell.identifier)
        collectionView.register(EmptyCollectionViewCell.self, forCellWithReuseIdentifier: EmptyCollectionViewCell.identifier)
        collectionView.register(PagerFooterView.self,
                forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
                                withReuseIdentifier: PagerFooterView.identifier)
        collectionView.register(
            EmptyFooterView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
            withReuseIdentifier: EmptyFooterView.identifier
        )
        collectionView.setCollectionViewLayout(collectionLayout(), animated: false)
        
        collectionView.alwaysBounceVertical = true
        collectionView.refreshControl = refreshControl
        collectionView.contentInset = UIEdgeInsets(top: 24, left: 0, bottom: 0, right: 0)

        
        dataSource.setFooterBuilder { [weak self] collectionView, indexPath in
            guard let self = self, self.viewModel.movies.value.isEmpty.NOT else {
                return collectionView.dequeueReusableSupplementaryView(
                    ofKind: UICollectionView.elementKindSectionFooter,
                    with: EmptyFooterView.self,
                    for: indexPath
                )
            }
            
            let footer = collectionView.dequeueReusableSupplementaryView(
                ofKind: UICollectionView.elementKindSectionFooter,
                with: PagerFooterView.self,
                for: indexPath
            )
            
            let pager = PagerListView(
                totalPages: Binding(
                    get: { self.viewModel.totalPages },
                    set: { _ in }
                ),
                current: Binding(
                    get: { self.viewModel.currentSelectedPage },
                    set: { [weak self] page in
                        self?.viewModel.didSelectPage(page: page)
                    }
                )
            )
            .padding(.horizontal, 12)
            
            footer.set(rootView: pager, parent: self)
            return footer
        }
        
        setUpRightUIBarButtons()
        
        let titleLabel = UILabel()
        titleLabel.text = NSLocalizedString("movie", comment: "")
        titleLabel.font = UIFont.systemFont(ofSize: 30, weight: .bold)
        titleLabel.textAlignment = .left
        titleLabel.sizeToFit()

        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: titleLabel)
        
        navigationItem.titleView = averageLabel
        averageLabel.textAlignment = .center
        averageLabel.sizeToFit()
    }
    
    @objc private func searchButtonTapped() {
        self.navigation.navigate(builder: Scenes.searchMovieScene())
    }
    
    @objc private func modeButtonTapped() {
        let currentTheme = ThemeManager.shared.currentTheme
        
        switch currentTheme {
        case .light:
            ThemeManager.shared.updateInterfaceStyle(.dark)
        case .unspecified, .dark:
            ThemeManager.shared.updateInterfaceStyle(.light)
        @unknown default:
            ThemeManager.shared.updateInterfaceStyle(.light)
        }
        
        updateRightUIBarButtons()
    }
    
    @objc private func handleRefresh() {
        viewModel.refresh()
    }
    
    private func setUpRightUIBarButtons() {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 16
        stack.alignment = .center
        
        let search = makeButton(image: UIImage(resource: .search), action: #selector(searchButtonTapped))
        let mode = makeButton(image: currentModeImage(), action: #selector(modeButtonTapped))
        
        self.searchButton = search
        self.modeButton = mode
        
        stack.addArrangedSubview(search)
        stack.addArrangedSubview(mode)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: stack)
    }
    
    private func currentModeImage() -> UIImage {
        let currentTheme = ThemeManager.shared.currentTheme
        return currentTheme == .dark ? UIImage(resource: .moon) : UIImage(resource: .sun)
    }

    func updateRightUIBarButtons() {
        modeButton?.setImage(currentModeImage().withRenderingMode(.alwaysTemplate), for: .normal)
    }
    
    private func makeButton(image: UIImage?, action: Selector) -> UIButton {
        let button = UIButton(type: .system)
        button.setImage(image?.withRenderingMode(.alwaysTemplate), for: .normal)
        button.tintColor = UIColor(resource: .txt)
        button.widthAnchor.constraint(equalToConstant: 24).isActive = true
        button.heightAnchor.constraint(equalToConstant: 24).isActive = true
        button.addTarget(self, action: action, for: .touchUpInside)
        return button
    }
    
    private func collectionLayout(spacing: CGFloat = 8, estimatedHeight: CGFloat = 269) -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(0.5),
            heightDimension: .absolute(269)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = .init(top: 4, leading: 4, bottom: 0, trailing: 4)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(estimatedHeight)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item, item])
        
        let section = NSCollectionLayoutSection(group: group)
        
        section.interGroupSpacing = spacing * 1.5
        section.contentInsets = .init(top: 0, leading: 0, bottom: 0, trailing: 0)
        
        
        let footerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                heightDimension: .absolute(68))
        let footer = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: footerSize,
            elementKind: UICollectionView.elementKindSectionFooter,
            alignment: .bottom
        )
        section.boundarySupplementaryItems = [footer]
        
        return UICollectionViewCompositionalLayout(section: section)
    }
}
