# 📋 Project Rules Checklist
*Follow these rules every time we add/modify anything*

## ✅ Before Adding Any Feature:

### 1. Check File Timeline
- Look at file creation dates: `ls -la scripts/core/ | sort -k 6,7`
- Newest files (May 27) are current, older ones may be outdated
- Don't modify files from May 24-25 without checking if newer versions exist

### 2. Test Existing Functions First
- Use `test_tutorial` command to see what actually works
- Don't assume a command works just because it's in help
- Fix broken commands before adding new ones

### 3. Object Count Limits
- **NEVER** spawn more than 20 objects at once
- Check object count before spawning: `list` command
- Respect FPS limits - if FPS < 30, stop spawning

### 4. Console Integration
- Every new feature MUST have a console command
- Test the command manually before considering it "done"
- Add command to help ONLY after it's verified working

### 5. Floodgate Compliance
- All object creation goes through Floodgate system
- Register objects properly with unique IDs
- Handle unloading/cleanup properly

## 🎯 When Adding New Systems:

### 1. Start Simple
- Create minimal working version first
- Test with `test_tutorial` system
- Only add complexity after basic version works

### 2. Follow Naming Convention
- Core systems: `scripts/core/[system_name].gd`
- UI elements: `scripts/ui/[ui_name].gd`
- Tests: `scripts/test/[test_name].gd`

### 3. Document Everything
- Add file header with purpose and creation date
- Update help command if adding console commands
- Add to tutorial test list if it's user-facing

### 4. Integration Points
- Connect to UniversalEntity system
- Register with FloodgateController
- Add to ConsoleManager commands
- Consider LOD system for 3D objects

## 🚨 Critical Rules:

### Performance Rules
1. Monitor FPS - if below 30, optimize immediately
2. Limit active objects in scene
3. Use LOD for distant objects
4. Clean up objects when removed

### Quality Rules
1. Test manually before claiming it works
2. Every command should give clear feedback
3. Failures should explain why they failed
4. No silent failures

### Architecture Rules
1. Use signals for communication between systems
2. Keep systems modular and loosely coupled
3. Follow existing patterns in the codebase
4. Prefer fixing existing systems over creating new ones

## 📊 File Creation Timeline:

Based on `ls -la scripts/core/`:

**May 27 (Most Recent)**:
- `perfect_astral_being.gd` - Our latest unified astral being
- `akashic_records_database.gd` - Text-based reality system
- `universal_workflow_analyzer.gd` - Project analysis tool
- `the_universal_thing.gd` - Core entity system

**May 26 (Stable)**:
- `seven_part_ragdoll_integration.gd` - Working ragdoll
- `simple_ragdoll_walker.gd` - Walking ragdoll
- `talking_astral_being.gd` - Feature-complete astral being

**May 24-25 (Potentially Outdated)**:
- Many files from this period - check if newer versions exist

## 🎮 Testing Protocol:

### Before Each Session:
1. Run `test_tutorial` command
2. Check which commands actually work
3. Note any new failures
4. Fix broken commands before adding features

### After Adding Features:
1. Test new command manually
2. Add to tutorial test suite
3. Verify it doesn't break existing features
4. Update documentation

### Before Considering "Done":
1. Command works reliably
2. Gives proper feedback
3. Handles errors gracefully
4. Follows project patterns
5. Documented in help

## 💡 Remember:

**"Better to have 10 perfect commands than 50 broken ones"**

Every addition should make the game feel more solid and responsive, not add more broken promises.