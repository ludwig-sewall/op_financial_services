#!/usr/bin/env python3
"""Fail when a dbt file in this repo breaks the naming conventions.

Projects are discovered from skeleton.json. Rules:
  models/staging/**       stg_<source>__<table>   (source = folder name)
  models/intermediate/**  int_<name>
  models/marts/**         dim_<name> | fct_<name> (plus time_spine_*)
  tests/*.sql             assert_<name> | warn_<name>
  macros/*.sql            snake_case
  YAML property files     start with an underscore
"""

from __future__ import annotations

import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SNAKE = set("abcdefghijklmnopqrstuvwxyz0123456789_")
MART_PREFIXES = ("dim_", "fct_", "time_spine_")


def snake(name: str) -> bool:
    return bool(name) and name[0].isalpha() and set(name) <= SNAKE and name == name.lower()


def model_files(folder: Path) -> list[Path]:
    if not folder.is_dir():
        return []
    return sorted(p for p in folder.rglob("*") if p.suffix in {".sql", ".py"} and "target" not in p.parts)


def check_project(project: Path) -> list[str]:
    found: list[str] = []
    label = project.name
    models = project / "models"
    for path in model_files(models / "staging"):
        source = path.parent.name
        if not path.stem.startswith(f"stg_{source}__") or not snake(path.stem):
            found.append(f"{label}: {path.stem} must be stg_{source}__<table> in snake_case")
    for path in model_files(models / "intermediate"):
        if not path.stem.startswith("int_") or not snake(path.stem):
            found.append(f"{label}: {path.stem} must start with int_ and be snake_case")
    for path in model_files(models / "marts"):
        if not path.stem.startswith(MART_PREFIXES) or not snake(path.stem):
            found.append(f"{label}: {path.stem} must start with dim_ or fct_ and be snake_case")
    for path in model_files(models):
        if path.parent == models:
            found.append(f"{label}: {path.name} must live in staging/, intermediate/ or marts/")
    for path in sorted((models).rglob("*.yml")) if models.is_dir() else []:
        if not path.name.startswith("_"):
            found.append(f"{label}: {path.name} must start with an underscore")
    for path in model_files(project / "tests"):
        if not (path.stem.startswith(("assert_", "warn_")) and snake(path.stem)):
            found.append(f"{label}: test {path.stem} must be assert_* or warn_* in snake_case")
    for path in model_files(project / "macros"):
        if not snake(path.stem):
            found.append(f"{label}: macro {path.stem} must be snake_case")
    return found


def violations() -> list[str]:
    manifest = json.loads((ROOT / "skeleton.json").read_text())
    found: list[str] = []
    for project in manifest["projects"]:
        found += check_project(ROOT / project["subdirectory"])
    return found


def main() -> int:
    bad = violations()
    if bad:
        print("\n".join(bad))
        return 1
    print("naming ok")
    return 0


if __name__ == "__main__":
    sys.exit(main())
