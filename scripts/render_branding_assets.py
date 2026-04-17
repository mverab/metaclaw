from PIL import Image, ImageDraw, ImageFont


def font(size: int, bold: bool = False):
    candidates = [
        "/System/Library/Fonts/Supplemental/Arial Bold.ttf" if bold else "/System/Library/Fonts/Supplemental/Arial.ttf",
        "/System/Library/Fonts/Supplemental/Helvetica.ttc",
    ]
    for path in candidates:
        try:
            return ImageFont.truetype(path, size)
        except Exception:
            continue
    return ImageFont.load_default()


def draw_logo(path: str):
    w, h = 1024, 1024
    img = Image.new("RGB", (w, h), "#F3F4F6")
    d = ImageDraw.Draw(img)

    c = "#121820"
    # emblem center
    cx = w // 2
    top = 235
    band_h = 58
    gap = 22
    half = 210

    for i in range(3):
        y = top + i * (band_h + gap)
        pts = [
            (cx - half, y),
            (cx, y + 95),
            (cx + half, y),
            (cx + half, y + band_h),
            (cx, y + 150),
            (cx - half, y + band_h),
        ]
        d.polygon(pts, fill=c)

    # small bridge notch on right
    d.polygon([(cx + 58, 420), (cx + 170, 420), (cx + 170, 500), (cx + 58, 500)], fill="#F3F4F6")
    d.polygon([(cx + 95, 445), (cx + 240, 365), (cx + 240, 430), (cx + 95, 510)], fill=c)

    text = "METACLAW"
    f = font(96, bold=True)
    tw, th = d.textbbox((0, 0), text, font=f)[2:]
    d.text(((w - tw) // 2, 735), text, fill=c, font=f)

    img.save(path, "PNG")


def draw_banner(path: str):
    w, h = 1600, 480
    bg = Image.new("RGB", (w, h), "#04070C")
    d = ImageDraw.Draw(bg)

    # subtle grid lines
    for x in range(0, w, 140):
        d.line([(x, 0), (x, h)], fill="#0D1622", width=1)
    for y in range(0, h, 80):
        d.line([(0, y), (w, y)], fill="#0A121D", width=1)

    # layered right-side geometry
    stroke = "#A9B5C6"
    layers = [
        [(980, 250), (1260, 110), (1540, 250), (1260, 390)],
        [(1030, 270), (1260, 155), (1490, 270), (1260, 385)],
        [(1080, 290), (1260, 205), (1440, 290), (1260, 375)],
    ]
    for poly in layers:
        d.polygon(poly, outline=stroke, width=3)

    # text block left
    f1 = font(88, bold=True)
    f2 = font(76, bold=False)
    d.text((95, 120), "MetaClaw", fill="#F2F5F8", font=f1)
    d.text((95, 238), "Setup Architect", fill="#F2F5F8", font=f2)

    bg.save(path, "PNG")


def draw_social(path: str):
    # exact OG ratio
    w, h = 1200, 630
    img = Image.new("RGB", (w, h), "#04070C")
    d = ImageDraw.Draw(img)

    # left mesh lines
    mesh = "#D9DEE5"
    d.line([(0, 30), (140, 255), (0, 520)], fill=mesh, width=3)
    d.line([(70, 0), (140, 255), (270, 40)], fill=mesh, width=3)
    d.line([(0, 200), (270, 200)], fill=mesh, width=3)
    d.line([(0, 420), (120, 255), (270, 390)], fill=mesh, width=3)

    # right geometry with safe area margin
    # keep right-most shape outside key text area and not too dominant
    d.polygon([(940, 90), (1200, 255), (940, 420), (1000, 255)], fill="#E8EAED")
    d.polygon([(945, 500), (1140, 500), (1200, 560), (995, 560)], fill="#E8EAED")

    # wire lines for structure
    d.line([(860, 100), (1140, 300), (860, 520)], fill=mesh, width=2)
    d.line([(1010, 70), (1010, 560)], fill=mesh, width=2)

    # text centered-left
    f1 = font(104, bold=True)
    f2 = font(86, bold=False)
    d.text((255, 220), "MetaClaw", fill="#F4F6F8", font=f1)
    d.text((300, 345), "Setup Architect", fill="#F4F6F8", font=f2)

    img.save(path, "PNG")


def main():
    draw_logo("assets/branding/logo.png")
    draw_banner("assets/branding/banner.png")
    draw_social("assets/branding/social-preview.png")


if __name__ == "__main__":
    main()
