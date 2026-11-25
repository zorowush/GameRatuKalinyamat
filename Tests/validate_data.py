#!/usr/bin/env python3
"""
Automated validation suite for Jejak Sang Ratu: Kejayaan Jepara.
Validates:
1. All JSON files under Data/ (UTF-8 syntax, schema integrity, historical source tags, quiz keys).
2. All .tscn scene references and project.godot paths.
3. All non-Assets res:// references inside Scripts/.
"""

import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
DATA_DIR = ROOT / "Data"
SCENES_DIR = ROOT / "Scenes"
SCRIPTS_DIR = ROOT / "Scripts"
VALID_TAGS = {"FAKTA", "TRADISI", "FIKSI GAME"}

errors: list[str] = []
checks_passed = 0


def check(condition: bool, message: str) -> None:
    global checks_passed
    if condition:
        checks_passed += 1
    else:
        errors.append(message)


def load_json(rel_path: str):
    full = ROOT / rel_path
    if not full.exists():
        errors.append(f"Missing required JSON file: {rel_path}")
        return None
    try:
        with full.open("r", encoding="utf-8") as f:
            data = json.load(f)
        check(True, f"Parsed {rel_path}")
        return data
    except Exception as exc:
        errors.append(f"Invalid JSON in {rel_path}: {exc}")
        return None


def validate_tag_and_ref(obj: dict, context: str) -> None:
    tag = str(obj.get("source_tag", "")).upper()
    ref = str(obj.get("reference", "")).strip()
    check(tag in VALID_TAGS, f"{context}: invalid source_tag '{tag}' (must be one of {VALID_TAGS})")
    check(len(ref) > 0, f"{context}: empty reference citation")


def validate_missions() -> None:
    data = load_json("Data/Missions/missions.json")
    if not isinstance(data, dict):
        return
    levels = data.get("levels", {})
    for lv in ("1", "2", "3"):
        check(lv in levels, f"missions.json missing level '{lv}'")
        if lv in levels:
            lv_obj = levels[lv]
            scene_rel = str(lv_obj.get("scene", "")).replace("res://", "")
            check((ROOT / scene_rel).exists(), f"missions.json level {lv} scene missing: {scene_rel}")
            steps = lv_obj.get("steps", [])
            check(isinstance(steps, list) and len(steps) >= 4, f"missions.json level {lv} needs >= 4 steps")
            for st in steps:
                check(bool(st.get("id")) and bool(st.get("title")), f"missions.json level {lv} step missing id/title")


def validate_references() -> None:
    data = load_json("Data/Historical_Data/references.json")
    if not isinstance(data, dict):
        return
    refs = data.get("references", [])
    check(isinstance(refs, list) and len(refs) >= 4, "references.json must contain S1-S4")
    for idx, r in enumerate(refs):
        check(bool(r.get("code")) and bool(r.get("citation")), f"references.json item {idx} missing code/citation")
        validate_tag_and_ref(r, f"references.json[{idx}]")


def validate_dialogues() -> None:
    for lv in (1, 2, 3):
        rel = f"Data/Dialogues/level{lv}_dialogues.json"
        data = load_json(rel)
        if not isinstance(data, dict):
            continue
        dialogues = data.get("dialogues", {})
        check(isinstance(dialogues, dict) and len(dialogues) >= 2, f"{rel} must contain >= 2 dialogue sequences")
        for did, dobj in dialogues.items():
            lines = dobj.get("lines", [])
            check(isinstance(lines, list) and len(lines) >= 1, f"{rel}:{did} has no lines")
            for li, line in enumerate(lines):
                ctx = f"{rel}:{did}[{li}]"
                check(bool(str(line.get("speaker", "")).strip()), f"{ctx} missing speaker")
                check(bool(str(line.get("text", "")).strip()), f"{ctx} missing text")
                validate_tag_and_ref(line, ctx)


def validate_archives() -> None:
    seen_ids: set[str] = set()
    for lv in (1, 2, 3):
        rel = f"Data/Historical_Data/level{lv}_archives.json"
        data = load_json(rel)
        if not isinstance(data, dict):
            continue
        archives = data.get("archives", [])
        check(isinstance(archives, list) and len(archives) == 3, f"{rel} must have exactly 3 archives")
        for idx, arc in enumerate(archives):
            ctx = f"{rel}[{idx}]"
            aid = str(arc.get("id", "")).strip()
            check(bool(aid) and aid not in seen_ids, f"{ctx} missing or duplicate archive id '{aid}'")
            seen_ids.add(aid)
            check(bool(str(arc.get("title", "")).strip()), f"{ctx} missing title")
            check(bool(str(arc.get("content", "")).strip()), f"{ctx} missing content")
            validate_tag_and_ref(arc, ctx)
    check(len(seen_ids) == 9, f"Expected 9 unique archives across 3 levels, got {len(seen_ids)}")


def validate_level1_challenges() -> None:
    chrono = load_json("Data/Historical_Data/level1_chronology.json")
    if isinstance(chrono, dict):
        validate_tag_and_ref(chrono, "level1_chronology.json")
        events = chrono.get("events", [])
        check(len(events) == 5, "level1_chronology.json must have 5 events")
        orders = sorted(int(ev.get("order", -1)) for ev in events)
        check(orders == [1, 2, 3, 4, 5], f"level1_chronology.json orders must be 1..5, got {orders}")
        for i, ev in enumerate(events):
            validate_tag_and_ref(ev, f"level1_chronology.json:events[{i}]")

    tapa = load_json("Data/Historical_Data/level1_tapa_investigation.json")
    if isinstance(tapa, dict):
        validate_tag_and_ref(tapa, "level1_tapa_investigation.json")
        cards = tapa.get("evidence_cards", [])
        check(len(cards) == 4, "level1_tapa_investigation.json must have 4 evidence cards")
        for i, c in enumerate(cards):
            validate_tag_and_ref(c, f"level1_tapa_investigation.json:cards[{i}]")
        concs = tapa.get("conclusions", [])
        check(len(concs) >= 3, "level1_tapa_investigation.json must have >= 3 conclusions")
        correct_count = sum(1 for c in concs if c.get("is_correct") is True)
        check(correct_count == 1, f"level1_tapa_investigation.json must have exactly 1 correct conclusion, got {correct_count}")


def validate_level2_challenges() -> None:
    trade = load_json("Data/Historical_Data/level2_trade.json")
    if isinstance(trade, dict):
        validate_tag_and_ref(trade, "level2_trade.json")
        ports = set(trade.get("ports", []))
        check(ports == {"Malaka", "Maluku", "Banten", "Makassar"}, f"Unexpected ports in level2_trade.json: {ports}")
        turns = trade.get("turns", [])
        check(len(turns) == 6, f"level2_trade.json must have 6 turns, got {len(turns)}")
        for i, t in enumerate(turns):
            ctx = f"level2_trade.json:turns[{i}]"
            check(t.get("correct_port") in ports, f"{ctx} invalid correct_port '{t.get('correct_port')}'")
            check(bool(t.get("feedback_correct")) and bool(t.get("feedback_wrong")), f"{ctx} missing feedback")
            validate_tag_and_ref(t, ctx)

    dip = load_json("Data/Historical_Data/level2_diplomacy.json")
    if isinstance(dip, dict):
        validate_tag_and_ref(dip, "level2_diplomacy.json")
        missions = dip.get("missions", [])
        check(len(missions) == 3, f"level2_diplomacy.json must have 3 missions, got {len(missions)}")
        for i, m in enumerate(missions):
            ctx = f"level2_diplomacy.json:missions[{i}]"
            validate_tag_and_ref(m, ctx)
            opts = m.get("options", [])
            correct_cnt = sum(1 for o in opts if o.get("is_correct") is True)
            check(correct_cnt == 1, f"{ctx} must have exactly 1 correct option, got {correct_cnt}")


def validate_level3_challenges() -> None:
    exp = load_json("Data/Historical_Data/level3_expedition.json")
    if isinstance(exp, dict):
        validate_tag_and_ref(exp, "level3_expedition.json")
        check(int(exp.get("max_spirit", 0)) == 3, "level3_expedition.json max_spirit must be 3")
        scenarios = exp.get("scenarios", [])
        check(len(scenarios) == 4, f"level3_expedition.json must have 4 scenarios, got {len(scenarios)}")
        for i, sc in enumerate(scenarios):
            ctx = f"level3_expedition.json:scenarios[{i}]"
            validate_tag_and_ref(sc, ctx)
            opts = sc.get("options", [])
            correct_cnt = sum(1 for o in opts if o.get("is_correct") is True)
            check(correct_cnt == 1, f"{ctx} must have exactly 1 correct option, got {correct_cnt}")
        ref = exp.get("reflection", {})
        validate_tag_and_ref(ref, "level3_expedition.json:reflection")
        factors = ref.get("factors", [])
        true_cnt = sum(1 for f in factors if f.get("is_true") is True)
        false_cnt = sum(1 for f in factors if f.get("is_true") is False)
        check(true_cnt == 4 and false_cnt == 1, f"reflection must have 4 true + 1 false factors, got {true_cnt}/{false_cnt}")

    quiz = load_json("Data/Historical_Data/level3_heritage_quiz.json")
    if isinstance(quiz, dict):
        heritage = quiz.get("heritage_items", [])
        check(len(heritage) == 3, f"level3_heritage_quiz.json must have 3 heritage items, got {len(heritage)}")
        for i, h in enumerate(heritage):
            validate_tag_and_ref(h, f"level3_heritage_quiz.json:heritage[{i}]")
        questions = quiz.get("questions", [])
        check(len(questions) == 10, f"level3_heritage_quiz.json must have 10 quiz questions, got {len(questions)}")
        correct_indices: set[int] = set()
        for i, q in enumerate(questions):
            ctx = f"level3_heritage_quiz.json:questions[{i}]"
            opts = q.get("options", [])
            cidx = q.get("correct_index", -1)
            check(isinstance(opts, list) and len(opts) == 4, f"{ctx} must have 4 options")
            check(isinstance(cidx, int) and 0 <= cidx < len(opts), f"{ctx} invalid correct_index {cidx}")
            if isinstance(cidx, int):
                correct_indices.add(cidx)
            check(bool(str(q.get("explanation", "")).strip()), f"{ctx} missing explanation")
            validate_tag_and_ref(q, ctx)
        check(len(correct_indices) >= 3, f"Quiz answer indices should be diversified, got {correct_indices}")


def validate_res_paths() -> None:
    res_pattern = re.compile(r'res://[A-Za-z0-9_./\-]+')

    # Check project.godot
    pg = ROOT / "project.godot"
    pg_text = pg.read_text(encoding="utf-8")
    for match in res_pattern.findall(pg_text):
        rel = match.replace("res://", "")
        check((ROOT / rel).exists(), f"project.godot references missing resource: {match}")

    # Check all .tscn files
    tscn_files = sorted(SCENES_DIR.rglob("*.tscn"))
    check(len(tscn_files) >= 16, f"Expected >= 16 scene files, found {len(tscn_files)}")
    for tscn in tscn_files:
        text = tscn.read_text(encoding="utf-8")
        check("[gd_scene" in text, f"Invalid .tscn header in {tscn.relative_to(ROOT)}")
        for match in res_pattern.findall(text):
            rel = match.replace("res://", "")
            check((ROOT / rel).exists(), f"{tscn.relative_to(ROOT)} references missing resource: {match}")

    # Check all .gd files (skip optional Assets/ paths because AssetLoader has fallbacks)
    gd_files = sorted(SCRIPTS_DIR.rglob("*.gd"))
    check(len(gd_files) >= 20, f"Expected >= 20 script files, found {len(gd_files)}")
    for gd in gd_files:
        text = gd.read_text(encoding="utf-8")
        for match in res_pattern.findall(text):
            if match.startswith("res://Assets/"):
                continue
            rel = match.replace("res://", "")
            check((ROOT / rel).exists(), f"{gd.relative_to(ROOT)} references missing path: {match}")


def main() -> int:
    print("=== Validasi Data & Struktur Proyek: Jejak Sang Ratu ===")
    validate_missions()
    validate_references()
    validate_dialogues()
    validate_archives()
    validate_level1_challenges()
    validate_level2_challenges()
    validate_level3_challenges()
    validate_res_paths()

    print(f"Total checks passed: {checks_passed}")
    if errors:
        print(f"FAILED with {len(errors)} error(s):")
        for e in errors:
            print(f"  - {e}")
        return 1
    print("ALL DATA, SCHEMA, HISTORICAL TAGS & RESOURCE PATHS VALID (0 errors).")
    return 0


if __name__ == "__main__":
    sys.exit(main())
