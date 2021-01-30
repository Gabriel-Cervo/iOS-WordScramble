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
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(promptForAnswer))
        
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
    
    @objc func promptForAnswer() {
        let alertController = UIAlertController(title: "Enter answer", message: nil, preferredStyle: .alert)
        alertController.addTextField()
        
        // Como o swift captura todos objetos usados na closure, definir como weak o proprio ViewController (self), pois chama o metodo submit dentro da closure, caso contrario acontecera um strong reference cycle
        let submitAction = UIAlertAction(title: "Submit", style: .default) { [weak self, weak alertController] _ in
            guard let answer = alertController?.textFields?[0].text else { return }
            
            self?.submit(answer) // Sempre usar self quando chamar algo de fora da closure mas mesma classe
            // Sempre cuidar os self nas closures, podem causar reference cycle...
        }
        
        alertController.addAction(submitAction)
        
        present(alertController, animated: true)
    }
    
    func submit(_ answer: String) {
        let lowerAnswer = answer.lowercased()
        
        let errorTitle: String
            let errorMessage: String

            if isPossible(word: lowerAnswer) {
                if isOriginal(word: lowerAnswer) {
                    if isReal(word: lowerAnswer) {
                        usedWords.insert(answer, at: 0)

                        let indexPath = IndexPath(row: 0, section: 0)
                        tableView.insertRows(at: [indexPath], with: .automatic)

                        return
                    } else {
                        errorTitle = "Word not recognised"
                        errorMessage = "You can't just make them up, you know!"
                    }
                } else {
                    errorTitle = "Word used already"
                    errorMessage = "Be more original!"
                }
            } else {
                guard let title = title?.lowercased() else { return }
                errorTitle = "Word not possible"
                errorMessage = "You can't spell that word from \(title)"
            }

            let ac = UIAlertController(title: errorTitle, message: errorMessage, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
        
            present(ac, animated: true)
    }
    
    //MARK: Word check methods
    func isPossible(word: String) -> Bool {
        guard var tempWord = title?.lowercased() else { return false }
        
        // Check se todas as letras sao usadas, removendo uma a uma da tempWord, se todas forem removidas ao fim do laço, quer dizer que é a mesma palavra, mesmo que em ordens diferentes
        for letter in word {
            if let position = tempWord.firstIndex(of: letter) {
                tempWord.remove(at: position)
            } else {
                return false
            }
        }
        
        return true
    }

    func isOriginal(word: String) -> Bool {
        return !usedWords.contains(word)
    }

    /**
     Swift’s strings natively store international characters as individual characters, e.g. the letter “é” is stored as precisely that. However, UIKit was written in Objective-C before Swift’s strings came along, and it uses a different character system called UTF-16 – short for 16-bit Unicode Transformation Format – where the accent and the letter are stored separately.

     It’s a subtle difference, and often it isn’t a difference at all, but it’s becoming increasingly problematic because of the rise of emoji – those little images that are frequently used in messages. Emoji are actually just special character combinations behind the scenes, and they are measured differently with Swift strings and UTF-16 strings: Swift strings count them as 1-letter strings, but UTF-16 considers them to be 2-letter strings. This means if you use count with UIKit methods, you run the risk of miscounting the string length.

     When you’re working with UIKit, SpriteKit, or any other Apple framework, use utf16.count for the character count. If it’s just  own code - i.e. looping over characters and processing each one individually – then use count instead.
     */
    func isReal(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count) // de: location, ate: ...
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        
        return misspelledRange.location == NSNotFound
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

