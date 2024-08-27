//
//  ViewController.swift
//  PopulationApp
//
//  Created by João Santos on 27/08/2024.
//

import UIKit
import SwiftUI

class ViewController: UIViewController {
    
    let stateWrapperView = UIView()
    let nationChartWrapperView = UIView()
    let nationChartData = PopulationChartData(items: [])
    let apiManager = ApiManager()
    var segmentView: UISegmentedControl!
    let activityIndicator = UIActivityIndicatorView(style: .large)

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .systemBackground
        
        self.segmentView = UISegmentedControl(frame: .zero, actions: [
            UIAction(title: "State Population", handler: { a in
                self.stateWrapperView.isHidden = false
                self.nationChartWrapperView.isHidden = true
            }),
            UIAction(title: "Nation Population", handler: { a in
                self.stateWrapperView.isHidden = true
                self.nationChartWrapperView.isHidden = false
            })
        ])
        self.segmentView.translatesAutoresizingMaskIntoConstraints = false
        self.segmentView.selectedSegmentIndex = 0
        self.view.addSubview(self.segmentView)
        
        self.stateWrapperView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.stateWrapperView)
        
        self.nationChartWrapperView.translatesAutoresizingMaskIntoConstraints = false
        self.nationChartWrapperView.isHidden = true
        self.view.addSubview(self.nationChartWrapperView)
        
        self.activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        self.activityIndicator.hidesWhenStopped = true
        self.view.addSubview(self.activityIndicator)
        
        NSLayoutConstraint.activate([
            self.segmentView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 10),
            self.segmentView.centerXAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.centerXAnchor),
            
            self.stateWrapperView.topAnchor.constraint(equalTo: self.segmentView.bottomAnchor, constant: 10),
            self.stateWrapperView.leftAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leftAnchor),
            self.stateWrapperView.rightAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.rightAnchor),
            self.stateWrapperView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            
            self.nationChartWrapperView.topAnchor.constraint(equalTo: self.segmentView.bottomAnchor, constant: 10),
            self.nationChartWrapperView.leftAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leftAnchor),
            self.nationChartWrapperView.rightAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.rightAnchor),
            self.nationChartWrapperView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            
            self.activityIndicator.centerXAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.centerXAnchor),
            self.activityIndicator.centerYAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.centerYAnchor)
        ])
        
        
        self.activityIndicator.startAnimating()
        Task {
            do {
                // Problem: Here if the first function throws the second function will not be called
                // so potentially there could be a problem with the states request and not with the
                // nation request, so we could display the nation data.
                // For the sake of simplicity we'll keep it as is, but could have done it in separate tasks
                let stateData = try await self.apiManager.fetchStateData()
                let nationData = try await self.apiManager.fetchNationData()
                
                // Because this function is marked as @MainActor, it will be safely called
                // from the main thread
                self.updateStatePopulationUI(stateData: stateData)
                self.updateNationChartUI(nationData: nationData)
                
            } catch {
                self.displayErrorAlert(error: error)
            }
            
            await MainActor.run {
                self.activityIndicator.stopAnimating()
            }
        }
    }
    
    @MainActor func updateStatePopulationUI(stateData: StateData) {
        if self.stateWrapperView.subviews.count > 0 {
            self.stateWrapperView.subviews.forEach({ $0.removeFromSuperview() })
        }
        
        let items = stateData.data.map({ countryState in
            return TableItem(location: countryState.state, population: countryState.population, year: countryState.idYear)
        })
        let tableData = TableData(items: items)
        let host = UIHostingController(rootView: PopulationTableView().environmentObject(tableData))
        host.view.translatesAutoresizingMaskIntoConstraints = false
        self.stateWrapperView.addSubview(host.view)
        
        NSLayoutConstraint.activate([
            host.view.topAnchor.constraint(equalTo: self.stateWrapperView.topAnchor),
            host.view.leftAnchor.constraint(equalTo: self.stateWrapperView.leftAnchor),
            host.view.rightAnchor.constraint(equalTo: self.stateWrapperView.rightAnchor),
            host.view.bottomAnchor.constraint(equalTo: self.stateWrapperView.bottomAnchor),
        ])
    }
    
    @MainActor func updateNationChartUI(nationData: NationData) {
        if self.nationChartWrapperView.subviews.count > 0 {
            self.nationChartWrapperView.subviews.forEach({ $0.removeFromSuperview() })
        }
        
        let items = nationData.data.map({ nationData in
            return PopulationChartItem(year: nationData.idYear, population: nationData.population)
        })
        let chartData = PopulationChartData(items: items)
        
        let host = UIHostingController(rootView: PopulationChartView().environmentObject(chartData))
        host.view.translatesAutoresizingMaskIntoConstraints = false
        self.nationChartWrapperView.addSubview(host.view)
        
        NSLayoutConstraint.activate([
            host.view.topAnchor.constraint(equalTo: self.nationChartWrapperView.topAnchor),
            host.view.leftAnchor.constraint(equalTo: self.nationChartWrapperView.leftAnchor),
            host.view.rightAnchor.constraint(equalTo: self.nationChartWrapperView.rightAnchor),
            host.view.bottomAnchor.constraint(equalTo: self.nationChartWrapperView.bottomAnchor),
        ])
    }

    @MainActor func displayErrorAlert(error: Error) {
        let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(alert, animated: true)
    }

}

