---
name: research
description: "Исследовать вопрос по ПЕРВОИСТОЧНИКАМ (официальные доки, код, спецификации — не пересказы) background-агентом; находки — в Markdown-файл репо с цитатами. Триггеры: «исследуй», «собери факты по X», research. Веб-источники — через tavily-скиллы."
---

Spin up a **background agent** to do the research, so you keep working while it
reads — in the multi-profile setup that is a kanban task for the orchestrator
profile; otherwise a background in-session subagent.

For web sources use the tavily skills (`tavily-search`, `tavily-research`); local files and code are read directly. Whatever the channel, each claim is still cited to its primary source.

**Dependency:** tavily-* are hub skills (CLI `tvly` + `TAVILY_API_KEY`), not part of this set — they ship in the default and orchestrator profiles. If a profile has no tavily skills, use the built-in `web_search` / `web_extract` tools and say in the report which channel was used.

Its job:

1. Investigate the question against **primary sources** (official docs, source code, specs, first-party APIs), not a secondary write-up of them. Follow every claim back to the source that owns it.
2. Write the findings to a single Markdown file, citing each claim's source.
3. Save it where the repo already keeps such notes; match the existing convention, and if there is none, put it somewhere sensible and say where.
