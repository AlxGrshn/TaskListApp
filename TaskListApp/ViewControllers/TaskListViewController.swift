//
//  TaskListViewController.swift
//  TaskListApp
//
//  Created by Alexander Grishin on 21.11.2022.
//

import UIKit

class TaskListViewController: UITableViewController {
    
    private let viewContext = StorageManager.shared.persistentContainer.viewContext
    private let cellID = "task"
    private var taskList: [Task] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupNavigationBar()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellID)
        
        StorageManager.shared.fetchData { tasks in
            taskList = tasks
        }
    }
    private func setupNavigationBar() {
        title = "Task List"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.backgroundColor = UIColor(named: "CustomColor")
        
        navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        navBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        
        navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance
        navigationController?.navigationBar.standardAppearance = navBarAppearance
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addNewTask)
        )
        navigationController?.navigationBar.tintColor = .white
    }
    
    @objc private func addNewTask() {
        showAlert(
            withTitle: "New Task",
            withMessage: "What do you want to do?"
        )
    }
    
    private func showAlert(withTitle title: String, withMessage message: String, andText text: String? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let saveAction = UIAlertAction(title: "Save", style: .default) { [unowned self] _ in
            guard let task = alert.textFields?.first?.text, !task.isEmpty else { return }
            if text == nil {
                addTask(task)
            } else {
                updateTask(task)
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)
        
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        alert.addTextField { textField in
            textField.placeholder = "Enter the new task"
            textField.text = text
        }
        present(alert, animated: true)
    }
    
    private func addTask(_ taskName: String) {
        let task = Task(context: viewContext)
        task.title = taskName
        taskList.append(task)
        
        let cellIndex = IndexPath(row: taskList.count - 1, section: 0)
        tableView.insertRows(at: [cellIndex], with: .automatic)
        StorageManager.shared.saveContext()
    }
    
    private func updateTask(_ taskName: String) {
        let cellIndex = IndexPath(row: tableView.indexPathForSelectedRow?.row ?? 6, section: 0)
        taskList[cellIndex.row].title = taskName
        tableView.reloadRows(at: [cellIndex], with: .automatic)
        StorageManager.shared.saveContext()
    }
    
}

extension TaskListViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        taskList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        let task = taskList[indexPath.row]
        var content = cell.defaultContentConfiguration()
        content.text = task.title
        cell.contentConfiguration = content
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        showAlert(
            withTitle: "Update Task",
            withMessage: "Do you want to change the task?",
            andText: taskList[indexPath.row].title
        )
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [unowned self] _, _, _ in
            self.viewContext.delete(self.taskList[indexPath.row])
            self.taskList.remove(at: indexPath.row)
            StorageManager.shared.saveContext()
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        configuration.performsFirstActionWithFullSwipe = true
        return configuration
    }
}
