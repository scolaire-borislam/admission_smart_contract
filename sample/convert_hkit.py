from PIL import Image, ImageDraw,ImageFont
font = ImageFont.truetype("OpenSans-Semibold.ttf", size=30)
template = Image.open("HKIT_CARD_TEMPLATE.jpeg")
pic = Image.open(f"ronaldo.jpeg").resize((145, 185), Image.ADAPTIVE)
template.paste(pic, (500, 160, 645, 345))
draw = ImageDraw.Draw(template)
draw.text((80, 220), "PETER RONALDO",font=font, fill='grey')
draw.text((80, 265), "232344540", font=font,fill='grey')
draw.text((80, 310), "FULL TIME", font=font,fill='grey')


template.save("ronaldo_converted.png")

