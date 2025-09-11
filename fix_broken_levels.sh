#!/bin/bash

# Fix all broken JSON files with proper content

# Fix intermediate levels
for i in 02 03 04 05; do
cat > assets/levels/intermediate/intermediate_$i.json << 'INNER_EOF'
{
  "levelId": "intermediate_'${i}'",
  "version": "1.0.0",
  "metadata": {
    "id": "intermediate_'${i}'",
    "title": "Intermediate Circuit '${i}'",
    "description": "Advanced circuit design principles",
    "difficulty": "intermediate",
    "estimatedTime": 300,
    "learningObjectives": ["Circuit analysis", "Component integration"],
    "tags": ["intermediate"],
    "unlocksComponents": [],
    "prerequisites": ["intermediate_'$(($i-1))'"
  },
  "grid": {"width": 14, "height": 10, "background": "circuit_board"},
  "components": {
    "available": [
      {"type": "battery", "quantity": 1, "properties": {"voltage": 12.0}},
      {"type": "resistor", "quantity": 3, "properties": {"resistance": 1000.0}},
      {"type": "capacitor", "quantity": 1, "properties": {"capacitance": 1000e-6}},
      {"type": "wire", "quantity": 12, "properties": {"resistance": 0.01}}
    ],
    "preplaced": []
  },
  "goals": [{
    "id": "circuit_analysis",
    "type": "circuit_analysis",
    "description": "Analyze and complete the intermediate circuit",
    "conditions": {"current_flow": {"minValue": 0.01}}
  }],
  "validation": {
    "circuitRules": ["no_short_circuits", "proper_component_connections"],
    "successConditions": ["all_goals_completed"]
  },
  "tutorial": {"enabled": false, "steps": []},
  "scoring": {
    "maxScore": 1500,
    "timeBonus": {"maxTime": 600, "bonusPerSecond": 1},
    "efficiencyBonus": {"maxComponents": 19, "bonusPerUnusedComponent": 30},
    "starThresholds": {"threeStars": 1200, "twoStars": 900, "oneStar": 600}
  }
}
INNER_EOF
done

# Fix remaining beginner levels
for i in 04 05; do
cat > assets/levels/beginner/beginner_$i.json << 'INNER_EOF'
{
  "levelId": "beginner_'${i}'",
  "version": "1.0.0",
  "metadata": {
    "id": "beginner_'${i}'",
    "title": "Beginner Practice '${i}'",
    "description": "Master core circuit building skills",
    "difficulty": "beginner",
    "estimatedTime": 220,
    "learningObjectives": ["Circuit mastery", "Problem solving"],
    "tags": ["beginner"],
    "unlocksComponents": [],
    "prerequisites": ["beginner_'$(($i-1))'"
  },
  "grid": {"width": 12, "height": 10, "background": "circuit_board"},
  "components": {
    "available": [
      {"type": "battery", "quantity": 2, "properties": {"voltage": 9.0}},
      {"type": "resistor", "quantity": 3, "properties": {"resistance": 470.0}},
      {"type": "capacitor", "quantity": 1, "properties": {"capacitance": 1000e-6}},
      {"type": "wire", "quantity": 15, "properties": {"resistance": 0.01}}
    ],
    "preplaced": []
  },
  "goals": [{
    "id": "circuit_mastery",
    "type": "component_state",
    "description": "Demonstrate circuit building mastery",
    "conditions": {"targetComponent": "led_1", "targetState": "on"}
  }],
  "validation": {
    "circuitRules": ["no_short_circuits", "proper_component_connections"],
    "successConditions": ["all_goals_completed"]
  },
  "tutorial": {"enabled": false, "steps": []},
  "scoring": {
    "maxScore": 1400,
    "timeBonus": {"maxTime": 400, "bonusPerSecond": 2},
    "efficiencyBonus": {"maxComponents": 21, "bonusPerUnusedComponent": 30},
    "starThresholds": {"threeStars": 1100, "twoStars": 900, "oneStar": 700}
  }
}
INNER_EOF
done

# Fix remaining advanced levels  
for i in 02 03; do
cat > assets/levels/advanced/advanced_$i.json << 'INNER_EOF'
{
  "levelId": "advanced_'${i}'",
  "version": "1.0.0",
  "metadata": {
    "id": "advanced_'${i}'",
    "title": "Advanced Design '${i}'",
    "description": "Complex circuit design challenges",
    "difficulty": "advanced",
    "estimatedTime": 600,
    "learningObjectives": ["Advanced circuit design", "Complex analysis"],
    "tags": ["advanced"],
    "unlocksComponents": [],
    "prerequisites": ["advanced_'$(($i-1))'"
  },
  "grid": {"width": 16, "height": 12, "background": "circuit_board"},
  "components": {
    "available": [
      {"type": "battery", "quantity": 1, "properties": {"voltage": 15.0}},
      {"type": "resistor", "quantity": 4, "properties": {"resistance": 1000.0}},
      {"type": "capacitor", "quantity": 2, "properties": {"capacitance": 10e-6}},
      {"type": "inductor", "quantity": 1, "properties": {"inductance": 0.01}},
      {"type": "wire", "quantity": 15, "properties": {"resistance": 0.01}}
    ],
    "preplaced": []
  },
  "goals": [{
    "id": "advanced_design",
    "type": "circuit_analysis",
    "description": "Design and analyze complex circuits",
    "conditions": {"frequency_response": {"targetFrequency": 1000}}
  }],
  "validation": {
    "circuitRules": ["no_short_circuits", "proper_component_connections"],
    "successConditions": ["all_goals_completed"]
  },
  "tutorial": {"enabled": false, "steps": []},
  "scoring": {
    "maxScore": 2000,
    "timeBonus": {"maxTime": 900, "bonusPerSecond": 1},
    "efficiencyBonus": {"maxComponents": 23, "bonusPerUnusedComponent": 25},
    "starThresholds": {"threeStars": 1600, "twoStars": 1200, "oneStar": 800}
  }
}
INNER_EOF
done

# Create expert_03, expert_04, expert_05
for i in 03 04 05; do
cat > assets/levels/expert/expert_$i.json << 'INNER_EOF'
{
  "levelId": "expert_'${i}'",
  "version": "1.0.0",
  "metadata": {
    "id": "expert_'${i}'",
    "title": "Expert Challenge '${i}'",
    "description": "Master-level circuit design and analysis",
    "difficulty": "expert",
    "estimatedTime": 900,
    "learningObjectives": ["Expert circuit design", "Advanced analysis"],
    "tags": ["expert"],
    "unlocksComponents": [],
    "prerequisites": ["expert_'$(($i-1))'"
  },
  "grid": {"width": 20, "height": 16, "background": "circuit_board"},
  "components": {
    "available": [
      {"type": "operational_amplifier", "quantity": 2, "properties": {"gain": 1.0}},
      {"type": "resistor", "quantity": 6, "properties": {"resistance": 10000.0}},
      {"type": "capacitor", "quantity": 3, "properties": {"capacitance": 100e-9}},
      {"type": "wire", "quantity": 25, "properties": {"resistance": 0.01}}
    ],
    "preplaced": []
  },
  "goals": [{
    "id": "expert_design",
    "type": "circuit_analysis",
    "description": "Design and analyze expert-level circuits",
    "conditions": {"frequency_response": {"targetFrequency": 1000, "targetGain": 3.0}}
  }],
  "validation": {
    "circuitRules": ["no_short_circuits", "proper_component_connections"],
    "successConditions": ["all_goals_completed"]
  },
  "tutorial": {"enabled": false, "steps": []},
  "scoring": {
    "maxScore": 3000,
    "timeBonus": {"maxTime": 1200, "bonusPerSecond": 1},
    "efficiencyBonus": {"maxComponents": 36, "bonusPerUnusedComponent": 20},
    "starThresholds": {"threeStars": 2400, "twoStars": 1800, "oneStar": 1200}
  }
}
INNER_EOF
done

