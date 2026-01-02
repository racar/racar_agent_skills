## Anthropic Skills (Official)

### Document Skills

#### docx
Comprehensive document creation, editing, and analysis with support for tracked changes, comments, formatting preservation, and text extraction. Use when Claude needs to work with professional documents (.docx files) for: (1) Creating new documents, (2) Modifying or editing content, (3) Working with tracked changes, (4) Adding comments, or any other document tasks.
Location: ~/.claude/anthropic-skills/skills/docx/SKILL.md

#### pdf
Comprehensive PDF manipulation toolkit for extracting text and tables, creating new PDFs, merging/splitting documents, and handling forms. Use when Claude needs to fill in a PDF form or programmatically process, generate, or analyze PDF documents at scale.
Location: ~/.claude/anthropic-skills/skills/pdf/SKILL.md

#### pptx
Presentation creation, editing, and analysis. Use when Claude needs to work with presentations (.pptx files) for: (1) Creating new presentations, (2) Modifying or editing content, (3) Working with layouts, (4) Adding comments or speaker notes, or any other presentation tasks.
Location: ~/.claude/anthropic-skills/skills/pptx/SKILL.md

#### xlsx
Comprehensive spreadsheet creation, editing, and analysis with support for formulas, formatting, data analysis, and visualization. Use when Claude needs to work with spreadsheets (.xlsx, .xlsm, .csv, .tsv, etc) for: (1) Creating new spreadsheets with formulas and formatting, (2) Reading or analyzing data, (3) Modify existing spreadsheets while preserving formulas, (4) Data analysis and visualization in spreadsheets, or (5) Recalculating formulas.
Location: ~/.claude/anthropic-skills/skills/xlsx/SKILL.md

### Development & Technical Skills

#### skill-creator
Guide for creating effective skills. Use when users want to create a new skill (or update an existing skill) that extends Claude's capabilities with specialized knowledge, workflows, or tool integrations.
Location: ~/.claude/anthropic-skills/skills/skill-creator/SKILL.md

#### mcp-builder
Guide for creating high-quality MCP (Model Context Protocol) servers to integrate external APIs and services with LLMs using Python or TypeScript.
Location: ~/.claude/anthropic-skills/skills/mcp-builder/SKILL.md

#### webapp-testing
Test local web applications using Playwright for UI verification and debugging. Use when Claude needs to automate browser testing, verify UI elements, or debug web application issues.
Location: ~/.claude/anthropic-skills/skills/webapp-testing/SKILL.md

#### frontend-design
Create distinctive, production-grade frontend interfaces with high design quality. Use when building web components, pages, artifacts, or applications (websites, landing pages, dashboards, React components, HTML/CSS layouts). Generates creative, polished code and UI design that avoids generic AI aesthetics.
Location: ~/.claude/anthropic-skills/skills/frontend-design/SKILL.md

### Creative & Design Skills

#### algorithmic-art
Create generative art using p5.js with seeded randomness, flow fields, and particle systems. Use when Claude needs to create computational art, generative designs, or interactive visual experiences.
Location: ~/.claude/anthropic-skills/skills/algorithmic-art/SKILL.md

#### canvas-design
Design beautiful visual art in .png and .pdf formats using design philosophies. Use when Claude needs to create posters, visual designs, or static artwork.
Location: ~/.claude/anthropic-skills/skills/canvas-design/SKILL.md

#### slack-gif-creator
Toolkit for creating animated GIFs optimized for Slack's size constraints with validators and composable animation primitives.
Location: ~/.claude/anthropic-skills/skills/slack-gif-creator/SKILL.md

#### artifacts-builder
Build complex claude.ai HTML artifacts using modern frontend web technologies (React, Tailwind CSS, shadcn/ui components).
Location: ~/.claude/anthropic-skills/skills/artifacts-builder/SKILL.md

#### theme-factory
Style artifacts with 10 pre-set professional themes or generate custom themes on-the-fly. Apply themes to slides, docs, reports, HTML landing pages, etc.
Location: ~/.claude/anthropic-skills/skills/theme-factory/SKILL.md

### Enterprise & Communication Skills

#### brand-guidelines
Apply Anthropic's official brand colors and typography to artifacts. Use when creating branded materials or ensuring visual consistency with Anthropic's design system.
Location: ~/.claude/anthropic-skills/skills/brand-guidelines/SKILL.md

#### internal-comms
Write internal communications like status reports, newsletters, and FAQs. Use when Claude needs to draft professional internal company communications.
Location: ~/.claude/anthropic-skills/skills/internal-comms/SKILL.md

#### doc-coauthoring
Collaborative document editing and co-authoring workflows.
Location: ~/.claude/anthropic-skills/skills/doc-coauthoring/SKILL.md

---

## Custom Skills (User-defined)

### ruby-rails
Ruby on Rails 8 and Ruby 3.2 backend development. Use when working on Rails applications, API development, ActiveRecord models, database migrations, service objects, serializers, RSpec testing, or Ruby code optimization. Triggers on Rails-specific patterns like controllers, models, migrations, jobs, concerns, serializers, and Rails configuration.
Location: ~/.claude/skills/ruby-rails/SKILL.md

### kotlin-java-backend  
<!-- TODO: Crear este skill -->
Kotlin and Java backend services, Spring Boot, API design, and JVM best practices. Use when developing backend services with Kotlin or Java.
Location: ~/.claude/skills/kotlin-java-backend/SKILL.md

### github-actions
<!-- TODO: Crear este skill -->
GitHub Actions workflows, CI/CD pipelines, automated testing, and deployment automation. Use when creating or debugging GitHub Actions workflows.
Location: ~/.claude/skills/github-actions/SKILL.md

---

## Usage Notes

- Claude reads ONLY this discovery file initially
- Full skill content loads on-demand when relevant to the task
- Skill folders must contain a SKILL.md file with YAML frontmatter (name + description)
- Custom skills follow the same structure as Anthropic skills