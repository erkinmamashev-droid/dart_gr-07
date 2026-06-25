import 'dart:math';

enum SuperAbility {
  criticalDamage,
  heal,
  healSelf,
  boost,
  blockAndRevert,
  stun,
  dodge,
  resurrection,
  explode,
  reap,
  shuriken,
  invisibility 
}

abstract class GameCharacter {
  String name;
  int health;
  int damage;

  GameCharacter(this.name, this.health, this.damage);

  bool get isAlive => health > 0;
}

abstract class Hero extends GameCharacter {
  SuperAbility ability;
  int lastTakenDamage = 0;
  int baseDamage; 

  Hero(super.name, super.health, super.damage, this.ability) : baseDamage = damage;

  void attack(Boss boss) {
    if (health <= 0) return; 
    boss.health -= damage;
  }

  void applySuperPower(Boss boss, List<Hero> heroes);
}

class Boss extends GameCharacter {
  SuperAbility? defence;
  bool isStunned = false;

  Boss(super.name, super.health, super.damage);

  void chooseDefence() {
    defence = SuperAbility.values[RpgGame.random.nextInt(SuperAbility.values.length)];
  }

  void attack(List<Hero> heroes) {
    Golem? golem;
    for (var h in heroes) {
      if (h is Golem && h.health > 0) {
        golem = h;
        break;
      }
    }

    for (var h in heroes) {
      if (h.health > 0) {
        if (h is Lucky) {
          if (RpgGame.random.nextInt(100) < 25) {
            print('${h.name} dodged the attack!');
            continue; 
          }
        }

        if (h is Avrora && h.invisibleRounds > 0) {
          h.accumulatedDamage += damage; 
          continue; 
        }

        int finalDamage = damage;
        h.lastTakenDamage = finalDamage;

        if (golem != null && h != golem) {
          int redirectedDamage = finalDamage ~/ 5; 
          finalDamage -= redirectedDamage;

          golem.health = max(0, golem.health - redirectedDamage);
          if (golem.health <= 0) {
            golem = null;
          }
        }

        h.health = max(0, h.health - finalDamage); 
      }
    }
  }
}


class Magic extends Hero {
  Magic(String name) : super(name, 260, 10, SuperAbility.boost);

  @override
  void applySuperPower(Boss boss, List<Hero> heroes) {
    if (health <= 0) return; 
    if (RpgGame.roundNumber <= 4) {
      for (var h in heroes) {
        if (h.health > 0 && h != this) {
          int boost = RpgGame.random.nextInt(3) + 2; // Чуть снизил бафф мага для баланса
          h.damage += boost;
          h.baseDamage += boost; 
        }
      }
    }
  }
}

class Golem extends Hero {
  Golem(String name) : super(name, 500, 5, SuperAbility.blockAndRevert); 
  @override
  void applySuperPower(Boss boss, List<Hero> heroes) {}
}

class Lucky extends Hero {
  Lucky(String name) : super(name, 240, 12, SuperAbility.dodge);
  @override
  void applySuperPower(Boss boss, List<Hero> heroes) {}
}

class Witcher extends Hero {
  bool hasResurrected = false;
  Witcher(String name) : super(name, 250, 0, SuperAbility.resurrection);

  @override
  void attack(Boss boss) {}

  @override
  void applySuperPower(Boss boss, List<Hero> heroes) {
    if (health <= 0 || hasResurrected) return;
    for (var h in heroes) {
      if (h.health <= 0 && h != this) {
        h.health = 150; 
        print('$name sacrificed himself to resurrect ${h.name}');
        health = 0;        
        hasResurrected = true;
        break;
      }
    }
  }
}

class Thor extends Hero {
  Thor(String name) : super(name, 260, 14, SuperAbility.stun);

  @override
  void applySuperPower(Boss boss, List<Hero> heroes) {
    if (health <= 0) return;
    if (RpgGame.random.nextBool()) {
      boss.isStunned = true;
      print('$name stunned the boss!');
    }
  }
}

class Warrior extends Hero {
  Warrior(String name) : super(name, 280, 15, SuperAbility.criticalDamage);
  @override
  void applySuperPower(Boss boss, List<Hero> heroes) {
    if (health <= 0) return; 
    if (RpgGame.random.nextInt(100) < 30) {
      boss.health -= damage * 2;
    }
  }
}

class Berserk extends Hero {
  Berserk(String name) : super(name, 260, 10, SuperAbility.blockAndRevert);
  @override
  void applySuperPower(Boss boss, List<Hero> heroes) {
    if (health <= 0) return; 
    if (lastTakenDamage > 0) {
      boss.health -= lastTakenDamage;
      lastTakenDamage = 0; 
    }
  }
}

class ExperiencedMedic extends Hero {
  ExperiencedMedic(String name) : super(name, 250, 5, SuperAbility.heal);

  @override
  void applySuperPower(Boss boss, List<Hero> heroes) {
    if (health <= 0) return; 
    for (var h in heroes) {
      if (h.health > 0 && h != this && h.health < 200) {
        int healAmount = RpgGame.random.nextInt(3) + 1;
        h.health += healAmount;
      }
    }
  }
}

class NoviceMedic extends Hero {
  NoviceMedic(String name) : super(name, 230, 5, SuperAbility.healSelf);

  @override
  void applySuperPower(Boss boss, List<Hero> heroes) {
    if (health <= 0) return; 
    health += 1;
  }
}

class Avrora extends Hero {
  bool hasUsedInvisibility = false;
  int invisibleRounds = 0;
  int accumulatedDamage = 0;

  Avrora(String name) : super(name, 250, 12, SuperAbility.invisibility);

  @override
  void applySuperPower(Boss boss, List<Hero> heroes) {
    if (health <= 0) return;

    if (!hasUsedInvisibility && health < 100) {
      invisibleRounds = 2;
      hasUsedInvisibility = true;
      print('$name went into invisibility for 2 rounds!');
      return;
    }

    if (invisibleRounds > 0) {
      invisibleRounds--;
      if (invisibleRounds == 0 && accumulatedDamage > 0) {
        boss.health -= accumulatedDamage;
        print('$name returned $accumulatedDamage accumulated damage to the boss!');
        accumulatedDamage = 0; 
      }
    }
  }
}

class Bomber extends Hero {
  bool hasExploded = false;
  Bomber(String name) : super(name, 230, 12, SuperAbility.explode);

  @override
  void applySuperPower(Boss boss, List<Hero> heroes) {
    if (health <= 0 && !hasExploded) {
      boss.health -= 100;
      hasExploded = true;
      print('$name exploded upon death and dealt 100 damage to the boss!');
    }
  }
}

class Reaper extends Hero {
  final int maxHP = 270;
  Reaper(String name) : super(name, 270, 12, SuperAbility.reap);

  @override
  void applySuperPower(Boss boss, List<Hero> heroes) {
    if (health <= 0) return;

    if (health < (maxHP * 0.15)) {
      damage = baseDamage * 3;
      print('$name enters Frenzy! Damage tripled to $damage.');
    } else if (health < (maxHP * 0.30)) {
      damage = baseDamage * 2;
      print('$name enters Enrage! Damage doubled to $damage.');
    } else {
      damage = baseDamage; 
    }
  }
}

class Samurai extends Hero {
  Samurai(String name) : super(name, 260, 14, SuperAbility.shuriken);

  @override
  void applySuperPower(Boss boss, List<Hero> heroes) {
    if (health <= 0) return;

    if (RpgGame.random.nextBool()) {
      boss.health -= 25;
      print('$name threw a Virus Shuriken! Dealt 25 damage to the boss.');
    } else {
      boss.health += 15;
      print('$name threw a Vaccine Shuriken! Healed the boss for 15 HP.');
    }
  }
}


class RpgGame {
  static int roundNumber = 0; 
  static final Random random = Random(); 

  static void line() {
    print('\n------------------------------\n');
  }

  static void startGame() {
    Boss boss = Boss('Org', 3300, 54); 
    roundNumber = 0; 

    List<Hero> heroes = [
      Warrior('Warrior Alpha'),
      Magic('Magic Merlin'),
      Berserk('Berserk Gutz'),
      ExperiencedMedic('Medic Haus (PRO)'), 
      NoviceMedic('Medic Retchet (NOOB)'), 
      Golem('Golem Stone'),     
      Lucky('Lucky Clover'),    
      Witcher('Witcher Geralt'),
      Thor('Thor Odinson'),     
      Bomber('Bomber Fuse'), // Добавлен Подрывник  
      Reaper('Reaper Grim'), // Добавлен Жнец
      Samurai('Samurai Jack'), // Добавлен Самурай
      Avrora('Avrora Night') // Добавлена Аврора 
    ];

    while (boss.health > 0 && heroes.any((h) => h.health > 0)) {
      roundNumber++;

      print('ROUND $roundNumber ----------------');
      boss.chooseDefence();

      print('Boss ${boss.name} health: ${boss.health} damage: ${boss.damage} defence: ${boss.defence?.name}');
      line();

      if (boss.isStunned) {
        print('Босс пропустил раунд из-за оглушения!');
        boss.isStunned = false; 
      } else {
        boss.attack(heroes); 
      }

      for (var h in heroes) {
        if (h.health > 0) { 
          if (boss.defence != h.ability) {
            h.attack(boss);
          }
        }
        boss.defence != h.ability ? h.applySuperPower(boss, heroes) : null;
      }

      line();
      print('СТАТИСТИКА РАУНДА:');
      for (var h in heroes) {
        print('${h.name} health: ${h.health} damage: ${h.damage} ${h.health <= 0 ? "[МЁРТВ]" : ""}');
      }

      line();
    }

    print(boss.health <= 0 ? 'HEROES WIN 🏆' : 'BOSS WIN 👹');
  }
}

void main() {
  RpgGame.startGame();
}