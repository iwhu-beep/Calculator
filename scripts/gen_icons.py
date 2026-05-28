import math, os, sys
from PIL import Image, ImageDraw, ImageFont

OUT = sys.argv[1] if len(sys.argv) > 1 else 'Calculator/Assets.xcassets/AppIcon.appiconset'
os.makedirs(OUT, exist_ok=True)

def make_icon(size, path):
    img = Image.new('RGBA', (size, size), (0,0,0,0))
    d = ImageDraw.Draw(img)

    # background rounded rect
    r = size * 0.22
    d.rounded_rectangle([(0,0),(size-1,size-1)], radius=int(r), fill=(26,26,46,255))

    # gradient overlay
    for y in range(size):
        t = y / size
        c = (int(30+(60-30)*t), int(30+(53-30)*t), int(50+(83-50)*t), 255)
        d.line([(0,y),(size,y)], fill=c)

    # orange calculator body
    ox = int(size*0.18)
    oy = int(size*0.32)
    ow = int(size*0.64)
    oh = int(size*0.52)
    orad = int(size*0.10)
    d.rounded_rectangle([(ox,oy),(ox+ow,oy+oh)], radius=orad, fill=(255,149,0,255))

    # display area
    dx = ox + int(ow*0.10)
    dy = oy + int(oh*0.10)
    dw = ow - int(ow*0.20)
    dh = int(oh*0.20)
    drad = int(size*0.025)
    d.rounded_rectangle([(dx,dy),(dx+dw,dy+dh)], radius=drad, fill=(40,40,60,255))
    # display text
    try:
        ft = ImageFont.truetype('/System/Library/Fonts/Menlo.ttc', int(dh*0.55))
        d.text((dx+int(dw*0.92), dy+dh//2), '1+1', fill=(255,255,255,200), anchor='rm', font=ft)
    except:
        pass

    # grid buttons 3x3
    gap = int(ow*0.05)
    bx = ox + int(ow*0.08)
    by = dy + dh + int(oh*0.06)
    bw = int((ow - gap*2 - int(ow*0.16)) / 3)
    bh = int((oy+oh - by - gap*2) / 3)
    btn_r = int(bw*0.20)
    for row in range(3):
        for col in range(3):
            x = bx + col*(bw+gap)
            y = by + row*(bh+gap)
            fc = (255,255,255,100) if (row==2 and col==2) else (255,255,255,180)
            d.rounded_rectangle([(x,y),(x+bw,y+bh)], radius=btn_r, fill=fc)

    # remove alpha
    bg = Image.new('RGBA', (size,size), (26,30,50,255))
    bg.paste(img, (0,0), img)
    bg = bg.convert('RGB')
    bg.save(path, 'PNG')
    print(f'  {path}')

sizes = {
    'icon-40.png':40, 'icon-58.png':58, 'icon-60.png':60,
    'icon-80.png':80, 'icon-87.png':87, 'icon-120.png':120,
    'icon-180.png':180, 'icon-1024.png':1024,
}
for fn, sz in sizes.items():
    make_icon(sz, os.path.join(OUT, fn))
print('Done!')
