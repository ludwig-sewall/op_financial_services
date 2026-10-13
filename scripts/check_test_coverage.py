#!/usr/bin/env python3
"""Fail when a model or source table has no primary-key / grain test; print test coverage by type.

Rules (per project in skeleton.json):
  - every model (.sql/.py under models/) is described in a YAML file
  - every model has a grain test: `unique` on a column, or a model-level
    `dbt_utils.unique_combination_of_columns`
  - every source table has a `unique` test on its key
  - every public model has an enforced contract (SQL models)
  - every project has at least one unit test and one singular test
"""

from __future__ import annotations

import json
import sys
from collections import Counter
from pathlib import Path

import yaml

ROOT = Path(__file__).resolve().parents[1]
GRAIN_TESTS = {"unique", "dbt_utils.unique_combination_of_columns"}


def test_name(t) -> str:
    return t if isinstance(t, str) else next(iter(t))


def kind(name: str) -> str:
    if "." not in name:
        return "built-in generic"
    pkg = name.split(".")[0]
    return "custom generic (platform)" if pkg == "platform" else f"package ({pkg})"


def check_project(base: Path) -> tuple[list[str], Counter]:
    problems: list[str] = []
    counts: Counter = Counter()
    label = base.name
    docs, unit_tests, sources = {}, 0, []
    for y in sorted(base.glob("models/**/*.yml")):
        doc = yaml.safe_load(y.read_text()) or {}
        for m in doc.get("models") or []:
            docs[m["name"]] = m
        unit_tests += len(doc.get("unit_tests") or [])
        for s in doc.get("sources") or []:
            sources += [(s["name"], t) for t in s.get("tables") or []]
    files = [p.stem for p in base.glob("models/**/*") if p.suffix in {".sql", ".py"}]
    for name in sorted(files):
        m = docs.get(name)
        if m is None:
            problems.append(f"{label}: model {name} has no YAML entry")
            continue
        names = [test_name(t) for t in m.get("data_tests") or []]
        for c in m.get("columns") or []:
            names += [test_name(t) for t in c.get("data_tests") or []]
        for n in names:
            counts[kind(n)] += 1
        if not GRAIN_TESTS & set(names):
            problems.append(f"{label}: model {name} has no grain test (unique / unique_combination_of_columns)")
        cfg = m.get("config") or {}
        if cfg.get("access") == "public" and not list(base.glob(f"models/**/{name}.py")):
            if not (cfg.get("contract") or {}).get("enforced"):
                problems.append(f"{label}: public model {name} has no enforced contract")
    for src, t in sources:
        tests = [test_name(x) for c in t.get("columns") or [] for x in c.get("data_tests") or []]
        counts["source"] += len(tests)
        if "unique" not in tests:
            problems.append(f"{label}: source {src}.{t['name']} has no unique key test")
    singular = [p for p in base.glob("tests/**/*.sql")]
    counts["singular"] += len(singular)
    counts["unit"] += unit_tests
    if docs and unit_tests == 0:
        problems.append(f"{label}: no unit tests")
    if docs and not singular:
        problems.append(f"{label}: no singular tests")
    counts["models"] = len(files)
    return problems, counts


def main() -> int:
    manifest = json.loads((ROOT / "skeleton.json").read_text())
    problems: list[str] = []
    print(f"{'project':<18} {'models':>6} {'built-in':>9} {'custom':>7} {'package':>8} {'source':>7} {'singular':>9} {'unit':>5}")
    for p in manifest["projects"]:
        found, c = check_project(ROOT / p["subdirectory"])
        problems += found
        pkg = sum(v for k, v in c.items() if k.startswith("package"))
        print(f"{p['key']:<18} {c['models']:>6} {c['built-in generic']:>9} {c['custom generic (platform)']:>7} "
              f"{pkg:>8} {c['source']:>7} {c['singular']:>9} {c['unit']:>5}")
    if problems:
        print("\n" + "\n".join(problems))
        return 1
    print("\ntest coverage ok")
    return 0


if __name__ == "__main__":
    sys.exit(main())
