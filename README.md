# Claude Code Skills Setup Guide

  ## Overview

  Skills are modular, self-contained packages that extend Claude's capabilities with specialized knowledge, workflows, and tools. This guide explains how to set up and manage skills for Claude Code.

  ## Directory Structure

  ~/.claude/
  ├── CLAUDE.md                    # Global user instructions
  ├── SKILLS.md                    # Skills discovery file (required)
  └── skills/                      # Skills directory
      ├── README.md                # This file
      ├── ruby-rails/              # Example skill
      │   └── SKILL.md
      ├── kotlin-java-backend/
      │   └── SKILL.md
      └── your-skill-name/
          ├── SKILL.md             # Required: Skill instructions
          ├── scripts/             # Optional: Executable code
          ├── references/          # Optional: Reference documentation
          └── assets/              # Optional: Templates, images, etc.

  ## Run claude with
  claude /add-dir ~/.claude

  ## Setup Instructions

  ### 1. Create Skills Directory

  ```bash
  mkdir -p ~/.claude/skills

  2. Create SKILLS.md Discovery File

  Create ~/.claude/SKILLS.md with the following structure:

  ## Anthropic Skills (Official)

  ### Document Skills

  #### docx
  Comprehensive document creation, editing, and analysis with support for tracked changes, comments, formatting preservation, and text extraction. Use when Claude needs to work with professional documents (.docx files) for: (1) Creating new documents, (2) Modifying or editing content, (3) Working with tracked changes, (4) Adding comments, or any other document tasks.
  Location: ~/.claude/anthropic-skills/skills/docx/SKILL.md

  [... other Anthropic skills ...]

  ---

  ## Custom Skills (User-defined)

  ### your-skill-name
  Description of what the skill does and when to use it. Be specific about triggers and use cases.
  Location: ~/.claude/skills/your-skill-name/SKILL.md

  ---

  ## Usage Notes

  - Claude reads ONLY this discovery file initially
  - Full skill content loads on-demand when relevant to the task
  - Skill folders must contain a SKILL.md file with YAML frontmatter (name + description)
  - Custom skills follow the same structure as Anthropic skills

  3. Update Global CLAUDE.md

  Add this line at the top of ~/.claude/CLAUDE.md:

  Skills available at: ~/.claude/SKILLS.md

  4. Update Project CLAUDE.md (Optional)

  In your project's CLAUDE.md file, you can reference specific skills:

  ## C-1 (SHOULD) Detect programming language of current task

  Detect programming language of current task (if necessary) and load the SKILL defined. If no one defined, ask to build the skill.

  Creating a New Skill

  Skill Structure

  Every skill requires a SKILL.md file with:

  1. YAML Frontmatter (required)
  2. Markdown Body (required)

  Example SKILL.md

  ---
  name: your-skill-name
  description: Brief description of what the skill does and when to use it. Include specific triggers, patterns, and use cases. This is the ONLY content Claude sees before the skill is loaded, so be comprehensive.
  ---

  # Your Skill Name

  ## Overview

  Brief introduction to the skill.

  ## When to Use This Skill

  - Trigger condition 1
  - Trigger condition 2
  - Use case 1
  - Use case 2

  ## Core Concepts

  ### Concept 1

  Explanation and examples.

  ```language
  code example

  Concept 2

  More content...

  Best Practices

  - Best practice 1
  - Best practice 2

  Common Patterns

  Pattern 1

  code example

  Common Mistakes to Avoid

  1. Mistake 1
  2. Mistake 2

  ## Skill Components

  ### SKILL.md (Required)

  - **Frontmatter**: `name` and `description` fields
  - **Body**: Instructions, patterns, examples, best practices
  - Keep under 500 lines; split into references if longer

  ### scripts/ (Optional)

  Executable code for tasks requiring deterministic reliability:

  scripts/
  ├── process_data.py
  ├── transform.sh
  └── helper.rb

  ### references/ (Optional)

  Documentation loaded on-demand:

  references/
  ├── api_docs.md
  ├── schemas.md
  └── examples.md

  ### assets/ (Optional)

  Files used in output (not loaded into context):

  assets/
  ├── templates/
  ├── images/
  └── boilerplate/

  ## Adding a Skill to SKILLS.md

  1. Open `~/.claude/SKILLS.md`
  2. Add entry under "Custom Skills (User-defined)" section:

  ```markdown
  ### your-skill-name
  Complete description including what it does and when to use it. Be specific about triggers.
  Location: ~/.claude/skills/your-skill-name/SKILL.md

  Skill Best Practices

  Writing Effective Descriptions

  The description in frontmatter is critical for skill discovery:

  ✅ Good: "Ruby on Rails 8 and Ruby 3.2 backend development. Use when working on Rails applications, API development, ActiveRecord models, database migrations, service objects, serializers, RSpec testing, or Ruby code optimization. Triggers on Rails-specific patterns like controllers, models, migrations, jobs, concerns, serializers, and Rails configuration."

  ❌ Bad: "Ruby on Rails development skill."

  Keep Skills Concise

  - Assume Claude is already smart
  - Only add context Claude doesn't have
  - Prefer concise examples over verbose explanations
  - Use progressive disclosure (split large skills into references)

  Progressive Disclosure

  For skills > 500 lines, split content:

  # Main Skill

  ## Quick Start
  [Essential content here]

  ## Advanced Topics
  - **Feature 1**: See [FEATURE1.md](references/feature1.md)
  - **Feature 2**: See [FEATURE2.md](references/feature2.md)

  Example Skills

  ruby-rails

  Backend development with Rails 8, Ruby 3.2, ActiveRecord, RSpec
  - Location: ~/.claude/skills/ruby-rails/SKILL.md
  - Includes: Models, controllers, services, testing, performance

  kotlin-java-backend

  JVM backend services with Kotlin/Java, Spring Boot
  - Location: ~/.claude/skills/kotlin-java-backend/SKILL.md
  - Includes: Spring patterns, API design, testing

  github-actions

  CI/CD pipelines and GitHub Actions workflows
  - Location: ~/.claude/skills/github-actions/SKILL.md
  - Includes: Workflow syntax, common actions, deployment

  How Skills Work

  1. Discovery: Claude reads SKILLS.md to see all available skills
  2. Triggering: When task matches a skill's description, Claude loads it
  3. Execution: Claude follows the skill's instructions and patterns
  4. On-demand loading: References and scripts loaded only when needed

  Troubleshooting

  Skill Not Loading

  - Check SKILLS.md has correct path
  - Verify SKILL.md has proper YAML frontmatter
  - Ensure description includes clear triggers
  - Check file permissions

  Skill Not Triggering

  - Make description more specific and comprehensive
  - Include explicit trigger words and patterns
  - Add more use case examples
  - Mention specific file patterns or keywords

  Performance Issues

  - Keep SKILL.md under 500 lines
  - Move detailed content to references/
  - Use progressive disclosure patterns
  - Avoid duplicate content

  Resources

  - https://github.com/anthropics/anthropic-skills
  - ~/.claude/anthropic-skills/skills/skill-creator/SKILL.md
  - https://docs.anthropic.com/claude-code



