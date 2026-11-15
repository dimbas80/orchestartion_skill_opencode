---
name: research
description: "Исследовать вопрос по ПЕРВОИСТОЧНИКАМ (официальные доки, код, спецификации — не пересказы) background-агентом; находки — в Markdown-файл репо с цитатами. Триггеры: «исследуй», «собери факты по X», research."
---

Spin up a **background agent** to do the research, so you keep working while it
reads — a background subagent where the harness offers one (e.g. zcode), a
regular subagent dispatch otherwise.

For web sources use the harness's built-in web search/fetch tools (or
dedicated search MCP servers the user has configured); local files and code
are read directly. Whatever the channel, each claim is still cited to its
primary source.

Its job:

1. Investigate the question against **primary sources** (official docs, source code, specs, first-party APIs), not a secondary write-up of them. Follow every claim back to the source that owns it.
2. Write the findings to a single Markdown file, citing each claim's source.
3. Save it where the repo already keeps such notes; match the existing convention, and if there is none, put it somewhere sensible and say where.
