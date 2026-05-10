<p align="center">
  <img src="https://github.com/zyggy123/Morphing-Flask/blob/main/icon.png" width="200" />
</p>

# 🧪 Eluna Morphing Flask System

A professional-grade custom item system for **AzerothCore** and **Eluna Lua Engine** (WotLK 3.3.5a). This system allows players to transform into various NPC models using a chargeable flask while maintaining full character control.

---

## 📋 Required Information

* **Name**: Eluna Morphing Flask System
* **Description**: A chargeable custom item system allowing players to transform into random, fully-controllable NPC models with persistent visual buffs.
* **Author**: zyggy123
* **License**: [GNU Affero General Public License v3.0](https://www.gnu.org/licenses/agpl-3.0.en.html)

---

## 📖 System Overview

This system introduces two custom items to your World of Warcraft server:

1. **Morphing Flask (Entry: 900001)**: A container that transforms the character into a random creature from a pre-configured list. It uses an "Illusion" spell that permits jumping, casting, and attacking.
2. **Flask Recharger (Entry: 900002)**: A utility tool used to refill flask charges using **Infinite Dust** (Entry: 34054).

---

## ✨ Key Features

* **Random Transformations**: Dynamically selects a Display ID from a configurable list upon use.
* **Full Combat Control**: Uses Spell ID `16739` to ensure the character is not stunned or pacified while transformed.
* **Persistent Visual Buff**: Displays a 30-minute "Illusion" buff that can be cancelled via right-click.
* **Login Persistence**: The system checks for the active buff upon login and re-applies the correct visual model.

---

## 🛠️ Installation Instructions

### 1. Prerequisites

* An **AzerothCore** or **TrinityCore** based server.
* **Eluna Lua Engine** compiled and enabled in your core.

### 2. Database Setup (SQL)

Import the following into your **`world`** database to create the required items:

```sql
-- Remove existing entries to prevent duplicates
DELETE FROM `item_template` WHERE `entry` IN (900001, 900002);

-- Create Morphing Flask (900001)
INSERT INTO `item_template` (`entry`, `class`, `subclass`, `name`, `displayid`, `Quality`, `Flags`, `BuyCount`, `BuyPrice`, `SellPrice`, `InventoryType`, `ItemLevel`, `RequiredLevel`, `maxcount`, `stackable`, `spellid_1`, `description`) 
VALUES (900001, 4, 0, 'Morphing Flask', 43499, 4, 64, 1, 0, 0, 0, 80, 1, 0, 1, 483, 'Right-click to transform. Costs 1 charge.');

-- Create Flask Recharger (900002)
INSERT INTO `item_template` (`entry`, `class`, `subclass`, `name`, `displayid`, `Quality`, `Flags`, `BuyCount`, `BuyPrice`, `SellPrice`, `InventoryType`, `ItemLevel`, `RequiredLevel`, `maxcount`, `stackable`, `spellid_1`, `description`) 
VALUES (900002, 3, 0, 'Flask Recharger', 20413, 3, 64, 1, 0, 0, 0, 80, 1, 0, 10, 483, 'Use to refill the Morphing Flask using Infinite Dust.');

```

### 3. Lua Script Setup

1. Navigate to your server's `lua_scripts` directory.
2. Create a new file named `MorphingFlask.lua`.
3. Paste the full Lua code from this repository into the file.
4. Restart your server or type `.reload eluna` in-game to activate the script.

---

## 🎮 How to Use

1. **Recharge**: Ensure you have **Infinite Dust** in your bags and use the **Flask Recharger** to add charges (up to 5).
2. **Transform**: Right-click the **Morphing Flask** to activate a random transformation.
3. **Cancel**: Right-click the buff icon in the top-right corner or use the flask again to revert to your original form.

---

## 🗑️ Client Cache Note

For the item names and descriptions to appear correctly in-game, you must **close your WoW client** and delete the following file:
`WoW_Folder/Cache/WDB/enUS/itemcache.wdb`
* **Right-click** the **Flask Recharger**.
* It will automatically consume dust and add charges (up to 5) to your flask.

---

## 🤝 Credits

Developed for the **AzerothCore** / **Eluna** community.
