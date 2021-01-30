//
//  ViewController.swift
//  100DaysOfSwift-Project5
//
//  Created by João Gabriel Dourado Cervo on 30/01/21.
//

import UIKit

class ViewController: UITableViewController {
    var allWords = [String]()
    var usedWords = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt") else {
            print("No file found")
            return
        }
        
        // Transforma o arquivo txt em uma string para poder ler depois
        // O "try?" significa -> Roda esse codigo, e me retorna nil se retornar erro
        guard let startWords = try? String(contentsOf: startWordsURL) else {
            print("Can't transform file in string")
            return
        }
        
        // Cada linha é separada por um \n na string, entao separa as palavras por isso
        allWords = startWords.components(separatedBy: "\n") // Transforma string em array
        
        if allWords.isEmpty {
            allWords = ["Potato"]
        }
        
        startGame()
    }
    
    func startGame() {
        title = allWords.randomElement()
        usedWords.removeAll(keepingCapacity: true)
        tableView.reloadData()
    }
    
    //MARK: TableView methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usedWords.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Word", for: indexPath)
        cell.textLabel?.text = usedWords[indexPath.row]
        
        return cell
    }


}

