import 'package:flutter/material.dart';

void main() {
  runApp(BudgetTrackerApp());
}

class BudgetTrackerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Budget Tracker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Category> categories = [
    Category('Food', 0),
    Category('Transportation', 0),
    Category('Entertainment', 0),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Budget Tracker'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'User Information',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'Expense Total: \$${getTotalExpense()}',
              style: TextStyle(fontSize: 18),
            ),
          ),
          SizedBox(height: 16.0),
          Expanded(
            child: ListView.builder(
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                return ListTile(
                  title: Text(category.name),
                  subtitle: Text('Total Expense: \$${category.totalExpense}'),
                  onTap: () {
                    // Reset the total expenses to zero before showing the ExpenseScreen
                    category.totalExpense = 0;
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ExpenseScreen(category: category),
                      ),
                    ).then((value) {
                      // After returning from ExpenseScreen, update the total expense
                      setState(() {});
                    });
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  double getTotalExpense() {
    double totalExpense = 0;
    for (var category in categories) {
      totalExpense += category.totalExpense;
    }
    return totalExpense;
  }
}

class Category {
  final String name;
  double totalExpense;
  List<Expense> expenses;

  Category(this.name, this.totalExpense) : expenses = [];

  void addExpense(Expense expense) {
    expenses.add(expense);
    totalExpense += expense.expenseValue;
  }

  void deleteExpense(Expense expense) {
    expenses.remove(expense);
    totalExpense -= expense.expenseValue;
  }
}

class Expense {
  final double expenseValue;
  final String description;

  Expense(this.expenseValue, this.description);
}

class ExpenseScreen extends StatefulWidget {
  final Category category;

  ExpenseScreen({required this.category});

  @override
  _ExpenseScreenState createState() => _ExpenseScreenState();
}

class _ExpenseScreenState extends State<ExpenseScreen> {
  late TextEditingController expenseValueController;
  late TextEditingController descriptionController;

  @override
  void initState() {
    super.initState();
    expenseValueController = TextEditingController();
    descriptionController = TextEditingController();
  }

  @override
  void dispose() {
    expenseValueController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  double getVisibleExpensesTotal() {
    double visibleExpensesTotal = 0;
    for (var expense in widget.category.expenses) {
      visibleExpensesTotal += expense.expenseValue;
    }
    return visibleExpensesTotal;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category.name),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Total Expense: \$${getVisibleExpensesTotal()}',
              style: TextStyle(fontSize: 18),
            ),
          ),
          SizedBox(height: 16.0),
          Expanded(
            child: ListView.builder(
              itemCount: widget.category.expenses.length,
              itemBuilder: (context, index) {
                final expense = widget.category.expenses[index];
                return ListTile(
                  title: Text('Expense ${index + 1}'),
                  subtitle: Text('Details: ${expense.description}'),
                  trailing: Text('\$${expense.expenseValue.toStringAsFixed(2)}'),
                  onTap: () {
                    // Show delete confirmation dialog
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text('Delete Expense'),
                        content: Text('Are you sure you want to delete this expense?'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text('Cancel'),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                // Delete expense from category
                                widget.category.deleteExpense(expense);
                              });
                              Navigator.of(context).pop();
                            },
                            child: Text('Delete'),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AddExpensePopup(category: widget.category),
                ).then((value) {
                  // After returning from AddExpensePopup, update the total expense
                  setState(() {});
                });
              },
              child: Text('Add Expense'),
            ),
          ),
        ],
      ),
    );
  }
}

class AddExpensePopup extends StatefulWidget {
  final Category category;

  AddExpensePopup({required this.category});

  @override
  _AddExpensePopupState createState() => _AddExpensePopupState();
}

class _AddExpensePopupState extends State<AddExpensePopup> {
  late TextEditingController expenseValueController;
  late TextEditingController descriptionController;

  @override
  void initState() {
    super.initState();
    expenseValueController = TextEditingController();
    descriptionController = TextEditingController();
  }

  @override
  void dispose() {
    expenseValueController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add Expense'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: expenseValueController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: 'Expense Value'),
          ),
          TextField(
            controller: descriptionController,
            decoration: InputDecoration(labelText: 'Description'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            final double expenseValue = double.tryParse(expenseValueController.text) ?? 0;
            final String description = descriptionController.text;
            if (expenseValue > 0) {
              setState(() {
                // Add expense to the category's expenses list
                widget.category.addExpense(Expense(expenseValue, description));
              });
              Navigator.of(context).pop();
            } else {
              // Show an error message if the entered expense is not valid
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Invalid Expense Value'),
                  content: Text('Please enter a valid expense value.'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text('OK'),
                    ),
                  ],
                ),
              );
            }
          },
          child: Text('Add'),
        ),
      ],
    );
  }
}