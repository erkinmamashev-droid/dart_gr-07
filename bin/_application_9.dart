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
  invisibility,
  gambling 
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
    boss.health = max(0, boss.health - damage); 
  }

  void applySuperPower(Boss boss, List<Hero> heroes);
}

class Boss extends GameCharacter {
  SuperAbility? defence;
  bool isStunned = false;

  Boss(super.name, super.health, super.damage);

  void chooseDefence() {
    List<SuperAbility> validDefences = [
      SuperAbility.criticalDamage,
      SuperAbility.boost,
      SuperAbility.blockAndRevert,
      SuperAbility.stun,
      SuperAbility.dodge,
      SuperAbility.shuriken,
      SuperAbility.gambling
    ];
    defence = validDefences[RpgGame.random.nextInt(validDefences.length)];
  }

  void attack(List<Hero> heroes) {
    if (isStunned) {
      print('$name is stunned and skips this round!');
      isStunned = false; 
      return;
    }

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
        
        if (defence == h.ability) {
          finalDamage = (finalDamage * 0.5).toInt();
          print('$name blocked 50% damage from ${h.name} due to aura!');
        }

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
          int boost = RpgGame.random.nextInt(3) + 2; 
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
      if (h.health <= 0 && h != this && h is! Witcher) { 
        h.health = 100;
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
      boss.health = max(0, boss.health - (damage * 2));
      print('$name dealt Critical Damage: ${damage * 2}');
    }
  }
}

class Berserk extends Hero {
  Berserk(String name) : super(name, 260, 10, SuperAbility.blockAndRevert);
  @override
  void applySuperPower(Boss boss, List<Hero> heroes) {
    if (health <= 0) return; 
    if (lastTakenDamage > 0) {
      boss.health = max(0, boss.health - lastTakenDamage);
      print('$name returned $lastTakenDamage damage back to the boss!');
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
        int healAmount = RpgGame.random.nextInt(3) + 2;
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
    health += 5;
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
        boss.health = max(0, boss.health - accumulatedDamage);
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
      boss.health = max(0, boss.health - 100);
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
      boss.health = max(0, boss.health - 25);
      print('$name threw a Virus Shuriken! Dealt 25 damage to the boss.');
    } else {
      boss.health += 15;
      print('$name threw a Vaccine Shuriken! Healed the boss for 15 HP.');
    }
  }
}

class Ludoman extends Hero {
  Ludoman(String name) : super(name, 260, 13, SuperAbility.gambling);

  @override
  void applySuperPower(Boss boss, List<Hero> heroes) {
    if (health <= 0) return;

    int die1 = RpgGame.random.nextInt(6) + 1;
    int die2 = RpgGame.random.nextInt(6) + 1;

    print('$name rolled dice: [$die1] and [$die2]');

    if (die1 == die2) {
      int product = die1 * die2;
      boss.health = max(0, boss.health - product);
      print('🎰 JACKPOT! Dice matched. $name dealt $product damage to the boss!');
    } else {
      int sum = die1 + die2;
      List<Hero> aliveTeammates = heroes.where((h) => h.health > 0 && h != this).toList();

      if (aliveTeammates.isNotEmpty) {
        Hero randomTeammate = aliveTeammates[RpgGame.random.nextInt(aliveTeammates.length)];
        randomTeammate.health = max(0, randomTeammate.health - sum);
        print('❌ Unlucky! Dice didn\'t match. $name hit teammate ${randomTeammate.name} for $sum damage!');
      } else {
        print('$name wanted to hit a teammate, but everyone else is already dead!');
      }
    }
  }
}

class RpgGame {
  static int roundNumber = 0; 
  static final Random random = Random(); 

  static void line() {
    print('\n------------------------------\n');
  }

  static void playRound(Boss boss, List<Hero> heroes) {
    roundNumber++;
    print('--- ROUND $roundNumber ---');
    
    boss.chooseDefence();
    
    for (var hero in heroes) {
      if (hero.health > 0) {
        hero.applySuperPower(boss, heroes);
      }
    }

    boss.attack(heroes);

    for (var hero in heroes) {
      if (hero.health > 0 && boss.health > 0) {
        hero.attack(boss);
      }
      if (hero is Bomber) {
        hero.applySuperPower(boss, heroes);
      }
    }

    printStatus(boss, heroes);
  }

  static void printStatus(Boss boss, List<Hero> heroes) {
    print('${boss.name} HP: ${boss.health} [Defence: ${boss.defence?.name}]');
    for (var hero in heroes) {
      print('${hero.name} HP: ${hero.health} (Damage: ${hero.damage})');
    }
    line();
  }

  static void startGame() {
    Boss boss = Boss('Org', 4200, 63); 
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
      Bomber('Bomber Fuse'),  
      Reaper('Reaper Grim'), 
      Samurai('Samurai Jack'), 
      Avrora('Avrora Night'),
      Ludoman('Ludoman Vegas') 
    ];

    printStatus(boss, heroes);

    while (boss.health > 0 && heroes.any((h) => h.health > 0 && h.damage > 0)) {
      playRound(boss, heroes);
    }

    if (boss.health <= 0) {
      print('HEROES WON THE GAME!!! 🎉');
    } else {
      print('BOSS WON THE GAME... 💀');
    }
  }
}

void main() {
  RpgGame.startGame();
}