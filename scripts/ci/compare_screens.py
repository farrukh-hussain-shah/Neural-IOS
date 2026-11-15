#!/usr/bin/env python3
"""Compares simulator screenshots with the design references rendered from the SVG files.

For every screen it writes a side-by-side image (design | simulator | mismatch heatmap)
and a mismatch score, then renders a Markdown report (README.md) for the output folder.
"""
import argparse
import json
import os
import shutil
from pathlib import Path

from PIL import Image, ImageChops, ImageDraw, ImageFont

SCREENS = [
    ("01-splash", "Splash", "768w light-3.svg"),
    ("02-onboarding-welcome", "Onboarding 1 – Welcome", "390w light.svg"),
    ("03-onboarding-add-keyboard", "Onboarding 2 – Setup 1 of 3", "768w light-1.svg"),
    ("04-onboarding-full-access", "Onboarding 3 – Setup 2 of 3", "768w light-2.svg"),
    ("05-home", "Home", "Home.svg"),
]

POINT_SCALE = 3
STATUS_BAR_POINTS = 47
HOME_INDICATOR_POINTS = 34
PIXEL_THRESHOLD = 32
PANEL_SCALE = 0.5
LABEL_HEIGHT = 72
GUTTER = 24
BACKGROUND = (17, 17, 20)
MISMATCH_COLOR = (255, 48, 48)


def load_font(size):
    try:
        return ImageFont.load_default(size=size)
    except TypeError:
        return ImageFont.load_default()


def mismatch_mask(design, actual):
    difference = ImageChops.difference(design, actual)
    red, green, blue = difference.split()
    magnitude = ImageChops.lighter(ImageChops.lighter(red, green), blue)
    return magnitude.point(lambda value: 255 if value > PIXEL_THRESHOLD else 0)


def mismatch_percentage(mask):
    width, height = mask.size
    top = STATUS_BAR_POINTS * POINT_SCALE
    bottom = height - HOME_INDICATOR_POINTS * POINT_SCALE
    region = mask.crop((0, top, width, bottom))
    mismatched = region.histogram()[255]
    return 100.0 * mismatched / (region.width * region.height)


def heatmap(actual, mask):
    dimmed = actual.convert("L").point(lambda value: int(value * 0.35)).convert("RGB")
    highlight = Image.new("RGB", actual.size, MISMATCH_COLOR)
    return Image.composite(highlight, dimmed, mask)


def side_by_side(panels, title):
    scaled = [
        (label, image.resize((int(image.width * PANEL_SCALE), int(image.height * PANEL_SCALE)), Image.LANCZOS))
        for label, image in panels
    ]
    panel_width, panel_height = scaled[0][1].size
    width = len(scaled) * panel_width + (len(scaled) + 1) * GUTTER
    height = panel_height + LABEL_HEIGHT * 2 + GUTTER
    canvas = Image.new("RGB", (width, height), BACKGROUND)
    draw = ImageDraw.Draw(canvas)
    draw.text((GUTTER, 18), title, fill=(255, 255, 255), font=load_font(34))
    label_font = load_font(28)
    for index, (label, image) in enumerate(scaled):
        x = GUTTER + index * (panel_width + GUTTER)
        draw.text((x, LABEL_HEIGHT + 14), label, fill=(200, 205, 215), font=label_font)
        canvas.paste(image, (x, LABEL_HEIGHT * 2))
    return canvas


def compare_screen(key, title, design_dir, actual_dir, output_dir):
    design_path = design_dir / f"{key}.png"
    actual_path = actual_dir / f"{key}.png"
    result = {"key": key, "title": title, "status": "missing", "mismatch": None, "note": ""}
    if not design_path.exists():
        result["note"] = "design reference missing"
        return result
    if not actual_path.exists():
        result["note"] = "simulator screenshot missing"
        return result

    design = Image.open(design_path).convert("RGB")
    actual = Image.open(actual_path).convert("RGB")
    if actual.size != design.size:
        result["note"] = f"simulator {actual.width}x{actual.height} resized to {design.width}x{design.height}"
        actual = actual.resize(design.size, Image.LANCZOS)

    mask = mismatch_mask(design, actual)
    result["mismatch"] = round(mismatch_percentage(mask), 2)
    result["status"] = "compared"

    side_by_side(
        [("Design (SVG)", design), ("Simulator", actual), ("Mismatch (red)", heatmap(actual, mask))],
        f"{title} — {result['mismatch']:.2f}% pixels differ",
    ).save(output_dir / "comparison" / f"{key}.png", optimize=True)
    shutil.copyfile(design_path, output_dir / "design" / f"{key}.png")
    return result


def write_report(results, output_dir):
    device_file = output_dir / "logs" / "device.txt"
    device = device_file.read_text().strip() if device_file.exists() else "unknown"
    commit = os.environ.get("GITHUB_SHA", "local")[:7]
    run_url = ""
    if os.environ.get("GITHUB_RUN_ID"):
        run_url = (
            f"{os.environ.get('GITHUB_SERVER_URL', 'https://github.com')}/"
            f"{os.environ.get('GITHUB_REPOSITORY', '')}/actions/runs/{os.environ['GITHUB_RUN_ID']}"
        )

    lines = [
        "# NeuralKey — Simulator vs Design",
        "",
        f"- Commit: `{commit}`",
        f"- Simulator: {device}",
    ]
    if run_url:
        lines.append(f"- Workflow run: {run_url}")
    lines += [
        "- Video of the full flow: [video/simulator-flow.mp4](video/simulator-flow.mp4)",
        f"- Mismatch = share of pixels whose colour differs by more than {PIXEL_THRESHOLD}/255, "
        f"excluding the status bar ({STATUS_BAR_POINTS} pt) and home indicator ({HOME_INDICATOR_POINTS} pt).",
        "- `Home.svg` has no status bar, so its reference is placed below the status bar.",
        "",
        "| Screen | Design file | Mismatch | Note |",
        "| --- | --- | --- | --- |",
    ]
    sources = {key: source for key, _, source in SCREENS}
    for result in results:
        mismatch = f"{result['mismatch']:.2f}%" if result["mismatch"] is not None else "—"
        lines.append(f"| {result['title']} | `{sources[result['key']]}` | {mismatch} | {result['note']} |")
    lines.append("")
    for result in results:
        if result["status"] != "compared":
            continue
        lines += [
            f"## {result['title']}",
            "",
            f"![{result['title']}](comparison/{result['key']}.png)",
            "",
            f"Full size: [design](design/{result['key']}.png) · [simulator](screenshots/{result['key']}.png)",
            "",
        ]
    report = "\n".join(lines)
    (output_dir / "README.md").write_text(report)
    (output_dir / "comparison" / "summary.json").write_text(json.dumps(results, indent=2))
    return report


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--design", type=Path, required=True)
    parser.add_argument("--output", type=Path, required=True)
    args = parser.parse_args()

    actual_dir = args.output / "screenshots"
    for folder in ("comparison", "design"):
        (args.output / folder).mkdir(parents=True, exist_ok=True)

    results = [compare_screen(key, title, args.design, actual_dir, args.output) for key, title, _ in SCREENS]
    print(write_report(results, args.output))


if __name__ == "__main__":
    main()
