import 'dart:io';

void main() {
  print("Hello User 👋");
  print("Simple Calculator");

  // Taking input
  stdout.write("Enter first number: ");
  double num1 = double.parse(stdin.readLineSync()!);

  stdout.write("Enter operator (+, -, *, /): ");
  String operator = stdin.readLineSync()!;

  stdout.write("Enter second number: ");
  double num2 = double.parse(stdin.readLineSync()!);

  // Perform calculation
  double result = calculate(num1, num2, operator);

  print("Result: $result");
}

// Function for calculation
double calculate(double a, double b, String op) {
  switch (op) {
    case '+':
      return add(a, b);
    case '-':
      return subtract(a, b);
    case '*':
      return multiply(a, b);
    case '/':
      return divide(a, b);
    default:
      print("Invalid operator!");
      return 0;
  }
}

// Arithmetic functions
double add(double a, double b) => a + b;

double subtract(double a, double b) => a - b;

double multiply(double a, double b) => a * b;

double divide(double a, double b) {
  if (b == 0) {
    print("Error: Division by zero!");
    return 0;
  }
  return a / b;
}
