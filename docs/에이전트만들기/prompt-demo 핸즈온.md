# prompt-demo 핸즈온 

```bash
mkdir -p prompt-demo/agents/primary
mkdir -p prompt-demo/agents/subagents
mkdir -p prompt-demo/agents/shared
mkdir -p prompt-demo/generated

cd prompt-demo

touch build-prompts.py

touch opencode.jsonc

touch agents/primary/dbt-orchestrator.md
touch agents/subagents/dbt-discoverer.md
touch agents/shared/dbt-conventions.md
touch agents/shared/naming-rules.md

python build-prompts.py

```
