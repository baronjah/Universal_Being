#!/usr/bin/env python3
"""
Universal Creation & Flow System
==============================

Implements the philosophical vision from instructions_05.txt combining:
- Interconnected stories that shape reality
- Cycles, turns, loops of creation and transformation
- Domino effects of cause and consequence
- Universal creation from cosmic to planetary scale
- Time-aware project evolution integration

Based on:
- instructions_05.txt: Human language philosophical framework
- artifact_0.txt: Time-aware project evolution system
- kamisama_tests: Cosmic hierarchy and structure
"""

import json
import time
import random
from datetime import datetime
from pathlib import Path
from typing import Dict, List, Any, Optional
from dataclasses import dataclass, asdict
from enum import Enum

class CreationPhase(Enum):
    """Phases of universal creation cycle"""
    GENESIS = "genesis"
    FORMATION = "formation"
    EXPANSION = "expansion"
    COMPLEXITY = "complexity"
    CONSCIOUSNESS = "consciousness"
    MANIFESTATION = "manifestation"
    TRANSFORMATION = "transformation"
    TRANSCENDENCE = "transcendence"
    UNITY = "unity"
    RENEWAL = "renewal"
    EVOLUTION = "evolution"
    BEYOND = "beyond"

class FlowDirection(Enum):
    """Directions of energy and story flow"""
    INWARD = "inward"
    OUTWARD = "outward"
    CIRCULAR = "circular"
    SPIRAL = "spiral"
    QUANTUM = "quantum"
    DIMENSIONAL = "dimensional"

@dataclass
class Story:
    """Individual story/entity in the interconnected web"""
    id: str
    name: str
    essence: str
    phase: CreationPhase
    energy_level: float
    connections: List[str]
    created_at: datetime
    last_active: datetime
    transformation_count: int = 0
    children_stories: List[str] = None
    parent_stories: List[str] = None
    
    def __post_init__(self):
        if self.children_stories is None:
            self.children_stories = []
        if self.parent_stories is None:
            self.parent_stories = []

@dataclass
class CreationCycle:
    """Represents a complete cycle of creation, transformation, and renewal"""
    cycle_id: str
    phase: CreationPhase
    stories_involved: List[str]
    energy_threshold: float
    duration_seconds: float
    started_at: datetime
    completed_at: Optional[datetime] = None
    resulted_in: List[str] = None
    
    def __post_init__(self):
        if self.resulted_in is None:
            self.resulted_in = []

class UniversalCreationSystem:
    """
    Main system implementing the universal creation philosophy
    Manages interconnected stories, cycles, and reality shaping
    """
    
    def __init__(self, system_root: str = "/mnt/c/Users/Percision 15/universal_creation"):
        self.root = Path(system_root)
        self.root.mkdir(parents=True, exist_ok=True)
        
        # Core data storage
        self.stories_file = self.root / "stories.json"
        self.cycles_file = self.root / "cycles.json"
        self.connections_file = self.root / "reality_web.json"
        self.timeline_file = self.root / "creation_timeline.json"
        
        # Initialize system
        self.stories: Dict[str, Story] = {}
        self.cycles: Dict[str, CreationCycle] = {}
        self.reality_web: Dict[str, List[str]] = {}
        self.creation_timeline: List[Dict] = []
        
        self.load_system_state()
        
        # Integration with project evolution system
        self.evolution_root = Path("/mnt/c/Users/Percision 15/claude_evolution")
        
        print("🌟 Universal Creation System Initialized")
        print("✨ Ready to shape reality through interconnected stories")
    
    def load_system_state(self):
        """Load existing system state from disk"""
        if self.stories_file.exists():
            with open(self.stories_file, 'r') as f:
                stories_data = json.load(f)
                for story_id, data in stories_data.items():
                    # Convert datetime strings back to datetime objects
                    data['created_at'] = datetime.fromisoformat(data['created_at'])
                    data['last_active'] = datetime.fromisoformat(data['last_active'])
                    data['phase'] = CreationPhase(data['phase'])
                    self.stories[story_id] = Story(**data)
        
        if self.cycles_file.exists():
            with open(self.cycles_file, 'r') as f:
                cycles_data = json.load(f)
                for cycle_id, data in cycles_data.items():
                    data['started_at'] = datetime.fromisoformat(data['started_at'])
                    if data['completed_at']:
                        data['completed_at'] = datetime.fromisoformat(data['completed_at'])
                    data['phase'] = CreationPhase(data['phase'])
                    self.cycles[cycle_id] = CreationCycle(**data)
        
        if self.connections_file.exists():
            with open(self.connections_file, 'r') as f:
                self.reality_web = json.load(f)
        
        if self.timeline_file.exists():
            with open(self.timeline_file, 'r') as f:
                self.creation_timeline = json.load(f)
    
    def save_system_state(self):
        """Save current system state to disk"""
        # Convert stories to serializable format
        stories_data = {}
        for story_id, story in self.stories.items():
            story_dict = asdict(story)
            story_dict['created_at'] = story.created_at.isoformat()
            story_dict['last_active'] = story.last_active.isoformat()
            story_dict['phase'] = story.phase.value
            stories_data[story_id] = story_dict
        
        with open(self.stories_file, 'w') as f:
            json.dump(stories_data, f, indent=2)
        
        # Convert cycles to serializable format
        cycles_data = {}
        for cycle_id, cycle in self.cycles.items():
            cycle_dict = asdict(cycle)
            cycle_dict['started_at'] = cycle.started_at.isoformat()
            if cycle.completed_at:
                cycle_dict['completed_at'] = cycle.completed_at.isoformat()
            cycle_dict['phase'] = cycle.phase.value
            cycles_data[cycle_id] = cycle_dict
        
        with open(self.cycles_file, 'w') as f:
            json.dump(cycles_data, f, indent=2)
        
        with open(self.connections_file, 'w') as f:
            json.dump(self.reality_web, f, indent=2)
        
        with open(self.timeline_file, 'w') as f:
            json.dump(self.creation_timeline, f, indent=2)
    
    def create_story(self, name: str, essence: str, initial_phase: CreationPhase = CreationPhase.GENESIS) -> str:
        """
        Create a new story in the universal creation web
        Each story represents an idea, project, concept, or entity
        """
        story_id = f"story_{len(self.stories) + 1}_{int(time.time())}"
        
        now = datetime.now()
        story = Story(
            id=story_id,
            name=name,
            essence=essence,
            phase=initial_phase,
            energy_level=random.uniform(0.1, 1.0),
            connections=[],
            created_at=now,
            last_active=now
        )
        
        self.stories[story_id] = story
        self.reality_web[story_id] = []
        
        # Record in timeline
        self.creation_timeline.append({
            "timestamp": now.isoformat(),
            "event": "story_created",
            "story_id": story_id,
            "name": name,
            "phase": initial_phase.value
        })
        
        self.save_system_state()
        print(f"✨ Created story: {name} ({story_id})")
        print(f"🌱 Essence: {essence}")
        print(f"🔄 Phase: {initial_phase.value}")
        
        return story_id
    
    def connect_stories(self, story1_id: str, story2_id: str, flow_direction: FlowDirection = FlowDirection.CIRCULAR):
        """
        Create connections between stories, enabling energy and influence flow
        This implements the 'interconnected stories' concept from instructions_05
        """
        if story1_id not in self.stories or story2_id not in self.stories:
            raise ValueError("Both stories must exist to create connection")
        
        # Update story connections
        if story2_id not in self.stories[story1_id].connections:
            self.stories[story1_id].connections.append(story2_id)
        
        if story1_id not in self.stories[story2_id].connections:
            self.stories[story2_id].connections.append(story1_id)
        
        # Update reality web
        if story2_id not in self.reality_web[story1_id]:
            self.reality_web[story1_id].append(story2_id)
        
        if story1_id not in self.reality_web[story2_id]:
            self.reality_web[story2_id].append(story1_id)
        
        # Record connection event
        self.creation_timeline.append({
            "timestamp": datetime.now().isoformat(),
            "event": "stories_connected",
            "story1": story1_id,
            "story2": story2_id,
            "flow_direction": flow_direction.value
        })
        
        self.save_system_state()
        
        story1_name = self.stories[story1_id].name
        story2_name = self.stories[story2_id].name
        print(f"🔗 Connected: {story1_name} ↔ {story2_name}")
        print(f"🌊 Flow direction: {flow_direction.value}")
    
    def initiate_creation_cycle(self, triggering_story_id: str) -> str:
        """
        Start a new creation cycle triggered by a story
        Implements the cycles, turns, loops concept from instructions_05
        """
        if triggering_story_id not in self.stories:
            raise ValueError("Triggering story must exist")
        
        cycle_id = f"cycle_{len(self.cycles) + 1}_{int(time.time())}"
        triggering_story = self.stories[triggering_story_id]
        
        # Determine cycle phase based on triggering story
        next_phases = {
            CreationPhase.GENESIS: CreationPhase.FORMATION,
            CreationPhase.FORMATION: CreationPhase.EXPANSION,
            CreationPhase.EXPANSION: CreationPhase.COMPLEXITY,
            CreationPhase.COMPLEXITY: CreationPhase.CONSCIOUSNESS,
            CreationPhase.CONSCIOUSNESS: CreationPhase.MANIFESTATION,
            CreationPhase.MANIFESTATION: CreationPhase.TRANSFORMATION,
            CreationPhase.TRANSFORMATION: CreationPhase.TRANSCENDENCE,
            CreationPhase.TRANSCENDENCE: CreationPhase.UNITY,
            CreationPhase.UNITY: CreationPhase.RENEWAL,
            CreationPhase.RENEWAL: CreationPhase.EVOLUTION,
            CreationPhase.EVOLUTION: CreationPhase.BEYOND,
            CreationPhase.BEYOND: CreationPhase.GENESIS  # Complete the eternal cycle
        }
        
        cycle_phase = next_phases.get(triggering_story.phase, CreationPhase.GENESIS)
        
        # Find all connected stories to include in cycle
        involved_stories = [triggering_story_id]
        self._add_connected_stories(triggering_story_id, involved_stories, depth=2)
        
        cycle = CreationCycle(
            cycle_id=cycle_id,
            phase=cycle_phase,
            stories_involved=involved_stories,
            energy_threshold=triggering_story.energy_level * len(involved_stories),
            duration_seconds=random.uniform(10, 60),  # Cycles can be 10-60 seconds
            started_at=datetime.now()
        )
        
        self.cycles[cycle_id] = cycle
        
        # Record cycle initiation
        self.creation_timeline.append({
            "timestamp": cycle.started_at.isoformat(),
            "event": "cycle_initiated",
            "cycle_id": cycle_id,
            "phase": cycle_phase.value,
            "triggering_story": triggering_story_id,
            "involved_stories": involved_stories
        })
        
        print(f"🌀 Initiated creation cycle: {cycle_id}")
        print(f"🔄 Phase: {cycle_phase.value}")
        print(f"📚 Stories involved: {len(involved_stories)}")
        print(f"⚡ Energy threshold: {cycle.energy_threshold:.2f}")
        
        return cycle_id
    
    def _add_connected_stories(self, story_id: str, story_list: List[str], depth: int):
        """Recursively add connected stories up to specified depth"""
        if depth <= 0 or story_id not in self.reality_web:
            return
        
        for connected_id in self.reality_web[story_id]:
            if connected_id not in story_list:
                story_list.append(connected_id)
                self._add_connected_stories(connected_id, story_list, depth - 1)
    
    def process_domino_effect(self, initiating_story_id: str, effect_strength: float = 1.0):
        """
        Process domino effects through the reality web
        Implements 'domino effect of cause and after effect' from instructions_05
        """
        if initiating_story_id not in self.stories:
            return
        
        affected_stories = []
        effect_queue = [(initiating_story_id, effect_strength)]
        processed = set()
        
        while effect_queue:
            current_story_id, current_strength = effect_queue.pop(0)
            
            if current_story_id in processed or current_strength < 0.1:
                continue
            
            processed.add(current_story_id)
            affected_stories.append(current_story_id)
            
            # Update current story
            current_story = self.stories[current_story_id]
            current_story.energy_level = min(1.0, current_story.energy_level + (current_strength * 0.1))
            current_story.last_active = datetime.now()
            current_story.transformation_count += 1
            
            # Propagate effect to connected stories
            for connected_id in self.reality_web.get(current_story_id, []):
                if connected_id not in processed:
                    # Effect diminishes as it propagates
                    diminished_strength = current_strength * random.uniform(0.5, 0.9)
                    effect_queue.append((connected_id, diminished_strength))
        
        # Record domino effect
        self.creation_timeline.append({
            "timestamp": datetime.now().isoformat(),
            "event": "domino_effect",
            "initiating_story": initiating_story_id,
            "affected_stories": affected_stories,
            "initial_strength": effect_strength
        })
        
        self.save_system_state()
        
        print(f"🎲 Domino effect initiated by: {self.stories[initiating_story_id].name}")
        print(f"🌊 Affected {len(affected_stories)} stories")
        print(f"⚡ Initial strength: {effect_strength:.2f}")
    
    def evolve_story_phase(self, story_id: str):
        """Evolve a story to its next phase based on energy and connections"""
        if story_id not in self.stories:
            return
        
        story = self.stories[story_id]
        current_phase = story.phase
        
        # Determine if story has enough energy and connections to evolve
        connection_count = len(story.connections)
        energy_requirement = 0.5 + (0.1 * connection_count)
        
        if story.energy_level >= energy_requirement:
            # Evolve to next phase
            phase_progression = list(CreationPhase)
            current_index = phase_progression.index(current_phase)
            next_index = (current_index + 1) % len(phase_progression)
            
            story.phase = phase_progression[next_index]
            story.energy_level = max(0.1, story.energy_level - 0.3)  # Evolution costs energy
            story.last_active = datetime.now()
            
            self.creation_timeline.append({
                "timestamp": datetime.now().isoformat(),
                "event": "story_evolved",
                "story_id": story_id,
                "old_phase": current_phase.value,
                "new_phase": story.phase.value
            })
            
            print(f"🌟 {story.name} evolved: {current_phase.value} → {story.phase.value}")
            
            # Evolution can trigger domino effects
            self.process_domino_effect(story_id, 0.8)
    
    def create_universe_from_stories(self, center_story_id: str, max_depth: int = 5) -> Dict:
        """
        Create a universe structure centered on a story
        Implements 'creation of entire universe' concept from instructions_05
        """
        if center_story_id not in self.stories:
            raise ValueError("Center story must exist")
        
        universe = {
            "center": center_story_id,
            "created_at": datetime.now().isoformat(),
            "layers": {},
            "total_stories": 0,
            "energy_distribution": {},
            "connection_density": 0
        }
        
        # Build universe layers radiating out from center
        visited = set()
        current_layer = {center_story_id}
        
        for depth in range(max_depth):
            if not current_layer:
                break
            
            layer_stories = []
            next_layer = set()
            
            for story_id in current_layer:
                if story_id not in visited:
                    visited.add(story_id)
                    layer_stories.append({
                        "id": story_id,
                        "name": self.stories[story_id].name,
                        "phase": self.stories[story_id].phase.value,
                        "energy": self.stories[story_id].energy_level,
                        "connections": len(self.stories[story_id].connections)
                    })
                    
                    # Add connected stories to next layer
                    for connected_id in self.reality_web.get(story_id, []):
                        if connected_id not in visited:
                            next_layer.add(connected_id)
            
            universe["layers"][f"layer_{depth}"] = layer_stories
            universe["total_stories"] += len(layer_stories)
            current_layer = next_layer
        
        # Calculate universe statistics
        total_energy = sum(story.energy_level for story in self.stories.values() if story.id in visited)
        total_connections = sum(len(self.reality_web.get(story_id, [])) for story_id in visited)
        
        universe["energy_distribution"] = {
            "total_energy": total_energy,
            "average_energy": total_energy / len(visited) if visited else 0,
            "energy_per_layer": {}
        }
        
        for layer_name, layer_stories in universe["layers"].items():
            layer_energy = sum(story["energy"] for story in layer_stories)
            universe["energy_distribution"]["energy_per_layer"][layer_name] = layer_energy
        
        universe["connection_density"] = total_connections / len(visited) if visited else 0
        
        # Save universe definition
        universe_file = self.root / f"universe_{center_story_id}_{int(time.time())}.json"
        with open(universe_file, 'w') as f:
            json.dump(universe, f, indent=2)
        
        print(f"🌌 Created universe centered on: {self.stories[center_story_id].name}")
        print(f"📊 Total stories: {universe['total_stories']}")
        print(f"⚡ Total energy: {universe['energy_distribution']['total_energy']:.2f}")
        print(f"🔗 Connection density: {universe['connection_density']:.2f}")
        
        return universe
    
    def integrate_with_project_evolution(self, story_id: str, project_name: str):
        """
        Integrate a story with the project evolution system from artifact_0
        Bridges the philosophical and practical systems
        """
        if story_id not in self.stories:
            raise ValueError("Story must exist")
        
        if not self.evolution_root.exists():
            print("⚠️  Project evolution system not found - creating basic integration")
            return
        
        story = self.stories[story_id]
        
        # Create project folder if it doesn't exist
        project_path = self.evolution_root / "projects" / project_name
        project_path.mkdir(parents=True, exist_ok=True)
        
        # Create universal creation bridge file
        bridge_file = project_path / "UNIVERSAL_CREATION_BRIDGE.md"
        bridge_content = f"""# Universal Creation Bridge
## Story Integration: {story.name}

### Story Context
- **Story ID**: {story_id}
- **Essence**: {story.essence}
- **Phase**: {story.phase.value}
- **Energy Level**: {story.energy_level:.2f}
- **Connections**: {len(story.connections)}
- **Created**: {story.created_at.isoformat()}

### Connected Stories
"""
        
        for connected_id in story.connections:
            if connected_id in self.stories:
                connected_story = self.stories[connected_id]
                bridge_content += f"- **{connected_story.name}** ({connected_story.phase.value}) - {connected_story.essence[:50]}...\n"
        
        bridge_content += f"""
### Reality Shaping Integration
This project is part of the universal creation web, where:
- Changes here create **domino effects** throughout connected stories
- The project **evolves through phases** aligned with creation cycles
- **Energy flows** between this project and related initiatives
- All development contributes to the **greater universal pattern**

### Commands
```bash
# Trigger domino effect from this story
python3 ../../universal_creation_system.py domino {story_id}

# Evolve story phase
python3 ../../universal_creation_system.py evolve {story_id}

# Create universe view centered on this story
python3 ../../universal_creation_system.py universe {story_id}
```

### Integration Status
- Project Evolution System: ✅ Integrated
- Universal Creation Web: ✅ Connected
- Story ID: {story_id}
- Last Updated: {datetime.now().isoformat()}
"""
        
        with open(bridge_file, 'w') as f:
            f.write(bridge_content)
        
        # Record integration
        self.creation_timeline.append({
            "timestamp": datetime.now().isoformat(),
            "event": "project_integration",
            "story_id": story_id,
            "project_name": project_name,
            "project_path": str(project_path)
        })
        
        self.save_system_state()
        
        print(f"🌉 Integrated story '{story.name}' with project '{project_name}'")
        print(f"📁 Project path: {project_path}")
        print(f"🔗 Bridge file created: UNIVERSAL_CREATION_BRIDGE.md")
    
    def get_system_status(self) -> str:
        """Get comprehensive status of the universal creation system"""
        total_stories = len(self.stories)
        total_cycles = len(self.cycles)
        total_connections = sum(len(connections) for connections in self.reality_web.values()) // 2
        
        active_cycles = [c for c in self.cycles.values() if c.completed_at is None]
        
        # Phase distribution
        phase_counts = {}
        total_energy = 0
        for story in self.stories.values():
            phase_counts[story.phase.value] = phase_counts.get(story.phase.value, 0) + 1
            total_energy += story.energy_level
        
        average_energy = total_energy / total_stories if total_stories > 0 else 0
        
        # Recent activity
        recent_events = sorted(self.creation_timeline, key=lambda x: x["timestamp"], reverse=True)[:5]
        
        status = f"""
🌟 Universal Creation System Status
════════════════════════════════════

📚 Stories: {total_stories}
🌀 Cycles: {total_cycles} (Active: {len(active_cycles)})
🔗 Connections: {total_connections}
⚡ Total Energy: {total_energy:.2f}
📊 Average Energy: {average_energy:.2f}

🔄 Phase Distribution:
"""
        
        for phase, count in phase_counts.items():
            status += f"├── {phase.capitalize()}: {count}\n"
        
        status += f"""
📈 Recent Activity:
"""
        
        for event in recent_events:
            timestamp = event["timestamp"][:19]  # Remove microseconds
            event_type = event["event"].replace("_", " ").title()
            status += f"├── {timestamp} - {event_type}\n"
        
        status += f"""
🌌 System Health:
├── Connection Density: {(total_connections / total_stories) if total_stories > 0 else 0:.2f}
├── Evolution Rate: {sum(s.transformation_count for s in self.stories.values()) / total_stories if total_stories > 0 else 0:.2f}
└── Energy Distribution: {'Balanced' if 0.3 <= average_energy <= 0.7 else 'Unbalanced'}

🎯 Ready for universal creation and reality shaping!
"""
        
        return status

# CLI Interface for the Universal Creation System
if __name__ == "__main__":
    import sys
    
    system = UniversalCreationSystem()
    
    if len(sys.argv) < 2:
        print("Universal Creation System - CLI Interface")
        print("==========================================")
        print(system.get_system_status())
        print("\nCommands:")
        print("  create <name> <essence> [phase]        - Create new story")
        print("  connect <story1_id> <story2_id>        - Connect two stories")
        print("  cycle <story_id>                       - Initiate creation cycle")
        print("  domino <story_id> [strength]           - Trigger domino effect")
        print("  evolve <story_id>                      - Evolve story phase")
        print("  universe <story_id> [depth]            - Create universe view")
        print("  integrate <story_id> <project_name>    - Integrate with project evolution")
        print("  status                                 - Show system status")
        sys.exit(0)
    
    command = sys.argv[1]
    
    try:
        if command == "create":
            name = sys.argv[2]
            essence = sys.argv[3]
            phase = CreationPhase(sys.argv[4]) if len(sys.argv) > 4 else CreationPhase.GENESIS
            story_id = system.create_story(name, essence, phase)
            print(f"✅ Story created with ID: {story_id}")
        
        elif command == "connect":
            story1_id = sys.argv[2]
            story2_id = sys.argv[3]
            system.connect_stories(story1_id, story2_id)
            print("✅ Stories connected")
        
        elif command == "cycle":
            story_id = sys.argv[2]
            cycle_id = system.initiate_creation_cycle(story_id)
            print(f"✅ Creation cycle initiated: {cycle_id}")
        
        elif command == "domino":
            story_id = sys.argv[2]
            strength = float(sys.argv[3]) if len(sys.argv) > 3 else 1.0
            system.process_domino_effect(story_id, strength)
            print("✅ Domino effect processed")
        
        elif command == "evolve":
            story_id = sys.argv[2]
            system.evolve_story_phase(story_id)
            print("✅ Story evolution processed")
        
        elif command == "universe":
            story_id = sys.argv[2]
            depth = int(sys.argv[3]) if len(sys.argv) > 3 else 5
            universe = system.create_universe_from_stories(story_id, depth)
            print(f"✅ Universe created and saved")
        
        elif command == "integrate":
            story_id = sys.argv[2]
            project_name = sys.argv[3]
            system.integrate_with_project_evolution(story_id, project_name)
            print("✅ Project integration completed")
        
        elif command == "status":
            print(system.get_system_status())
        
        else:
            print(f"❌ Unknown command: {command}")
    
    except Exception as e:
        print(f"❌ Error: {e}")