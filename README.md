"# Caught-the-Thief-Game" 
# Police and Thief Game

## Description
A turn-based multiplayer game where each player is assigned one of four unique roles: **King**, **Police**, **Robber**, or **Thief**. Each role has specific objectives and can earn points based on their actions during each round. The game proceeds until a player reaches a target score to win.

## Game Rules

### 1. **Roles and Objectives**

- **King**: The King’s goal is to avoid being involved in any direct action. They simply survive the round and earn points.
- **Police**: The Police aim to identify and catch the Thief by guessing which player holds the Thief role.
- **Robber**: The Robber doesn’t actively pursue any role but benefits by remaining undiscovered, supporting the Thief’s disguise.
- **Thief**: The Thief tries to avoid detection by the Police to continue earning points.

### 2. **Point System**

#### Points Awarded per Role:
- **King**:
  - Gains **1200 points** each round by avoiding direct action.
  
- **Police**:
  - Gains **900 points** if they successfully identify the Thief.
  - No points are awarded if the Police guess incorrectly.

- **Thief**:
  - Gains **900 points** if they avoid detection by the Police.

- **Robber**:
  - Gains **400 points** each round, regardless of other actions, if they remain undiscovered.

### 3. **Gameplay and Rounds**

- **Round Start**:
  - At the start of each round, roles are randomly assigned to each player (King, Police, Robber, or Thief).
  
- **Police Guess**:
  - If the Police is a human player, they must choose one of the other players to guess as the Thief.
  - If the Police role is assigned to a computer, it automatically guesses the Thief.
  - The **guess button** is disabled if a computer is playing as the Police to streamline gameplay.

- **Scoring**:
  - After the Police makes their guess, points are awarded according to the outcomes:
    - If the Police guesses the Thief correctly, they earn **900 points**.
    - If the Police guesses incorrectly, the Thief earns **900 points**.
    - The Robber earns **400 points** each round, regardless of the Police’s guess.
    - The King automatically earns **1200 points** each round.

### 4. **Game End**

- The game proceeds in rounds, with scores accumulating for each player.
- The first player to reach a target score (e.g., **5000 points**) is declared the winner, and the game ends.

### 5. **Special Conditions**

- If the Police role is held by a computer, a message will display the computer’s guess instead of allowing a manual guess.
- The game board shows only the **King** and **Police** roles to all players initially; roles are revealed only after the Police makes a guess.

---

This layout should make the rules clear and engaging for anyone reading your GitHub README, explaining each role's point acquisition and round-by-round progression in detail.



