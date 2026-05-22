#!/usr/bin/env python3
"""Batch-convert DB2 SQL files to Snowflake SQL one file at a time.

This script reads one .sql file per request, sends only that file's content to an
OpenAI-compatible chat-completions endpoint, writes the converted SQL to an
output folder, and records failures for files that still fail after retries.
It also supports retrying previously failed files from the failed folder.
"""

from __future__ import annotations

import argparse
import json
import os
import sys
import time
import urllib.error
import urllib.request
from dataclasses import dataclass
from pathlib import Path
from typing import Any


SOURCE_DB = "DB2"
TARGET_DB = "Snowflake"
DEFAULT_MODEL = "gpt-4.1-mini"
DEFAULT_TIMEOUT = 120
DEFAULT_LOG_FILE = "logs/conversion.jsonl"


@dataclass
class AttemptResult:
    ok: bool
    content: str = ""
    error_type: str = ""
    message: str = ""


def eprint(*args: object) -> None:
    print(*args, file=sys.stderr)


def load_text(path: Path) -> str:
    return path.read_text(encoding="utf-8")


def load_json(path: Path) -> dict[str, Any]:
    return json.loads(path.read_text(encoding="utf-8"))


def save_text(path: Path, content: str) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(content, encoding="utf-8")


def save_json(path: Path, payload: dict[str, Any]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(payload, ensure_ascii=False, indent=2), encoding="utf-8")


def append_jsonl(path: Path, payload: dict[str, Any]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("a", encoding="utf-8") as handle:
        handle.write(json.dumps(payload, ensure_ascii=False) + "\n")


def delete_if_exists(path: Path) -> None:
    try:
        path.unlink()
    except FileNotFoundError:
        pass


def strip_code_fences(text: str) -> str:
    stripped = text.strip()
    if stripped.startswith("```"):
        lines = stripped.splitlines()
        if len(lines) >= 2 and lines[0].startswith("```") and lines[-1].startswith("```"):
            inner = "\n".join(lines[1:-1]).strip()
            if inner.lower().startswith("sql\n"):
                inner = inner[4:]
            return inner.strip()
    return stripped


def extract_section(md_text: str, heading: str) -> str:
    marker = f"## {heading}"
    start = md_text.find(marker)
    if start < 0:
        raise ValueError(f"Missing section: {heading}")
    body = md_text[start + len(marker):]
    next_heading = body.find("\n## ")
    if next_heading >= 0:
        body = body[:next_heading]
    return body.strip()


def extract_fenced_block(section_text: str) -> str:
    start = section_text.find("```text")
    if start < 0:
        start = section_text.find("```")
    if start < 0:
        raise ValueError("No fenced prompt block found")
    body = section_text[start:]
    first_newline = body.find("\n")
    if first_newline < 0:
        raise ValueError("Malformed fenced block")
    body = body[first_newline + 1:]
    end = body.rfind("```")
    if end < 0:
        raise ValueError("Unterminated fenced prompt block")
    return body[:end].strip()


def extract_system_prompt(prompt_block: str) -> str:
    marker = "[User]"
    idx = prompt_block.find(marker)
    if idx < 0:
        raise ValueError("Prompt block missing [User] marker")
    system_part = prompt_block[:idx].strip()
    if system_part.startswith("[System]"):
        system_part = system_part[len("[System]"):].strip()
    return system_part


def extract_user_template(prompt_block: str) -> str:
    marker = "[User]"
    idx = prompt_block.find(marker)
    if idx < 0:
        raise ValueError("Prompt block missing [User] marker")
    user_part = prompt_block[idx + len(marker):].strip()
    return user_part


def load_failed_context(failed_sql_path: Path) -> tuple[str, str, str]:
    meta_path = Path(str(failed_sql_path) + ".json")
    if not meta_path.is_file():
        return "failed", "", ""
    try:
        data = load_json(meta_path)
    except Exception:  # noqa: BLE001
        return "failed", "", ""
    return (
        str(data.get("status") or "failed"),
        str(data.get("error_type") or ""),
        str(data.get("message") or ""),
    )


def render_loop_prompt(template: str, file_path: str, sql_content: str, prev_status: str, error_type: str, error_message: str) -> str:
    return (
        template
        .replace("{{FILE_PATH}}", file_path)
        .replace("{{SQL_CONTENT}}", sql_content)
        .replace("{{PREVIOUS_STATUS}}", prev_status)
        .replace("{{ERROR_TYPE}}", error_type)
        .replace("{{ERROR_MESSAGE}}", error_message)
    )


def build_messages(system_prompt: str, user_prompt: str) -> list[dict[str, str]]:
    return [
        {"role": "system", "content": system_prompt},
        {"role": "user", "content": user_prompt},
    ]


def call_openai_compatible(
    base_url: str,
    api_key: str,
    model: str,
    messages: list[dict[str, str]],
    timeout: int,
    endpoint_style: str,
) -> str:
    if endpoint_style == "responses":
        endpoint = base_url.rstrip("/") + "/responses"
        payload_obj: dict[str, Any] = {
            "model": model,
            "input": messages,
            "temperature": 0,
        }
    else:
        endpoint = base_url.rstrip("/") + "/chat/completions"
        payload_obj = {
            "model": model,
            "messages": messages,
            "temperature": 0,
        }

    payload = json.dumps(payload_obj).encode("utf-8")

    headers = {
        "Content-Type": "application/json",
    }
    if api_key:
        headers["Authorization"] = f"Bearer {api_key}"

    request = urllib.request.Request(endpoint, data=payload, headers=headers, method="POST")
    try:
        with urllib.request.urlopen(request, timeout=timeout) as response:
            data = json.loads(response.read().decode("utf-8"))
    except urllib.error.HTTPError as exc:
        body = exc.read().decode("utf-8", errors="replace")
        raise RuntimeError(f"http_error:{exc.code}:{body}") from exc
    except urllib.error.URLError as exc:
        raise RuntimeError(f"network_error:{exc.reason}") from exc

    if endpoint_style == "responses":
        output = data.get("output") or []
        for item in output:
            content = item.get("content") or []
            for block in content:
                text = block.get("text")
                if text and text.strip():
                    return text
        raise RuntimeError("empty_response:no_output_text")

    choices = data.get("choices") or []
    if not choices:
        raise RuntimeError("empty_response:no_choices")
    message = choices[0].get("message") or {}
    content = message.get("content") or ""
    if not content.strip():
        raise RuntimeError("empty_response:no_content")
    return content


def classify_error(error: str) -> tuple[str, str]:
    lowered = error.lower()
    if "http_error:400" in lowered:
        return "validation_failed", error
    if "http_error:401" in lowered or "http_error:403" in lowered:
        return "auth_error", error
    if "http_error:413" in lowered or "token" in lowered or "context" in lowered:
        return "token_limit", error
    if "empty_response" in lowered:
        return "empty_response", error
    if "network_error" in lowered or "timeout" in lowered:
        return "network_error", error
    if "http_error:5" in lowered:
        return "server_error", error
    return "syntax_error", error


def convert_file(
    file_path: Path,
    input_root: Path,
    output_root: Path,
    failed_root: Path,
    system_prompt: str,
    user_template: str,
    base_url: str,
    api_key: str,
    model: str,
    timeout: int,
    retries: int,
    endpoint_style: str,
    log_file: Path,
    previous_status: str = "",
    previous_error_type: str = "",
    previous_error_message: str = "",
    cleanup_failed: bool = False,
) -> dict[str, Any]:
    sql_content = load_text(file_path)
    rel_path = file_path.relative_to(input_root)
    output_path = output_root / rel_path
    failed_path = failed_root / rel_path

    last_error_type = ""
    last_error_message = ""
    first_previous_status = previous_status
    first_previous_error_type = previous_error_type
    first_previous_error_message = previous_error_message

    for attempt in range(1, retries + 2):
        prev_status = previous_status if attempt == 1 and previous_status else ("failed" if attempt > 1 else "")
        prev_error_type = previous_error_type if attempt == 1 and previous_error_type else last_error_type
        prev_error_message = previous_error_message if attempt == 1 and previous_error_message else last_error_message
        user_prompt = render_loop_prompt(
            user_template,
            file_path=str(rel_path),
            sql_content=sql_content,
            prev_status=prev_status,
            error_type=prev_error_type,
            error_message=prev_error_message,
        )

        try:
            raw = call_openai_compatible(
                base_url=base_url,
                api_key=api_key,
                model=model,
                messages=build_messages(system_prompt, user_prompt),
                timeout=timeout,
                endpoint_style=endpoint_style,
            )
            converted = strip_code_fences(raw)
            if not converted:
                raise RuntimeError("empty_response:blank_after_strip")

            save_text(output_path, converted.rstrip() + "\n")
            result = {
                "file": str(rel_path),
                "status": "success",
                "attempt": attempt,
                "source_db": SOURCE_DB.lower(),
                "target_db": TARGET_DB.lower(),
                "stage": "save",
                "output_file": str(output_path),
                "timestamp": time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime()),
                "cleaned_failed_artifacts": False,
                "previous_status": first_previous_status,
                "previous_error_type": first_previous_error_type,
                "previous_error_message": first_previous_error_message,
            }
            if cleanup_failed and input_root == failed_root:
                delete_if_exists(file_path)
                delete_if_exists(Path(str(file_path) + ".json"))
                result["cleaned_failed_artifacts"] = True
            append_jsonl(log_file, result)
            return result
        except Exception as exc:  # noqa: BLE001
            error_type, message = classify_error(str(exc))
            last_error_type = error_type
            last_error_message = message
            failure_event = {
                "file": str(rel_path),
                "status": "retry_failed",
                "attempt": attempt,
                "error_type": error_type,
                "message": message,
                "source_db": SOURCE_DB.lower(),
                "target_db": TARGET_DB.lower(),
                "stage": "llm_convert",
                "timestamp": time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime()),
                "previous_status": first_previous_status,
                "previous_error_type": first_previous_error_type,
                "previous_error_message": first_previous_error_message,
            }
            append_jsonl(log_file, failure_event)
            eprint(f"[FAILED] file={rel_path} attempt={attempt} error_type={error_type} message={message}")

    save_text(failed_path, sql_content)
    log_payload = {
        "file": str(rel_path),
        "status": "failed",
        "attempt": retries + 1,
        "error_type": last_error_type,
        "message": last_error_message,
        "source_db": SOURCE_DB.lower(),
        "target_db": TARGET_DB.lower(),
        "stage": "llm_convert",
        "timestamp": time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime()),
        "failed_file": str(failed_path),
        "previous_status": first_previous_status,
        "previous_error_type": first_previous_error_type,
        "previous_error_message": first_previous_error_message,
    }
    save_json(failed_root / (rel_path.as_posix() + ".json"), log_payload)
    return log_payload


def main() -> int:
    parser = argparse.ArgumentParser(description="Convert DB2 SQL files to Snowflake SQL one file at a time.")
    parser.add_argument("input_dir", help="Directory containing source .sql files")
    parser.add_argument("--output-dir", default="output", help="Directory for converted SQL files")
    parser.add_argument("--failed-dir", default="failed", help="Directory for failed files and logs")
    parser.add_argument("--prompt-md", default="db2_to_snowflake_prompt.md", help="Prompt markdown file")
    parser.add_argument("--base-url", default=os.environ.get("LLM_BASE_URL", "http://localhost:8000/v1"), help="OpenAI-compatible base URL")
    parser.add_argument("--api-key", default=os.environ.get("LLM_API_KEY", os.environ.get("OPENAI_API_KEY", "")), help="API key")
    parser.add_argument("--model", default=os.environ.get("LLM_MODEL", DEFAULT_MODEL), help="Model name")
    parser.add_argument("--timeout", type=int, default=DEFAULT_TIMEOUT, help="Request timeout in seconds")
    parser.add_argument("--retries", type=int, default=1, help="Retry count after the first attempt")
    parser.add_argument("--endpoint-style", choices=("chat_completions", "responses"), default="chat_completions", help="LLM endpoint payload style")
    parser.add_argument("--log-file", default=DEFAULT_LOG_FILE, help="JSONL log file path")
    parser.add_argument("--retry-failed", action="store_true", help="Retry files already stored under the failed directory")
    parser.add_argument("--cleanup-failed", action="store_true", help="Delete failed SQL and JSON metadata after successful retry")
    parser.add_argument("--dry-run", action="store_true", help="Print files that would be converted")
    args = parser.parse_args()

    input_root = Path(args.input_dir).resolve()
    output_root = Path(args.output_dir).resolve()
    failed_root = Path(args.failed_dir).resolve()
    prompt_md = Path(args.prompt_md).resolve()
    log_file = Path(args.log_file).resolve()

    if not input_root.is_dir():
        eprint(f"Input directory does not exist: {input_root}")
        return 2
    if not prompt_md.is_file():
        eprint(f"Prompt file does not exist: {prompt_md}")
        return 2

    md_text = load_text(prompt_md)
    section = extract_section(md_text, "파일 1개씩 루프 처리 버전")
    prompt_block = extract_fenced_block(section)
    system_prompt = extract_system_prompt(prompt_block)
    user_template = extract_user_template(prompt_block)

    source_root = failed_root if args.retry_failed else input_root
    sql_files = sorted(source_root.rglob("*.sql"))
    if not sql_files:
        print("No .sql files found.")
        return 0

    summary: list[dict[str, Any]] = []
    for file_path in sql_files:
        if args.dry_run:
            print(file_path.relative_to(source_root))
            continue
        previous_status = ""
        previous_error_type = ""
        previous_error_message = ""
        if args.retry_failed:
            previous_status, previous_error_type, previous_error_message = load_failed_context(file_path)
        result = convert_file(
            file_path=file_path,
            input_root=source_root,
            output_root=output_root,
            failed_root=failed_root,
            system_prompt=system_prompt,
            user_template=user_template,
            base_url=args.base_url,
            api_key=args.api_key,
            model=args.model,
            timeout=args.timeout,
            retries=args.retries,
            endpoint_style=args.endpoint_style,
            log_file=log_file,
            previous_status=previous_status,
            previous_error_type=previous_error_type,
            previous_error_message=previous_error_message,
            cleanup_failed=args.cleanup_failed,
        )
        summary.append(result)

    if args.dry_run:
        return 0

    success = sum(1 for item in summary if item.get("status") == "success")
    failed = sum(1 for item in summary if item.get("status") == "failed")
    cleaned = sum(1 for item in summary if item.get("cleaned_failed_artifacts"))
    started_at = time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime())
    report = {
        "total": len(summary),
        "success": success,
        "failed": failed,
        "source_db": SOURCE_DB.lower(),
        "target_db": TARGET_DB.lower(),
        "started_at": started_at,
        "finished_at": time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime()),
        "retry_failed": args.retry_failed,
        "cleanup_failed": args.cleanup_failed,
        "cleaned_failed_artifacts": cleaned,
        "files": summary,
    }
    save_json(output_root / "conversion_summary.json", report)
    if args.retry_failed:
        save_json(failed_root / "retry_summary.json", report)
    print(json.dumps(report, ensure_ascii=False, indent=2))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
