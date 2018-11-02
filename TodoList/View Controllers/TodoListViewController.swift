import UIKit
import CloudKit

class TodoListViewController: UITableViewController {

    // MARK: - Properties
    private lazy var todos: Todos = {
        var todos = Todos(items: [])
        return todos
    }()
    
    private lazy var footer: TextFieldView = {
        let footer = TextFieldView.nibView
        footer.delegate = self
        return footer
    }()
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchTodos()
        setupUI()
    }
    
    // MARK: - Helpers
    private func setupUI() {

        navigationItem.rightBarButtonItem = editButtonItem

        tableView.register(cellType: ItemTableViewCell.self)
        tableView.tableFooterView = footer
        tableView.estimatedRowHeight = 44
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedSectionFooterHeight = 80
        tableView.sectionFooterHeight = UITableViewAutomaticDimension
        
        title = NSLocalizedString("My List", comment: "")
    }

    private func fetchTodos() {
        CloudKitService().fetchAll(type: Item.self, success: { (records) in
            self.todos = Todos(items: records)
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }) { (error) in
            print(error)
        }
    }

    // MARK: - TableView dataSource Delegate
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todos.items.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: ItemTableViewCell = tableView.dequeueReusableCell(for: indexPath)

        let item = todos.items[indexPath.row]
        cell.set(text: item.title, isCompleted: item.isComplete)

        return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            todos.items.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }

    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    override func tableView(_ tableView: UITableView,
        moveRowAt sourceIndexPath: IndexPath,
        to destinationIndexPath: IndexPath) {
            todos.items.swapAt(sourceIndexPath.row, destinationIndexPath.row)
            todos.save()
    }
    
    // MARK: - TableView Delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Toggle item completion state
        todos.items[indexPath.row].isComplete.toggle()
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }

}

// MARK: - TextFieldViewDelegate Extension
extension TodoListViewController: TextFieldViewDelegate {
    func textField(didEnter text: String) {
        let item = Item(title: text, record: nil)
        todos.items.append(item)
        let newIndex = IndexPath(row: todos.items.count-1, section: 0)
        tableView.beginUpdates()
        tableView.insertRows(at: [newIndex], with: .automatic)
        tableView.endUpdates()
    }
}
