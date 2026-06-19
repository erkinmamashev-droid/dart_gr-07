enum Subject {
  math,
  physics,
  english,
  history,
}

class Person {
  String fullName;
  int age;
  bool isMarried;

  Person(this.fullName, this.age, this.isMarried);

  void introduce() {
    print(
     "Hi! My name is $fullName. I am $age years old. Married: ${isMarried ? 'Yes' : 'No'}.");
  }
}

class Student extends Person {
  Map<Subject, double> marks;

  Student(
    String fullName,
    int age,
    bool isMarried,
    this.marks,
  ) : super(fullName, age, isMarried);

  void showMarks() {
    print('Student: $fullName');

    for (var entry in marks.entries) {
      print('${entry.key.name}: ${entry.value}');
    }
  }

  double calculateAverage() {
    double sum = 0;

    for (var mark in marks.values) {
      sum += mark;
    }

    return sum / marks.length;
  }

  @override
  void introduce() {
    super.introduce();
    print('Average mark: ${calculateAverage()}');
   }
  }

  class Teacher extends Person {
    int experience;

    static double _baseSalary = 50000;

    Teacher(
      String fullName,
      int age,
      bool isMarried,
      this.experience,
    ) : super(fullName, age, isMarried);

    double calculateSalary() {
      double salary = _baseSalary;

      if (experience > 3) {
        for (int year = 4; year <= experience; year++) {
          salary *= 1.05;
        }
      }

      if (isMarried) {
        salary += 5000;
      }

      return salary;
    }

  @override
  void introduce() {
    super.introduce();
    print('Experience: $experience years.');
    print('Salary: ${calculateSalary()}');
   }
 }

 void main() {
  Teacher teacher = Teacher(
    'John Brown', 
    40,
    true, 
    10,
    );

  teacher.introduce();

  print("\n-----------------\n");

  Student student1 = Student(
    'Adam White',
    17,
    false,
    {
      Subject.math: 90,
      Subject.physics: 85,
      Subject.english: 92,
      Subject.history: 89,
    },
  );

  Student student2 = Student(
    'Alice Green',
    18,
    false,
    {
      Subject.math: 95,
      Subject.physics: 88,
      Subject.english: 91,
      Subject.history: 94,
    },
  );

  student1.introduce();
  student1.showMarks();

  print("\n-----------------\n");

  student2.introduce();
  student2.showMarks();
 }