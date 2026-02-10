# Tutorial System Testing Guide

This document describes how to manually test the guided tutorial flow via Old Salt.

## Prerequisites
- Fresh game save (tutorial_completed = false in GameManager)
- GameWorld scene loaded
- NPCManager with Old Salt spawned
- DialogueBox UI present

## Tutorial Flow Test Steps

### 1. Welcome Step
**Expected Behavior:**
- Tutorial starts automatically on new game
- Tutorial tooltip appears with "Welcome to Blueth Farm!"
- Old Salt dialogue appears: "So you're finally here! Your grandmother left you..."
- Player can move with WASD

**Verification:**
- [ ] Tutorial tooltip visible
- [ ] Old Salt welcome dialogue displays
- [ ] Player movement works

### 2. Journal Step
**Expected Behavior:**
- After moving, next step prompts to press J
- Old Salt dialogue: "Good, you know how to get around. Now, your grandmother kept a journal..."
- Journal opens when pressing J

**Verification:**
- [ ] Movement completion detected
- [ ] Old Salt dialogue about journal appears
- [ ] Pressing J opens journal
- [ ] Tutorial advances to next step

### 3. Walk to Dock
**Expected Behavior:**
- Tutorial prompts player to walk to dock
- Objective marker shows dock location (if implemented)
- Step completes when player reaches dock area

**Verification:**
- [ ] Tooltip shows "Walk to the dock"
- [ ] Player can navigate to dock
- [ ] Proximity detection works

### 4. Talk to Old Salt
**Expected Behavior:**
- Tutorial prompts to press E to talk
- Old Salt at dock shows "tutorial_meet_at_dock" dialogue
- Dialogue: "Ah, there you are! I've been waiting for you..."
- Dialogue system enters DIALOGUE game state

**Verification:**
- [ ] Old Salt visible at dock
- [ ] E prompt appears near Old Salt
- [ ] Correct tutorial dialogue plays
- [ ] DialogueBox displays properly

### 5. Open Inventory
**Expected Behavior:**
- After dock dialogue, tutorial gives seeds
- Old Salt dialogue: "Here, take these. Eelgrass seeds..."
- Inventory contains 10 seagrass_zostera_seed
- Pressing I opens inventory

**Verification:**
- [ ] Seeds added to inventory
- [ ] Old Salt seed dialogue appears
- [ ] Inventory UI opens with I key
- [ ] Seeds visible in inventory

### 6. Plant First Seeds
**Expected Behavior:**
- Old Salt dialogue: "Alright, here's how it works: Press 2 to equip..."
- Player equips seed bag with 2
- Player clicks shallow water to plant
- GameManager.first_plant_done set to true
- After planting, Old Salt congratulates: "There you go! Your first planting..."

**Verification:**
- [ ] Planting instructions dialogue appears
- [ ] Seed bag equips with key 2
- [ ] Click to plant works
- [ ] First plant success detected
- [ ] Congratulations dialogue plays

### 7. Check Dashboard
**Expected Behavior:**
- Tutorial prompts to press Tab
- Old Salt dialogue: "You should know—every bit of seagrass you plant..."
- Carbon Dashboard opens
- Dashboard shows carbon data

**Verification:**
- [ ] Dashboard dialogue appears
- [ ] Tab key opens Carbon Dashboard
- [ ] Tutorial advances to completion

### 8. Tutorial Complete
**Expected Behavior:**
- Old Salt final dialogue: "You're getting the hang of it! Keep planting..."
- Tutorial completion message displays briefly
- GameManager.tutorial_completed = true
- Tutorial system sets tutorial_active = false

**Verification:**
- [ ] Final dialogue from Old Salt
- [ ] Tutorial completion detected
- [ ] Normal gameplay resumes
- [ ] Tutorial doesn't restart on reload

## Common Issues to Check

### DialogueBox Issues
- DialogueBox must have process_mode = PROCESS_MODE_ALWAYS
- DialogueBox must be in "dialogue_box" group
- DialogueBox must be child of GameWorld

### NPCManager Issues
- NPCManager must spawn Old Salt before tutorial starts
- Old Salt must be in "npc_manager" group lookup
- Old Salt position should be accessible (dock location)

### Tutorial System Issues
- TutorialSystem must be in "tutorial_system" group
- Tutorial must check GameManager.tutorial_completed
- Each step must have proper condition checks

### Dialogue Integration Issues
- NPC controller must check tutorial_active flag
- Tutorial dialogue keys must exist in old_salt.tres
- Dialogue formatting must match DialogueBox expectations

## Automated Test Coverage

Run the automated tests with:
```bash
cd game
godot --headless --script addons/gut/gut_cmdln.gd -gconfig=.gutconfig.json -gexit
```

Test file: `tests/test_tutorial_integration.gd`

Tests cover:
- Old Salt has all required tutorial dialogues
- Tutorial system has integration methods
- Tutorial steps are properly defined
- Dialogue format is correct
- Associated quests are configured

## Success Criteria

The tutorial is working correctly if:
1. All 8 tutorial steps complete in sequence
2. Old Salt dialogue appears at appropriate times
3. Player receives seeds and can plant
4. Tutorial state persists correctly
5. Tutorial doesn't restart after completion
6. All automated tests pass
