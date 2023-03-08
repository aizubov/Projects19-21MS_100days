//
//  ViewController.swift
//  Projects19-21MS_100days
//
//  Created by user228564 on 3/8/23.
//

import UIKit


final class ViewController: UITableViewController, DetailDelegate {
    // MARK: - Parameters
    
    private var notes = [Note]()
    
    var selectedCellView: UIView!

    var editButton: UIBarButtonItem!
    var cancelButton: UIBarButtonItem!
    
    var spacerButton: UIBarButtonItem!
    var notesCountButton: UIBarButtonItem!
    var newNoteButton: UIBarButtonItem!
    var deleteAllButton: UIBarButtonItem!
    var buttonDelete: UIBarButtonItem!

    // MARK: - ViewController Settings
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Notes"
        navigationController?.navigationBar.prefersLargeTitles = true

        newNoteButton = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(createNote))
        
        toolbarItems = [newNoteButton]
        navigationController?.isToolbarHidden = false

        
        tableView.allowsMultipleSelectionDuringEditing = true
        
        reloadDataFromSaveAndLoadUtils()
    }

    override func viewWillAppear(_ animated: Bool) {
        sortNotes()
        updateData()
    }

    // MARK: - Save, Load and Update
    
    func reloadDataFromSaveAndLoadUtils() {
        DispatchQueue.global().async { [weak self] in
            self?.notes = SaveAndLoadUtils.load()
            self?.sortNotes()
            
            DispatchQueue.main.async {
                self?.updateData()
            }
        }
    }
    
    func updateData() {
        tableView.reloadData()
    }
     
    func sortNotes() {
        notes.sort(by: { $0.date >= $1.date })
    }
    

    // MARK: - Table formatting
     
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notes.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Note", for: indexPath)

        if let cell = cell as? NoteCell {
            let note = notes[indexPath.row]
            let split = note.text.split(separator: "\n", maxSplits: 2, omittingEmptySubsequences: true)
            
            cell.titleLabel.text = getTitleText(split: split)
            cell.subtitleLabel.text = getSubtitleText(split: split)
            cell.dateLabel.text = formatDate(from: note.date)
            

        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            notes.remove(at: indexPath.row)
            
            DispatchQueue.global().async { [weak self] in
                if let notes = self?.notes {
                    SaveAndLoadUtils.save(notes: notes)
                }
                
                DispatchQueue.main.async {
                    self?.tableView.deleteRows(at: [indexPath], with: .automatic)
                }
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView.isEditing {
            toolbarItems = [spacerButton, buttonDelete]
        }
        else {
            toDetailViewController(noteIndex: indexPath.row)
        }
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if tableView.isEditing {
            if tableView.indexPathsForSelectedRows == nil || tableView.indexPathsForSelectedRows!.isEmpty {
                toolbarItems = [spacerButton]
            }
        }
    }
    
    // MARK: Cell formatting
    
    func getTitleText(split: [Substring]) -> String {
        if split.count >= 1 {
            return String(split[0])
        }
        
        return "No Header"
    }
    
    func getSubtitleText(split: [Substring]) -> String {
        if split.count >= 2 {
            return String(split[1])
        }
        
        return "Empty text field"
    }
    
    func formatDate(from date: Date) -> String {
        let dateFormatter = DateFormatter()
        
        if Calendar.current.isDateInToday(date) {
            dateFormatter.dateStyle = .none
            dateFormatter.timeStyle = .short
            return dateFormatter.string(from: date)
        }
        
        if Calendar.current.isDateInYesterday(date) {
            return "Yesterday"
        }
        
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .none
        return dateFormatter.string(from: date)
    }
    
    
    // MARK: - Actions
    
    func toDetailViewController(noteIndex: Int) {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "DetailViewController") as? DetailViewController {
            vc.setParameters(notes: notes, noteIndex: noteIndex)
            vc.delegate = self
            navigationController?.pushViewController(vc, animated: true)
        }
    }

    @objc func createNote() {
        notes.append(Note(text: "", date: Date()))
        DispatchQueue.global().async { [weak self] in
            if let notes = self?.notes {
                SaveAndLoadUtils.save(notes: notes)
                
                DispatchQueue.main.async {
                    self?.toDetailViewController(noteIndex: notes.count - 1)
                }
            }
        }
    }
    
    // MARK: - Table Edit

    func deleteNotes(rows: [IndexPath]) {
        for path in rows {
            notes.remove(at: path.row)
        }
        
        DispatchQueue.global().async { [weak self] in
            if let notes = self?.notes {
                SaveAndLoadUtils.save(notes: notes)
            }
            
            DispatchQueue.main.async {
                self?.updateData()
                //self?.editModeOut()
            }
        }
    }
    
    func editor(_ editor: DetailViewController, didUpdate notes: [Note]) {
        self.notes = notes
    }
}


