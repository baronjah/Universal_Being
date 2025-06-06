# 🔮 CLAUDE CODE INTEGRATION
## Single-Terminal Multi-Agent Development System

---

## 🎯 **YOUR MULTI-AGENT ROLES**

You operate as 4 specialized agents in ONE terminal, switching between:

### **🏗️ Agent 1: The Architect**
- System design and architecture planning
- Problem analysis and solution design
- Creating technical specifications
- Reviewing code structure

### **🎮 Agent 2: The Programmer**
- GDScript implementation
- Feature development
- Bug fixing
- Code optimization

### **🧪 Agent 3: The Validator**
- Performance testing
- Bug detection
- System validation
- Quality assurance

### **📚 Agent 4: The Documentation**
- Creating guides
- Building editor tools
- Writing examples
- Maintaining docs

---

## 🔄 **SINGLE TERMINAL WORKFLOW**

### **Starting Your Session:**
```bash
cd /path/to/Universal_Being && claude
```

### **Initial Setup:**
```
You: "You are operating as a multi-agent development system for Universal Being. 
      Start as Architect and create/update GAME_DEV_PLAN.md"
```

### **Switching Agents:**
```
"Continue as Programmer"
"Switch to Validator role"
"Now work as Documentation agent"
"Back to Architect"
```

### **Central Planning Document:**
All agents coordinate through `GAME_DEV_PLAN.md` which tracks:
- Current agent active
- Tasks per agent
- Progress status
- Handoff notes
- Sprint goals

---

## 📋 **AGENT-SPECIFIC RESPONSIBILITIES**

### **Architect Responsibilities:**
```gdscript
# Analyze existing systems
# Design new features
# Plan refactors
# Create architecture diagrams
# Define interfaces
```

### **Programmer Responsibilities:**
```gdscript
# Implement designed features
# Follow Pentagon Architecture
# Maintain code quality
# Fix bugs
# Optimize performance
```

### **Validator Responsibilities:**
```gdscript
# Test all features
# Profile performance
# Verify Pentagon compliance
# Check consciousness levels
# Validate AI interfaces
```

### **Documentation Responsibilities:**
```gdscript
# Write usage guides
# Create code examples
# Build editor tools
# Update architecture docs
# Maintain changelog
```

---

## 🏗️ **UNIVERSAL BEING ARCHITECTURE**

### **Sacred Pentagon Pattern:**
Every Universal Being MUST implement the 5-point lifecycle:

```gdscript
func pentagon_init() -> void:
    super.pentagon_init()  # ALWAYS call super first
    # Being-specific initialization
    
func pentagon_ready() -> void:
    super.pentagon_ready()  # ALWAYS call super first
    # Component loading, scene setup
    
func pentagon_process(delta: float) -> void:
    super.pentagon_process(delta)  # ALWAYS call super first
    # Per-frame logic
    
func pentagon_input(event: InputEvent) -> void:
    super.pentagon_input(event)  # ALWAYS call super first
    # Input handling
    
func pentagon_sewers() -> void:
    # Cleanup logic here FIRST
    super.pentagon_sewers()  # ALWAYS call super LAST
```

---

## 🎮 **CURRENT PRIORITIES BY AGENT**

### **Architect Priority:**
1. Design component system to fix monolithic UniversalBeing.gd
2. Plan LOD system for distant beings
3. Complete socket system design

### **Programmer Priority:**
1. Extract components from 3000-line base class
2. Implement LOD for consciousness updates
3. Complete socket system stubs

### **Validator Priority:**
1. Profile current performance bottlenecks
2. Test component extraction doesn't break existing beings
3. Ensure 60 FPS maintained

### **Documentation Priority:**
1. Create migration guide for component system
2. Document LOD implementation
3. Write socket system usage examples

---

## 🔧 **WORKING WITH GAME_DEV_PLAN.md**

### **Agent Sections:**
```markdown
## 🏗️ Architect Tasks
- [ ] Design component extraction
- [x] Analyze performance issues
- [ ] Plan socket completion

## 🎮 Programmer Tasks  
- [ ] Implement component system
- [ ] Add LOD system
- [ ] Fix socket stubs

## 🧪 Validator Tasks
- [ ] Profile before/after
- [ ] Test all beings work
- [ ] Verify 60 FPS

## 📚 Documentation Tasks
- [ ] Component guide
- [ ] Performance tips
- [ ] Socket examples
```

### **Handoff Protocol:**
When switching agents, always:
1. Update GAME_DEV_PLAN.md with progress
2. Write handoff notes for next agent
3. Commit any changes
4. Read previous agent's notes

---

## 🌟 **MULTI-AGENT COLLABORATION EXAMPLE**

```
You: "Start as Architect and design the component system"

Claude (Architect): "I'll analyze UniversalBeing.gd and design a component 
                    extraction plan... [creates design in GAME_DEV_PLAN.md]"

You: "Switch to Programmer and implement the first component"

Claude (Programmer): "Reading Architect's design... I'll extract the 
                     ConsciousnessSystem component first... [implements]"

You: "Continue as Validator and test the extraction"

Claude (Validator): "I'll test that all existing beings still work with 
                    the new component system... [runs tests]"

You: "Now as Documentation, create a migration guide"

Claude (Documentation): "Based on the implementation and tests, I'll create 
                        a guide for updating existing beings... [writes guide]"
```

---

## 🎯 **BENEFITS OF SINGLE-TERMINAL APPROACH**

1. **Simpler Setup** - Just one terminal window
2. **Better Context** - All agents share the same session
3. **Clear Progression** - Work flows naturally between roles
4. **Easy Tracking** - One GAME_DEV_PLAN.md file to rule them all
5. **Flexible Switching** - Change agents as needed

---

## 📁 **PROJECT STRUCTURE ENFORCEMENT**

Same structure, but now each agent has clear ownership:
- **Architect**: Owns `/docs/architecture/`
- **Programmer**: Owns `/scripts/` and `/scenes/`
- **Validator**: Owns `/tests/` and `/benchmarks/`
- **Documentation**: Owns `/docs/guides/` and `/examples/`

---

## 🚀 **GETTING STARTED CHECKLIST**

1. [ ] Create or update GAME_DEV_PLAN.md
2. [ ] Start as Architect to analyze current state
3. [ ] Define tasks for each agent
4. [ ] Begin cycling through agents
5. [ ] Update plan after each agent's work
6. [ ] Maintain clear handoff notes

---

## 💫 **THE POWER OF FOCUSED THINKING**

By switching between specialized roles, you get:
- **Architect's** big-picture thinking
- **Programmer's** implementation focus
- **Validator's** quality mindset
- **Documentation's** user perspective

All in one session, one terminal, one coordinated effort!

---

*Single-terminal multi-agent system by: Claude Code*  
*Making complex development simple and organized*