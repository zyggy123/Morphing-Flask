

```markdown
# 🧪 Eluna Morphing Flask System

A professional-grade custom item system for **AzerothCore** and **Eluna Lua Engine** (WotLK 3.3.5a). This system allows players to transform into various NPC models using a chargeable flask while maintaining full character control.

---

## 📖 What is this?
This system introduces two custom items to your World of Warcraft server:
1.  **Morphing Flask**: A magical container that transforms your character into a random creature. It uses a specialized "Illusion" spell that allows you to jump, cast spells, and attack normally.
2.  **Flask Recharger**: A utility item used to refill the flask's charges using reagents like Infinite Dust.

---

## ⚙️ Prerequisites
Before installing, ensure your server meets these requirements:
* **Emulator**: AzerothCore or TrinityCore.
* **Scripting Engine**: **Eluna Lua Engine** must be compiled and enabled within your server core.
* **Database**: Access to your `world` database (via HeidiSQL, Navicat, etc.).

---

## 🛠️ Installation Steps

### 1. Database Import (SQL)
You must add the custom items to your server's database so the core can recognize them.
1.  Open your database management tool (like HeidiSQL).
2.  Connect to your **`world`** database.
3.  Open a new Query tab and paste the following code:

```sql
-- Step 1: Remove existing entries to prevent duplicates
DELETE FROM `item_template` WHERE `entry` IN (900001, 900002);

-- Step 2: Create Morphing Flask (ID: 900001)
-- Uses Dummy Spell 483 to ensure it is clickable without default effects
INSERT INTO `item_template` (`entry`, `class`, `subclass`, `name`, `displayid`, `Quality`, `Flags`, `BuyCount`, `BuyPrice`, `SellPrice`, `InventoryType`, `ItemLevel`, `RequiredLevel`, `maxcount`, `stackable`, `spellid_1`, `description`) 
VALUES (900001, 4, 0, 'Morphing Flask', 43499, 4, 64, 1, 0, 0, 0, 80, 1, 0, 1, 483, 'Right-click to transform. Costs 1 charge.');

-- Step 3: Create Flask Recharger (ID: 900002)
INSERT INTO `item_template` (`entry`, `class`, `subclass`, `name`, `displayid`, `Quality`, `Flags`, `BuyCount`, `BuyPrice`, `SellPrice`, `InventoryType`, `ItemLevel`, `RequiredLevel`, `maxcount`, `stackable`, `spellid_1`, `description`) 
VALUES (900002, 3, 0, 'Flask Recharger', 20413, 3, 64, 1, 0, 0, 0, 80, 1, 0, 10, 483, 'Use to refill the Morphing Flask using Infinite Dust.');

```

4. Execute the query.
5. **RESTART your worldserver** or use `.reload item_template` in-game (Restart is recommended for new items).

### 2. Lua Script Setup

1. Navigate to your server's root folder.
2. Open the `lua_scripts` directory.
3. Create a new file named `MorphingFlask.lua`.
4. Paste the full Lua code provided in this repository into that file.
5. Save and close.
6. Type `.reload eluna` in-game to activate the script immediately.

---

## 🎮 How to Use

### Transforming

* Ensure your **Morphing Flask** has charges (check your chat messages).
* **Right-click** the flask in your bags.
* You will gain an **Illusion buff** (30 mins) and a random appearance.
* Each use consumes **1 charge**.

### Cancelling

* You can end the morph early by **right-clicking the buff icon** in the top-right of your UI.
* Alternatively, use the flask again while transformed to cancel.

### Recharging

* Carry **Infinite Dust** (Item ID: 34054) in your inventory.
* **Right-click** the **Flask Recharger**.
* It will automatically consume dust and add charges (up to 5) to your flask.

---

## 🤝 Credits

Developed for the **AzerothCore** / **Eluna** community.
