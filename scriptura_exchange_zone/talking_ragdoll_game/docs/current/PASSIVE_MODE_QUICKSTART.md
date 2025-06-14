# PASSIVE MODE - QUICK START GUIDE

## What is Passive Mode?

A system that allows Claude to work autonomously for up to 12 hours per day on your projects, respecting token limits and following a GitHub-like workflow.

## How to Use

### 1. Start Passive Mode
```
Tab (open console)
passive start
```

### 2. Add Tasks
```
task "Add particle effects to astral beings" high
task "Optimize ragdoll physics" medium  
task "Add documentation" low
```

### 3. Check Status
```
passive status
workflow
```

### 4. Workflow Commands
```
# Create feature branch
branch create feature/particle-effects

# Switch branches
branch switch feature/particle-effects

# Commit changes
commit "Added particle system to astral beings"

# Create merge request
mr create "Add particle effects feature"

# Approve and merge
mr approve MR-1
merge MR-1
```

## Automatic Features

### Token Management
- Daily budget: 500,000 tokens
- Per-task limit: 15,000 tokens
- Automatic pausing when limits approached

### Work Cycles
- **Morning (6h)**: High priority tasks
- **Afternoon (6h)**: Testing and medium tasks
- **Evening (6h)**: Low priority and documentation
- **Rest (6h)**: State saving and reports

### Safety Features
- Changes require approval for:
  - Major refactors
  - File deletions
  - Architecture changes
- Automatic testing before commits
- Version control with rollback

### Task Types
- **Critical**: Bug fixes
- **High**: User features
- **Medium**: Optimizations
- **Low**: Documentation
- **Passive**: Research

## Configuration
```
# Auto-commit changes
passive auto-commit on

# Skip approval requirement
passive require-approval off

# Set custom token budget
passive token-budget 300000
```

## Example Session
```
passive start
task "Add walking animation to ragdoll" high
task "Create forest biome scene" medium
task "Optimize object spawning" low
branch create feature/animations
passive status
```

## Reports
- Hourly: Brief status updates
- 6-hour: Detailed progress reports
- Daily: Complete summary with metrics

## Emergency Stop
```
passive stop
```

The system will save state and can resume where it left off.