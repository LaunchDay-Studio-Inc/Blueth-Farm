# Contributing to Blueth Farm

Thank you for your interest in contributing to Blueth Farm! We're building a game that combines cozy gameplay with real climate science, and we welcome contributions from diverse backgrounds.

## 🌊 Ways to Contribute

### 1. Code & Development
- Implement game systems and mechanics
- Optimize performance
- Fix bugs
- Write tests

### 2. Art & Design
- Create sprites and animations
- Design UI elements
- Develop environmental art
- Character design and illustration

### 3. Writing & Narrative
- Develop NPC dialogue
- Write journal entries
- Craft quest descriptions
- Improve documentation

### 4. Science & Research
- Review scientific accuracy
- Provide species data
- Validate ecosystem mechanics
- Contribute to Science Reference document

### 5. Audio
- Compose music
- Create sound effects
- Design ambient soundscapes
- Implement adaptive audio

### 6. Playtesting
- Test prototype builds
- Provide feedback
- Report bugs
- Suggest improvements

## 🚀 Getting Started

### First Contribution

1. **Read the Documentation**
   - Start with the [Game Design Document](docs/GDD.md)
   - Review [Art Direction](docs/ART_DIRECTION.md) if contributing visuals
   - Check [Science Reference](docs/SCIENCE_REFERENCE.md) for scientific context

2. **Check Existing Issues**
   - Browse [open issues](../../issues) for tasks
   - Look for issues labeled `good first issue` or `help wanted`

3. **Join the Discussion**
   - Comment on issues you're interested in
   - Ask questions if anything is unclear
   - Share your ideas and expertise

### Setting Up Development Environment

*(This section will be expanded when prototype development begins)*

**For Code Contributors:**
```bash
# Clone the repository
git clone https://github.com/LaunchDay-Studio-Inc/Blueth-Farm.git
cd Blueth-Farm

# Development setup instructions coming soon
# (Godot installation, project setup, etc.)
```

## 📋 Contribution Workflow

### 1. Fork & Branch

```bash
# Fork the repository on GitHub, then:
git clone https://github.com/YOUR-USERNAME/Blueth-Farm.git
cd Blueth-Farm

# Create a feature branch
git checkout -b feature/your-feature-name
# or
git checkout -b fix/bug-description
```

### 2. Make Changes

- Write clear, commented code
- Follow existing code style and conventions
- Test your changes thoroughly
- Update documentation if needed

### 3. Commit Your Changes

Follow our commit message format:

```
type(scope): Brief description

Detailed explanation of what changed and why.

Closes #issue-number
```

**Types:**
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code formatting (no functional changes)
- `refactor`: Code restructuring
- `test`: Adding or updating tests
- `chore`: Maintenance tasks

**Examples:**
```
feat(planting): Add seagrass growth stages

Implemented three growth stages (seedling, juvenile, mature) with
visual sprite changes and carbon sequestration rates.

Closes #42
```

```
docs(science): Update mangrove carbon storage rates

Updated values to reflect latest IPCC 2024 data.
```

### 4. Push & Pull Request

```bash
# Push to your fork
git push origin feature/your-feature-name
```

Then create a Pull Request on GitHub:

1. Go to the original Blueth-Farm repository
2. Click "New Pull Request"
3. Select your fork and branch
4. Fill out the PR template
5. Submit for review

## ✅ Pull Request Guidelines

### PR Title Format
Use the same format as commit messages:
```
type(scope): Brief description
```

### PR Description Template
```markdown
## Description
Brief description of changes

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Documentation update
- [ ] Art/Asset addition
- [ ] Science/Research update

## Related Issues
Closes #issue-number

## Testing
How were these changes tested?

## Screenshots (if applicable)
Add screenshots for visual changes

## Checklist
- [ ] Code follows project style guidelines
- [ ] Self-review completed
- [ ] Documentation updated
- [ ] No new warnings generated
- [ ] Scientific accuracy verified (if applicable)
```

## 🎨 Code Style Guidelines

### General Principles
- **Clarity over cleverness:** Readable code is maintainable code
- **Comment complex logic:** Explain *why*, not *what*
- **Consistent naming:** Use descriptive, consistent names
- **Keep functions focused:** One function, one responsibility

### GDScript Style (for Godot)
```gdscript
# Use snake_case for variables and functions
var seagrass_count: int = 0
var carbon_sequestered: float = 0.0

# Use PascalCase for class names
class_name SeagrassPlant extends Node2D

# Constants in UPPER_CASE
const MAX_GROWTH_STAGE: int = 3
const CARBON_PER_DAY: float = 0.5

# Clear function names with type hints
func calculate_carbon_sequestration(plant_count: int, days: int) -> float:
    return plant_count * CARBON_PER_DAY * days

# Document complex functions
## Calculates tidal height based on lunar cycle and time of day.
## Returns a value between 0.0 (low tide) and 1.0 (high tide).
func get_tidal_height(game_time: float, lunar_phase: float) -> float:
    # Implementation...
    pass
```

### Documentation Style
- Use markdown for all documentation
- Keep line length to ~100 characters
- Use headers, lists, and tables for clarity
- Include code examples where helpful

## 🐛 Bug Reports

### Before Reporting
1. Check if the bug is already reported
2. Verify it's reproducible
3. Gather relevant information

### Bug Report Template
```markdown
**Describe the Bug**
Clear description of what's wrong

**To Reproduce**
Steps to reproduce:
1. Go to '...'
2. Click on '...'
3. See error

**Expected Behavior**
What should happen

**Screenshots**
If applicable

**Environment:**
- OS: [e.g., Windows 10]
- Game Version: [e.g., v0.1.0]
- Hardware: [if relevant]

**Additional Context**
Any other relevant information
```

## 💡 Feature Requests

We love new ideas! When suggesting features:

1. **Check existing issues** to avoid duplicates
2. **Explain the problem** the feature solves
3. **Describe the solution** you envision
4. **Consider alternatives** you've thought about
5. **Align with project goals** (cozy, educational, scientifically grounded)

### Feature Request Template
```markdown
**Problem Statement**
What problem does this feature solve?

**Proposed Solution**
Describe your proposed feature

**Alternatives Considered**
Other approaches you've thought about

**Scientific Basis** (if applicable)
Real-world science supporting this feature

**Additional Context**
Screenshots, mockups, references, etc.
```

## 🔬 Scientific Contributions

We're committed to scientific accuracy. If you have expertise in:
- Marine biology
- Coastal ecology
- Climate science
- Carbon cycle research
- Fisheries science
- Conservation biology

Your input is invaluable!

### How to Contribute Science
1. Review [Science Reference](docs/SCIENCE_REFERENCE.md)
2. Suggest corrections or additions
3. Provide peer-reviewed sources
4. Explain implications for game mechanics

## 🎓 Code of Conduct

### Our Pledge
We pledge to make participation in this project a harassment-free experience for everyone, regardless of:
- Age, body size, disability, ethnicity
- Gender identity and expression
- Level of experience, education
- Nationality, personal appearance, race, religion
- Sexual identity and orientation

### Our Standards

**Positive behaviors:**
- Using welcoming and inclusive language
- Being respectful of differing viewpoints
- Gracefully accepting constructive criticism
- Focusing on what's best for the community
- Showing empathy toward others

**Unacceptable behaviors:**
- Trolling, insulting/derogatory comments, personal attacks
- Public or private harassment
- Publishing others' private information
- Other conduct inappropriate in a professional setting

### Enforcement
Project maintainers will:
- Clearly communicate expectations
- Take appropriate corrective action for violations
- Remove, edit, or reject contributions that violate this Code

Instances of unacceptable behavior can be reported to the project team.

## 📞 Communication Channels

*(To be established as the project grows)*

- **GitHub Issues:** Bug reports, feature requests, discussions
- **GitHub Discussions:** General questions, ideas, community chat
- **Discord:** *(Coming soon)* Real-time chat and collaboration
- **Email:** *(To be announced)* Direct contact for sensitive issues

## 🎯 Development Priorities

Current focus areas (updated as project evolves):

**Now (Pre-Production):**
- [ ] Finalizing game design documentation
- [ ] Assembling development team
- [ ] Scientific advisor outreach
- [ ] Prototype planning

**Next (Prototype):**
- [ ] Milestone 1: Foundation (tile map, player movement)
- [ ] Milestone 2: Core planting loop
- [ ] Milestone 3: Carbon tracking & UI
- [ ] Milestone 4: NPC & narrative
- [ ] Milestone 5: Polish & audio

**Future:**
- [ ] Expand to all five zones
- [ ] Complete NPC relationship systems
- [ ] Full research tree implementation
- [ ] Multiplayer features

## 🏆 Recognition

Contributors will be recognized in:
- Game credits (with permission)
- README acknowledgments
- Release notes
- Community highlights

Significant contributions may lead to ongoing collaboration opportunities.

## 📝 License

By contributing to Blueth Farm, you agree that your contributions will be licensed under the same [MIT License](LICENSE) that covers the project.

## ❓ Questions?

Don't hesitate to ask! You can:
- Open a GitHub issue with the `question` label
- Start a discussion in GitHub Discussions *(when available)*
- Reach out through official channels *(to be announced)*

---

**Thank you for helping us build a game that restores virtual coasts and supports real-world ocean conservation!** 🌊💙

*"Every contribution, like every restored seagrass blade, makes a difference."*
