import 'package:dart_application_4/dart_application_4.dart' as dart_application_4;

int totalCalls = 0;

void greet() {
  totalCalls++;
  print("Hello! Welcome to Dart programming!");
}

void introduce(String name, int age) {
  totalCalls++;
  print("My name is $name and i am $age years old.");
}

int addNumbers(int a, int b) {
  totalCalls++;
  return a + b;
}

double calculateDiscount({
  required double price,
  double discount = 0,
  double tax = 0,
}) {
  totalCalls++;
  return price -
      (price * discount / 100) +
      (price * tax / 100);
}

void main (){
  greet();
  greet();
  greet();

  print('');

  introduce('Alex', 25);
  introduce('John', 30);
  introduce('Emma', 22);

  print('');

  int sum = addNumbers(5, 8);
  print('Sum of 5 and 8 is $sum.');
  
  double price1 = calculateDiscount(price: 100);
  print('Final price: \$${price1}');

  double price2 = calculateDiscount(
    price: 100,
    discount: 10,
    );
    print('Final price: \$${price2}');

    double price3 = calculateDiscount(
      price: 100,
      discount: 10,
      tax: 5,
    );
  print('Final price: \$${price3}');

  print('');
  print('Total function calls: $totalCalls');
}