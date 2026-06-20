// 1️⃣ Интерфейс Switchable
abstract class Switchable {
  void turnOn();
  void turnOff();
}

// 2️⃣ Интерфейс Adjustable
abstract class Adjustable {
  void increase();
  void decrease();
}

// 3️⃣ Миксин BatteryPowered
mixin BatteryPowered {
  int batteryLevel = 100;

  void showBattery() {
    print('Battery level: $batteryLevel%');
  }
}

// 4️⃣ Абстрактный класс Device
abstract class Device implements Switchable {
  final String name;

  Device(this.name);

  void showInfo() {
    print('Device: $name');
  }
}

// 5️⃣ Класс SmartLamp
class SmartLamp extends Device with BatteryPowered implements Adjustable {
  int brightness = 50;

  SmartLamp(String name) : super(name);

  @override
  void turnOn() {
    print('Lamp $name is ON');
  }

  @override
  void turnOff() {
    print('Lamp $name is OFF');
  }

  @override
  void increase() {
    brightness = (brightness + 10).clamp(0, 100);
    print('Brightness increased to $brightness%');
  }

  @override
  void decrease() {
    brightness = (brightness - 10).clamp(0, 100);
    print('Brightness decreased to $brightness%');
  }

  @override
  void showInfo() {
    print('Lamp: $name | Brightness: $brightness%');
  }
}

// 6️⃣ Класс SmartSpeaker
class SmartSpeaker extends Device with BatteryPowered implements Adjustable {
  int volume = 30;

  SmartSpeaker(String name) : super(name);

  @override
  void turnOn() {
    print('Speaker $name is ON');
  }

  @override
  void turnOff() {
    print('Speaker $name is OFF');
  }

  @override
  void increase() {
    volume = (volume + 5).clamp(0, 100);
    print('Volume increased to $volume%');
  }

  @override
  void decrease() {
    volume = (volume - 5).clamp(0, 100);
    print('Volume decreased to $volume%');
  }

  @override
  void showInfo() {
    print('Speaker: $name | Volume: $volume%');
  }
}

// 7️⃣ Класс SmartThermostat
class SmartThermostat extends Device {
  double temperature = 22.0;

  SmartThermostat(String name) : super(name);

  @override
  void turnOn() {
    print('Thermostat $name is ON');
  }

  @override
  void turnOff() {
    print('Thermostat $name is OFF');
  }

  @override
  void showInfo() {
    print('Thermostat: $name | Temperature: $temperature°C');
  }
}

// 8️⃣ Главная функция main
void main() {
  List<Device> smartHomeDevices = [
    SmartLamp('Living Room Light'),
    SmartSpeaker('Kitchen HomePod'),
    SmartThermostat('Nest Bedroom'),
  ];

  for (var device in smartHomeDevices) {
    device.showInfo();
    device.turnOn();

    if (device is Adjustable) {
  (device as Adjustable).increase();
}

    if (device is BatteryPowered) {
  (device as BatteryPowered).showBattery();
}

    print('-----------------------------------');
  }

  print('All devices processed.');
}