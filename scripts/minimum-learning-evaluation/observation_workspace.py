from __future__ import annotations

import argparse
import hashlib
import json
import shutil
import subprocess
import sys
import tempfile
import zipfile
from pathlib import Path, PurePosixPath
from typing import Any


PUBLIC_SHA256 = "1d6c0f5bbd167c1865546a8fc40223a074113ad8f69d6284ffe3bf5ac56055b6"
PULSE_SHA256 = "d9ecd2cf2001d5fd0bd839fc3799560691268ae8e736112b3ec6ba82bd98c6b6"
PRODUCT_ASSETS = ("minimum_learning_mvp.py", "schema.sql")
TASKS = ("TASK-01", "TASK-02", "TASK-03")
CONDITIONS = ("B0", "Product")
UPDATE_TASKS = {
    "TASK-01": "public/change_pulse/TASK-01/ORBIT_변경합의서_2_서명본_2026-04-02.md",
    "TASK-03": "public/change_pulse/TASK-03/HELIOS_고객변경승인_2026-07-30.md",
}
FORBIDDEN_PATH_PARTS = ("sealed", "truth", "evaluator", "verdict", "ground_truth")
FIXED_ZIP_TIME = (1980, 1, 1, 0, 0, 0)


def sha256_bytes(value: bytes) -> str:
    return hashlib.sha256(value).hexdigest()


def sha256_file(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def json_bytes(value: Any) -> bytes:
    return (json.dumps(value, ensure_ascii=False, indent=2, sort_keys=True) + "\n").encode("utf-8")


def log_schema_bytes(log_type: str) -> bytes:
    return json_bytes({
        "record_type": "schema",
        "schema_version": "1.0",
        "log_type": log_type,
        "append_only": True,
    })


def observation_template(task_id: str, condition: str) -> bytes:
    text = f"""# Initial Observation Record

- Task ID: {task_id}
- Condition: {condition}
- Run ID:
- Isolated Context ID:
- Start UTC:
- End UTC:

## Observation

- Core reconstruction claims:
- Evidence used for each claim:
- Originals opened:
- Confirmed / conditional / conflict / needs verification / cannot determine:
- Human preparation:
- Human reconstruction work:
- Human verification work:
- Preparation seconds:
- Reconstruction seconds:
- Verification seconds:
- Human activity types:
- Original-open count:
- Manual correction count:
- Follow-up submission count:
- Product-only persistent state object/relation used (Product only):

## Frozen submission

- Final answer:
- Next action:
- Termination reason:
"""
    return text.encode("utf-8")


def common_runtime() -> dict[str, Any]:
    return {
        "model_id": "gpt-5.6-sol",
        "reasoning_effort": "high",
        "reasoning_mode": "standard",
        "parser": "UTF-8 Markdown/JSON direct read; no OCR",
        "search": "ripgrep 15.2.0 exact/regex plus direct full-corpus reads",
        "reranker": "none",
        "limits": {
            "input_tokens_per_phase": 120000,
            "output_tokens_per_phase": 12000,
            "user_submissions_per_phase": 6,
            "wall_clock_minutes_per_phase": 60,
            "external_api_spend_usd": 0,
        },
        "limit_enforcement": "operator-enforced stop at the first configured limit",
        "network": False,
        "web_search": False,
        "apps_connectors_mcp": False,
        "original_source_open": True,
        "human_cost_log": "logs/HUMAN_COST_LOG.jsonl",
        "execution_log": "logs/EXECUTION_LOG.jsonl",
    }


def initial_boundary(task_id: str, condition: str, inventory: list[str]) -> dict[str, Any]:
    product = condition == "Product"
    return {
        "package_kind": "OBSERVATION_INITIAL",
        "task_id": task_id,
        "condition": condition,
        "workspace_rule": "Extract this package into an empty workspace. Mount or copy no other files.",
        "allowed_inventory": sorted(inventory),
        "common_runtime": common_runtime(),
        "persistent_control_state": product,
        "initial_state": "empty SQLite state created after extraction" if product else "no persistent control state",
        "condition_only_assets": ["product/minimum_learning_mvp.py", "product/schema.sql"] if product else [],
        "cross_task_state": False,
        "cross_condition_state": False,
        "additional_evaluation_gates": [],
    }


def update_boundary(task_id: str, condition: str, inventory: list[str]) -> dict[str, Any]:
    return {
        "package_kind": "OBSERVATION_UPDATE",
        "task_id": task_id,
        "condition": condition,
        "workspace_rule": "Apply only to the matching frozen initial workspace after both initial condition outputs are frozen.",
        "allowed_inventory": sorted(inventory),
        "common_runtime": common_runtime(),
        "continuity": "same Task x Condition notes and Product state only",
        "cross_task_state": False,
        "cross_condition_state": False,
        "additional_evaluation_gates": [],
    }


def write_deterministic_zip(path: Path, entries: dict[str, bytes]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with zipfile.ZipFile(path, "w", compression=zipfile.ZIP_DEFLATED, compresslevel=9) as archive:
        for name in sorted(entries):
            info = zipfile.ZipInfo(name, FIXED_ZIP_TIME)
            info.compress_type = zipfile.ZIP_DEFLATED
            info.external_attr = 0o100644 << 16
            info.create_system = 3
            archive.writestr(info, entries[name])


def read_zip_entries(path: Path) -> dict[str, bytes]:
    result: dict[str, bytes] = {}
    with zipfile.ZipFile(path, "r") as archive:
        for info in archive.infolist():
            if info.is_dir():
                continue
            name = PurePosixPath(info.filename).as_posix()
            if name.startswith("/") or ".." in PurePosixPath(name).parts:
                raise ValueError(f"unsafe archive path: {name}")
            if name in result:
                raise ValueError(f"duplicate archive path: {name}")
            result[name] = archive.read(info)
    return result


def assert_no_forbidden_paths(names: list[str]) -> None:
    for name in names:
        lowered = name.lower()
        if any(part in lowered for part in FORBIDDEN_PATH_PARTS):
            raise ValueError(f"forbidden observation path: {name}")


def build(args: argparse.Namespace) -> dict[str, Any]:
    public_package = Path(args.public_package).resolve()
    pulse_package = Path(args.pulse_package).resolve()
    product_dir = Path(args.product_dir).resolve()
    output_dir = Path(args.output_dir).resolve()

    if sha256_file(public_package) != PUBLIC_SHA256:
        raise ValueError("Public Run Package hash mismatch")
    if sha256_file(pulse_package) != PULSE_SHA256:
        raise ValueError("Change Pulse Package hash mismatch")

    public_entries = read_zip_entries(public_package)
    if not public_entries or any(not name.startswith("public/main/") for name in public_entries):
        raise ValueError("initial Public package must contain only public/main files")
    assert_no_forbidden_paths(list(public_entries))

    pulse_entries = read_zip_entries(pulse_package)
    if set(pulse_entries) != set(UPDATE_TASKS.values()):
        raise ValueError("Change Pulse package inventory mismatch")
    assert_no_forbidden_paths(list(pulse_entries))

    product_assets: dict[str, bytes] = {}
    for name in PRODUCT_ASSETS:
        path = product_dir / name
        if not path.is_file():
            raise ValueError(f"missing Product asset: {path}")
        product_assets[f"product/{name}"] = path.read_bytes()

    if output_dir.exists():
        if any(output_dir.iterdir()):
            raise ValueError(f"output directory must be absent or empty: {output_dir}")
    else:
        output_dir.mkdir(parents=True)

    packages: list[dict[str, Any]] = []
    public_payload = {name: data for name, data in public_entries.items()}
    common_logs = {
        "logs/HUMAN_COST_LOG.jsonl": log_schema_bytes("human_cost"),
        "logs/EXECUTION_LOG.jsonl": log_schema_bytes("execution"),
    }

    for task_id in TASKS:
        for condition in CONDITIONS:
            entries = dict(public_payload)
            entries.update(common_logs)
            entries["logs/OBSERVATION.md"] = observation_template(task_id, condition)
            if condition == "Product":
                entries.update(product_assets)
            inventory = sorted([*entries, "runtime/EXECUTION_BOUNDARY.json"])
            entries["runtime/EXECUTION_BOUNDARY.json"] = json_bytes(initial_boundary(task_id, condition, inventory))
            package = output_dir / f"{task_id}_{condition}_INITIAL.zip"
            write_deterministic_zip(package, entries)
            packages.append({
                "kind": "initial",
                "task_id": task_id,
                "condition": condition,
                "file": package.name,
                "sha256": sha256_file(package),
                "bytes": package.stat().st_size,
            })

    for task_id, source_path in UPDATE_TASKS.items():
        for condition in CONDITIONS:
            entries = {source_path: pulse_entries[source_path]}
            inventory = sorted([*entries, "runtime/EXECUTION_BOUNDARY.json"])
            entries["runtime/EXECUTION_BOUNDARY.json"] = json_bytes(update_boundary(task_id, condition, inventory))
            package = output_dir / f"{task_id}_{condition}_UPDATE.zip"
            write_deterministic_zip(package, entries)
            packages.append({
                "kind": "update",
                "task_id": task_id,
                "condition": condition,
                "file": package.name,
                "sha256": sha256_file(package),
                "bytes": package.stat().st_size,
            })

    manifest = {
        "version": "0.3",
        "status": "OBSERVATION_DISTRIBUTION_BUILT",
        "boundary": "Observation packages contain only released public input, condition assets, common runtime declarations, and logging files. Evaluation workspace is not packaged or mounted.",
        "public_run_package_sha256": PUBLIC_SHA256,
        "change_pulse_package_sha256": PULSE_SHA256,
        "packages": packages,
    }
    manifest_path = output_dir / "OBSERVATION_PACKAGE_MANIFEST.json"
    manifest_path.write_bytes(json_bytes(manifest))
    sidecar = "".join(f"{item['sha256']}  {item['file']}\n" for item in sorted(packages, key=lambda item: item["file"]))
    (output_dir / "OBSERVATION_DISTRIBUTION_SHA256.txt").write_text(sidecar, encoding="utf-8", newline="\n")
    return {**manifest, "manifest_sha256": sha256_file(manifest_path)}


def validate(args: argparse.Namespace) -> dict[str, Any]:
    distribution = Path(args.distribution).resolve()
    manifest_path = distribution / "OBSERVATION_PACKAGE_MANIFEST.json"
    manifest = json.loads(manifest_path.read_text(encoding="utf-8"))
    errors: list[str] = []
    boundaries: list[dict[str, Any]] = []
    initial_public_hashes: dict[str, dict[str, str]] = {}

    for item in manifest["packages"]:
        package = distribution / item["file"]
        if not package.is_file():
            errors.append(f"missing package: {item['file']}")
            continue
        actual_hash = sha256_file(package)
        if actual_hash != item["sha256"]:
            errors.append(f"package hash mismatch: {item['file']}")
        entries = read_zip_entries(package)
        names = sorted(entries)
        try:
            assert_no_forbidden_paths(names)
        except ValueError as error:
            errors.append(str(error))
        boundary_name = "runtime/EXECUTION_BOUNDARY.json"
        if boundary_name not in entries:
            errors.append(f"boundary missing: {item['file']}")
            continue
        boundary = json.loads(entries[boundary_name].decode("utf-8"))
        boundaries.append(boundary)
        if sorted(boundary["allowed_inventory"]) != names:
            errors.append(f"inventory mismatch: {item['file']}")
        if boundary["task_id"] != item["task_id"] or boundary["condition"] != item["condition"]:
            errors.append(f"boundary identity mismatch: {item['file']}")
        if boundary["additional_evaluation_gates"] != []:
            errors.append(f"unexpected evaluation gate: {item['file']}")
        if item["kind"] == "initial":
            if any("change_pulse" in name.lower() for name in names):
                errors.append(f"initial package exposes update path: {item['file']}")
            if any(Path(path).name in b"\n".join(entries.values()).decode("utf-8", errors="ignore") for path in UPDATE_TASKS.values()):
                errors.append(f"initial package exposes update filename: {item['file']}")
            public_hashes = {
                name: sha256_bytes(data)
                for name, data in entries.items()
                if name.startswith("public/main/")
            }
            initial_public_hashes[item["file"]] = public_hashes
            has_product = any(name.startswith("product/") for name in names)
            if has_product != (item["condition"] == "Product"):
                errors.append(f"Product asset boundary mismatch: {item['file']}")
            if any(name.endswith((".sqlite", ".sqlite3", ".db")) for name in names):
                errors.append(f"initial package contains durable state: {item['file']}")
        else:
            expected_update = UPDATE_TASKS[item["task_id"]]
            update_inputs = [name for name in names if name.startswith("public/change_pulse/")]
            if update_inputs != [expected_update]:
                errors.append(f"update package scope mismatch: {item['file']}")

    public_sets = list(initial_public_hashes.values())
    if not public_sets or any(value != public_sets[0] for value in public_sets[1:]):
        errors.append("initial public corpus differs across Task x Condition packages")

    common = [boundary["common_runtime"] for boundary in boundaries]
    if not common or any(value != common[0] for value in common[1:]):
        errors.append("common runtime/model/limits differ across packages")

    with tempfile.TemporaryDirectory(prefix="aer-observation-isolation-") as temp_name:
        temp_root = Path(temp_name)
        roots: dict[tuple[str, str], Path] = {}
        for item in manifest["packages"]:
            if item["kind"] != "initial":
                continue
            root = temp_root / item["task_id"] / item["condition"]
            root.mkdir(parents=True)
            with zipfile.ZipFile(distribution / item["file"], "r") as archive:
                archive.extractall(root)
            roots[(item["task_id"], item["condition"])] = root

        for (task_id, condition), root in roots.items():
            existing_state = list(root.rglob("*.sqlite3"))
            if existing_state:
                errors.append(f"non-clean initial state: {task_id}/{condition}")
            if condition == "Product":
                db = root / "state" / "control.sqlite3"
                db.parent.mkdir()
                command = [
                    sys.executable,
                    str(root / "product" / "minimum_learning_mvp.py"),
                    "init",
                    "--db",
                    str(db),
                ]
                completed = subprocess.run(command, capture_output=True, text=True, encoding="utf-8")
                if completed.returncode != 0 or not db.is_file():
                    errors.append(f"Product clean start failed: {task_id}")

        state_files = {
            key: [path.resolve() for path in root.rglob("*.sqlite3")]
            for key, root in roots.items()
        }
        for key, files in state_files.items():
            expected = 1 if key[1] == "Product" else 0
            if len(files) != expected:
                errors.append(f"condition state count mismatch: {key[0]}/{key[1]}")
            for other_key, other_root in roots.items():
                if other_key == key:
                    continue
                if any(str(path).startswith(str(other_root.resolve())) for path in files):
                    errors.append(f"condition state leaked: {key} -> {other_key}")

    return {
        "status": "PASS" if not errors else "HOLD",
        "errors": errors,
        "package_count": len(manifest["packages"]),
        "initial_package_count": sum(item["kind"] == "initial" for item in manifest["packages"]),
        "update_package_count": sum(item["kind"] == "update" for item in manifest["packages"]),
        "sealed_or_evaluator_paths_packaged": False if not any("forbidden observation path" in error for error in errors) else True,
        "common_runtime_equal": "common runtime/model/limits differ across packages" not in errors,
        "clean_task_condition_start": not any("initial state" in error or "clean start" in error for error in errors),
        "condition_state_leak": any("state leaked" in error for error in errors),
        "additional_evaluation_gates": 0,
        "manifest_sha256": sha256_file(manifest_path),
    }


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description="Build and validate clean AER observation packages without sealed/evaluator assets")
    sub = parser.add_subparsers(dest="command", required=True)
    build_parser = sub.add_parser("build")
    build_parser.add_argument("--public-package", required=True)
    build_parser.add_argument("--pulse-package", required=True)
    build_parser.add_argument("--product-dir", required=True)
    build_parser.add_argument("--output-dir", required=True)
    validate_parser = sub.add_parser("validate")
    validate_parser.add_argument("--distribution", required=True)
    return parser


def main() -> int:
    args = build_parser().parse_args()
    try:
        result = build(args) if args.command == "build" else validate(args)
        print(json.dumps(result, ensure_ascii=False, indent=2, sort_keys=True))
        return 0 if result.get("status") != "HOLD" else 2
    except (OSError, ValueError, KeyError, json.JSONDecodeError, zipfile.BadZipFile) as error:
        print(json.dumps({"status": "ERROR", "error": str(error)}, ensure_ascii=False), file=sys.stderr)
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
