# make-icon.py: needs icon256.png extracted from GraveyardKeeper2.exe
# (icoextract GraveyardKeeper2.exe exe.ico && magick "exe.ico[8]" icon256.png) and Pillow
from PIL import Image, ImageDraw
src = Image.open("icon256.png").convert("RGBA")
im = src.copy(); px, sp = im.load(), src.load()
green = lambda p: p[3] > 0 and p[1] > p[0] + 25 and p[1] > p[2] + 25

# 1. wipe the skull (non-hand pixels in its bbox) to the portal's dark blue

# 2. Apple logo silhouette (logo.svg rendered at 8x), downsampled to pixels
import subprocess
X, Y, W, H, S = 25, 70, 58, 69, 8
subprocess.run(["rsvg-convert", "-w", str(W*S), "-h", str(H*S), "-o", "logo8x.png", "apple-logo.svg"], check=True)
body = Image.open("logo8x.png").getchannel("A").resize((W, H), Image.BOX).point(lambda v: 255 if v > 110 else 0)
lf = Image.new("L", (W, H))
B, L = body.load(), lf.load()
covered = lambda x, y: 0 <= x-X < W and 0 <= y-Y < H and (B[x-X, y-Y] or L[x-X, y-Y])
near_green = lambda x, y: any(green(sp[x+a, y+b]) for a in (-1, 0, 1) for b in (-1, 0, 1))
skull = lambda p, x, y: p[3] > 0 and not green(p) and (p[0] - p[2] > 60 or p[0] - p[1] > 50 or (not near_green(x, y) and sum(p[:3]) < 120 and 35 < x < 82 and 98 < y < 130))
# erase skull pixels the apple doesn't cover: smear background in from the right
for y in range(84, 140):
    for x in range(88, 20, -1):
        bite = x >= 70 and 91 <= y <= 124   # anything left in the bite hole goes
        if not covered(x, y) and (skull(sp[x, y], x, y) or (bite and not near_green(x, y))): px[x, y] = px[x+1, y]

OUT = (26, 18, 24, 255)
# classic six-stripe logo; leaf (top quarter) is the green stripe
STRIPES = [(97, 187, 70), (253, 184, 39), (245, 130, 31), (224, 58, 62), (150, 61, 151), (0, 157, 220)]
top = int(H * 0.27)
inside = lambda i, j: 0 <= i < W and 0 <= j < H and B[i, j]
for i in range(W):
    for j in range(H):
        x, y = X+i, Y+j
        if B[i, j]:
            k = 0 if j < top else min(5, (j - top) * 6 // (H - top))
            c = STRIPES[k]
            if not inside(i+1, j) or not inside(i, j+1):          # 1px darker rim bottom/right
                c = tuple(int(v * .75) for v in c)
            px[x, y] = c + (255,)
        elif any(inside(i+a, j+b) for a in (-1, 0, 1) for b in (-1, 0, 1)):
            px[x, y] = OUT

# 3. the zombie's fingers (and their outlines) back in front
for x in range(1, 60):
    for y in range(100, 145):
        p = sp[x, y]
        near = any(green(sp[x+a, y+b]) for a in (-1, 0, 1) for b in (-1, 0, 1))
        if green(p) or (p[3] > 0 and sum(p[:3]) < 200 and near): px[x, y] = p
im.save("gk2mac256.png")
im.resize((1024, 1024), Image.NEAREST).save("gk2mac1024.png")
