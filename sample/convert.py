from PIL import Image, ImageDraw,ImageFont
font = ImageFont.truetype("OpenSans-Semibold.ttf", size=30)
template = Image.open("UWL_CARD_TEMPLATE.png")
pic = Image.open(f"messi.jpeg").resize((150, 190), Image.ADAPTIVE)
template.paste(pic, (500, 110, 650, 300))
draw = ImageDraw.Draw(template)
draw.text((80, 220), "LEO MESSI",font=font, fill='grey')
draw.text((80, 265), "32344540", font=font,fill='grey')
draw.text((80, 310), "FULL TIME", font=font,fill='grey')

template.save("messi_card.png")

