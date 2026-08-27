#!/usr/bin/env python3
import json, re, sys
from pathlib import Path

def to_person_id(name: str) -> str:
    base = re.sub(r"[^A-Za-z]+", "_", name).strip("_").upper()
    return f"P_{base}"[:120]

def normalize_name(raw: str):
    if "##" in raw:
        name, note = raw.split("##", 1)
        return name.strip(), note.strip()
    return raw.strip(), ""

def y_auc(auc: int):
    return [{
        "rep":"ymd","calendar":"AUC","scale":"native",
        "certainty":"medium","approx":False,"ymd":{"year":auc}
    }]

def convert(input_rows):
    persons = {}
    tenures = []

    def ensure_person(nom):
        pid = to_person_id(nom)
        if pid not in persons:
            persons[pid] = {
                "id": pid,
                "name": {"normalized": nom},
                "variants": [
                    {"form": nom, "lang":"la","script":"Latn","kind":"source","casus":"nom"}
                ]
            }
        return pid

    for row in input_rows:
        auc = int(row["auc"])
        notes_year = row.get("notes","").strip()

        # Ordinarii
        for idx, raw in enumerate(row.get("ordinarii", []), start=1):
            name, note = normalize_name(raw)
            pid = ensure_person(name)
            tenures.append({
                "id": f"TENURE_AUC_{auc}_CONSUL_{idx}",
                "office_id": "OFFICE_CONSUL_ORDINARIUS",
                "person_id": pid,
                "ordinal": idx,
                "start": y_auc(auc), "end": y_auc(auc),
                "certainty": "medium",
                "status": "recognized",
                "notes": "; ".join([t for t in (notes_year, note) if t])
            })

        # Suffects
        for j, raw in enumerate(row.get("suffects", []), start=1):
            name, note = normalize_name(raw)
            pid = ensure_person(name)
            tenures.append({
                "id": f"TENURE_AUC_{auc}_SUFFECT_{j}",
                "office_id": "OFFICE_CONSUL_SUFFECTUS",
                "person_id": pid,
                "ordinal": j,
                "start": y_auc(auc), "end": y_auc(auc),
                "certainty": "medium",
                "status": "recognized",
                "notes": "; ".join([t for t in (notes_year, note) if t]) or "Suffect consul"
            })

    return list(persons.values()), tenures

def main(argv):
    if len(argv) < 2:
        print("Usage: python roman_consul_converter.py <input_auc_block.json>")
        print("Input rows: [{'auc': 245, 'ordinarii': [...], 'suffects': [...], 'notes': '...'}, ...]")
        sys.exit(1)

    in_path = Path(argv[1])
    if not in_path.exists():
        print(f"Input not found: {in_path}")
        sys.exit(2)

    with open(in_path, "r", encoding="utf-8") as f:
        rows = json.load(f)

    persons, tenures = convert(rows)

    # Derive output stems from input name: input_auc_0245_0344.json -> persons_auc_0245_0344.json
    stem = in_path.stem
    suffix = ""
    m = re.search(r"(auc[_\d]+)", stem, flags=re.I)
    if m:
        suffix = m.group(1)
    else:
        suffix = stem

    out_persons = in_path.with_name(f"persons_{suffix}.json")
    out_tenures = in_path.with_name(f"tenures_{suffix}.json")

    with open(out_persons, "w", encoding="utf-8") as f:
        json.dump(persons, f, ensure_ascii=False, indent=2)
    with open(out_tenures, "w", encoding="utf-8") as f:
        json.dump(tenures, f, ensure_ascii=False, indent=2)

    print(f"Wrote: {out_persons}")
    print(f"Wrote: {out_tenures}")

if __name__ == "__main__":
    main(sys.argv)
