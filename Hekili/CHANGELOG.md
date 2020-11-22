# Hekili

## [v9.0.2-1.0.3](https://github.com/Hekili/hekili/tree/v9.0.2-1.0.3) (2020-11-20)
[Full Changelog](https://github.com/Hekili/hekili/compare/v9.0.2-1.0.2...v9.0.2-1.0.3) [Previous Releases](https://github.com/Hekili/hekili/releases)

- Merge branch 'shadowlands' of https://github.com/Hekili/hekili into shadowlands  
- Elemental:  Fix Echoing Shock usage.  
- Merge pull request #556 from ShmooDude/Feral-damage-calculations  
- Calculate ability damage  
    Should have accurate calculations for Rake, Shred, Swipe(Cat), Brutal Slash, Moonfire(Cat), Thrash(Cat), and Rip.  Pre-patch accurate calculation for Ferocious Bite.  
    Stats:  
    Critical Strike chance (with 2x multiplier for Shred)  
    Mastery  
    Versatility  
    Armor (For physical damage, 0.7 multiplier)  
    Buffs:  
    Tiger's Fury  
    Savage Roar  
    Moment of Clarity (Note: talent is checked in class.aura.clearcasting.multiplier so no need for checks in the damage function)  
    Bloodtalons  
    Stealth (Prowl, Shadowmeld, Berserk, Incarnation, Sudden Ambush)  
    Non-Aura Talents:  
    Sabertooth  
    Soul of the Forest  
    Other:  
    Feral Aura (Blizzard's "tuning" knob)  
    TODO: Implement Taste For Blood soulbind conduit (x% increased Ferocious Bite damage per bleed (thrash\_cat, rake, rip or primal\_wrath)  
- Store/Use registered aura for damage multipliers  
    class.auras.<aura\_name>.multiplier stores the multiplier effect of the given aura.    
    This allows the use of functions to calculate the proper multiplier value for things like Carnivorous Instincts or Moment of Clarity.  
- Fix thrash\_cat.pmultiplier  
    thrash\_cat, not thrash  
- Update attack\_power  
    UnitWeaponAttackPower() returns WeaponDPS * 6 which is now part of all attack\_power ability calculations  
- Even more debug information.  
- Make pet.X\_elemental automatically swap for primal vs. greater.  
- Merge branch 'shadowlands' of https://github.com/Hekili/hekili into shadowlands  
- Noisier snapshots for Unholy target cycling.  
- Default toggle for Apocalypse only set to Cooldowns without Army of the Damned (may make options weird).  
- Update issue templates  