#!/usr/bin/env python3
from __future__ import annotations

import argparse
import html
import re
import sys
import unicodedata
from pathlib import Path


PREPARE_TAG_PATTERN = re.compile(
    r"^prepare-(?P<version_name>\d+\.\d+\.\d+)\+(?P<version_code>[1-9]\d*)$"
)
RELEASE_TAG_PATTERN = re.compile(
    r"^(?P<version_name>\d+\.\d+\.\d+)\+(?P<version_code>[1-9]\d*)$"
)
CHANGELOG_HEADING_PATTERN = "^##\\s+(?:\\[{version}\\]|{version})(?:\\s+-.*)?\\s*$"
LOCALES = ("en-US", "fr-FR", "es-ES", "de-DE")
MAX_CHANGELOG_BYTES = 500


class ReleaseMetadataError(Exception):
    pass


def parse_prepare_tag(tag: str) -> tuple[str, str]:
    match = PREPARE_TAG_PATTERN.fullmatch(tag)
    if match is None:
        raise ReleaseMetadataError(
            f"Invalid prepare tag '{tag}'. Expected format prepare-x.y.z+n."
        )
    return match.group("version_name"), match.group("version_code")


def parse_release_tag(tag: str) -> tuple[str, str]:
    match = RELEASE_TAG_PATTERN.fullmatch(tag)
    if match is None:
        raise ReleaseMetadataError(
            f"Invalid release tag '{tag}'. Expected format x.y.z+n."
        )
    return match.group("version_name"), match.group("version_code")


def update_pubspec_version(pubspec_path: Path, version_name: str, version_code: str) -> None:
    text = pubspec_path.read_text(encoding="utf-8")
    version_line = f"version: {version_name}+{version_code}"
    updated_text, replacements = re.subn(
        r"(?m)^version:\s*.+$",
        version_line,
        text,
        count=1,
    )
    if replacements != 1:
        raise ReleaseMetadataError(
            f"Could not find a unique version line in {pubspec_path.as_posix()}."
        )
    pubspec_path.write_text(updated_text, encoding="utf-8")


def extract_changelog_section(changelog_path: Path, version_name: str) -> str:
    heading_pattern = re.compile(
        CHANGELOG_HEADING_PATTERN.format(version=re.escape(version_name))
    )
    section_lines: list[str] = []
    in_target_section = False

    for raw_line in changelog_path.read_text(encoding="utf-8").splitlines():
        line = raw_line.rstrip()
        if heading_pattern.match(line):
            in_target_section = True
            continue
        if in_target_section and line.startswith("## "):
            break
        if in_target_section:
            section_lines.append(line)

    section = "\n".join(section_lines).strip()
    if not section:
        raise ReleaseMetadataError(
            f"Could not find a non-empty CHANGELOG.md section for version {version_name}."
        )
    return section


def markdown_line_to_text(line: str) -> str:
    stripped = line.strip()
    if not stripped:
        return ""

    if re.match(r"^#{3,6}\s+", stripped):
        stripped = re.sub(r"^#{3,6}\s+", "", stripped).strip()
        prefix = ""
        suffix = ":"
    elif re.match(r"^[-*+]\s+", stripped):
        stripped = re.sub(r"^[-*+]\s+", "", stripped).strip()
        prefix = "- "
        suffix = ""
    elif re.match(r"^\d+\.\s+", stripped):
        stripped = re.sub(r"^\d+\.\s+", "", stripped).strip()
        prefix = "- "
        suffix = ""
    else:
        prefix = ""
        suffix = ""

    stripped = re.sub(r"!\[([^\]]*)\]\([^)]+\)", r"\1", stripped)
    stripped = re.sub(r"\[([^\]]+)\]\([^)]+\)", r"\1", stripped)
    stripped = stripped.replace("`", "")
    stripped = re.sub(r"[*_~]", "", stripped)
    stripped = re.sub(r"<[^>]+>", "", stripped)
    stripped = html.unescape(stripped)
    stripped = unicodedata.normalize("NFKD", stripped).encode("ascii", "ignore").decode(
        "ascii"
    )
    stripped = re.sub(r"\s+", " ", stripped).strip()

    if not stripped:
        return ""
    return f"{prefix}{stripped}{suffix}".strip()


def trim_ascii_text(text: str, max_bytes: int) -> str:
    encoded = text.encode("ascii")
    if len(encoded) <= max_bytes:
        return text

    cutoff = max_bytes - 3
    truncated = encoded[:cutoff].decode("ascii", errors="ignore").rstrip()
    last_break = max(truncated.rfind("\n"), truncated.rfind(" "))
    if last_break >= max(40, cutoff - 120):
        truncated = truncated[:last_break].rstrip()
    truncated = truncated.rstrip(" -,:;\n")
    return f"{truncated}..."


def render_plaintext_changelog(section: str) -> str:
    rendered_lines = [markdown_line_to_text(line) for line in section.splitlines()]
    text = "\n".join(line for line in rendered_lines if line).strip()
    if not text:
        raise ReleaseMetadataError("Generated changelog text is empty after Markdown cleanup.")

    text = trim_ascii_text(text, MAX_CHANGELOG_BYTES)
    if not text.strip():
        raise ReleaseMetadataError("Generated changelog text is empty after trimming.")
    if len(text.encode("ascii")) > MAX_CHANGELOG_BYTES:
        raise ReleaseMetadataError("Generated changelog text exceeds 500 bytes.")
    return text


def write_changelog_files(metadata_root: Path, version_code: str, changelog_text: str) -> Path:
    primary_path: Path | None = None
    for locale in LOCALES:
        output_path = metadata_root / locale / "changelogs" / f"{version_code}.txt"
        output_path.parent.mkdir(parents=True, exist_ok=True)
        output_path.write_text(changelog_text, encoding="ascii")
        if primary_path is None:
            primary_path = output_path
    assert primary_path is not None
    return primary_path


def append_github_outputs(output_path: Path, outputs: dict[str, str]) -> None:
    with output_path.open("a", encoding="utf-8") as handle:
        for key, value in outputs.items():
            handle.write(f"{key}={value}\n")


def prepare_release(args: argparse.Namespace) -> int:
    version_name, version_code = parse_prepare_tag(args.tag)
    release_tag = f"{version_name}+{version_code}"

    update_pubspec_version(args.pubspec, version_name, version_code)
    section = extract_changelog_section(args.changelog, version_name)
    changelog_text = render_plaintext_changelog(section)
    primary_changelog = write_changelog_files(
        args.metadata_root,
        version_code,
        changelog_text,
    )

    if args.github_output is not None:
        append_github_outputs(
            args.github_output,
            {
                "version_name": version_name,
                "version_code": version_code,
                "release_tag": release_tag,
                "changelog_file": primary_changelog.as_posix(),
            },
        )
    return 0


def parse_release(args: argparse.Namespace) -> int:
    version_name, version_code = parse_release_tag(args.tag)
    changelog_file = args.metadata_root / "en-US" / "changelogs" / f"{version_code}.txt"

    if args.require_changelog:
        if not changelog_file.is_file():
            raise ReleaseMetadataError(
                f"Release notes file {changelog_file.as_posix()} does not exist."
            )
        changelog_text = changelog_file.read_text(encoding="ascii").strip()
        if not changelog_text:
            raise ReleaseMetadataError(
                f"Release notes file {changelog_file.as_posix()} is empty."
            )
        if len(changelog_text.encode("ascii")) > MAX_CHANGELOG_BYTES:
            raise ReleaseMetadataError(
                f"Release notes file {changelog_file.as_posix()} exceeds 500 bytes."
            )

    if args.github_output is not None:
        append_github_outputs(
            args.github_output,
            {
                "version_name": version_name,
                "version_code": version_code,
                "release_tag": args.tag,
                "changelog_file": changelog_file.as_posix(),
            },
        )
    return 0


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description="Release metadata helpers for GitHub Actions.")
    subparsers = parser.add_subparsers(dest="command", required=True)

    prepare_parser = subparsers.add_parser(
        "prepare",
        help="Update pubspec.yaml and Fastlane metadata from a prepare tag.",
    )
    prepare_parser.add_argument("--tag", required=True)
    prepare_parser.add_argument("--pubspec", type=Path, required=True)
    prepare_parser.add_argument("--changelog", type=Path, required=True)
    prepare_parser.add_argument("--metadata-root", type=Path, required=True)
    prepare_parser.add_argument("--github-output", type=Path)
    prepare_parser.set_defaults(func=prepare_release)

    parse_parser = subparsers.add_parser(
        "parse-release-tag",
        help="Validate a release tag and expose metadata for workflows.",
    )
    parse_parser.add_argument("--tag", required=True)
    parse_parser.add_argument("--metadata-root", type=Path, required=True)
    parse_parser.add_argument("--github-output", type=Path)
    parse_parser.add_argument("--require-changelog", action="store_true")
    parse_parser.set_defaults(func=parse_release)

    return parser


def main() -> int:
    parser = build_parser()
    args = parser.parse_args()
    try:
        return args.func(args)
    except ReleaseMetadataError as exc:
        print(f"Error: {exc}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    sys.exit(main())
