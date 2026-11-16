import json
import pathlib
import subprocess
import sys


def configuration_arguments(arguments: list[str]) -> list[str]:
    options = ("-c", "--config", "-p", "--profile", "-C", "--cd", "--enable", "--disable")
    result = []
    iterator = iter(arguments)
    for argument in iterator:
        if argument == "--":
            break
        if argument in options:
            result.extend((argument, next(iterator)))
        elif any(argument.startswith(option + "=") for option in options):
            result.append(argument)
        elif any(argument.startswith(option) for option in ("-c", "-p", "-C")):
            result.append(argument)
    return result


def developer_instructions(arguments: list[str]) -> str:
    result = subprocess.run(
        ["codex", *configuration_arguments(arguments), "debug", "prompt-input"],
        capture_output=True,
        text=True,
        check=True,
        timeout=30,
    )
    instructions = []
    for item in json.loads(result.stdout):
        if item.get("role") != "developer":
            continue
        metadata = item.get("internal_chat_message_metadata_passthrough", {})
        kinds = metadata.get("content_item_kinds", [])
        contents = item.get("content", [])
        provenance = metadata.get("content_item_metadata", [])
        if len(kinds) != len(contents) or len(provenance) != len(contents):
            raise ValueError("Codex prompt inspection lacks instruction provenance")
        for kind, content, origin in zip(kinds, contents, provenance):
            if (
                kind == "generic.developer_instructions"
                and not origin.get("provenance", {}).get("from_additional_requirements")
            ):
                instructions.append(content["text"])
    return "\n\n".join(instructions)


def main() -> None:
    container_instructions = pathlib.Path(sys.argv[1]).read_text()
    existing = developer_instructions(sys.argv[2:])
    combined = "\n\n".join(text for text in (existing, container_instructions) if text)
    print("developer_instructions=" + json.dumps(combined, ensure_ascii=False))


if __name__ == "__main__":
    try:
        main()
    except (OSError, ValueError, StopIteration, subprocess.SubprocessError):
        print(
            "Container instructions not loaded: Codex configuration inspection failed. "
            "Check codex debug prompt-input.",
            file=sys.stderr,
        )
        sys.exit(1)
