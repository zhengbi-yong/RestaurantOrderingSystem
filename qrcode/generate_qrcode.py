import qrcode
import io
from PIL import ImageDraw, ImageFont

def generate_qr(url, text):
    qr = qrcode.QRCode(
        version=1,
        error_correction=qrcode.constants.ERROR_CORRECT_H,
        box_size=10,
        border=4,
    )
    qr.add_data(url)
    qr.make(fit=True)

    img_qr = qr.make_image(fill_color="black", back_color="white").convert('RGB')
    
    # Define the font properties
    font = ImageFont.truetype("arial.ttf", 15)  # Load from ttf file
    draw = ImageDraw.Draw(img_qr)
    textwidth, textheight = draw.textsize(text, font=font)  # Correct way to get text size
    
    # Calculate the x, y coordinates of the text
    width, height = img_qr.size 
    x = (width - textwidth) / 2
    y = (height - textheight) / 2

    # Draw the text on the image
    draw.text((x, y), text, font=font, fill="black")

    # Convert PIL Image to Bytes
    byte_arr = io.BytesIO()
    img_qr.save(byte_arr, format='PNG')
    return byte_arr.getvalue()

item = '内'
num = 5
text = f'{item}{num}'

# Example usage
for i in range(1,num+1):
    url = f'http://8.134.163.125/#/auto_login?username={item}{i}&password=1'
    qr_code = generate_qr(url, text)

    # Save to file
    with open(f'./result/qr_code{item}{i}.png', 'wb') as f:
        f.write(qr_code)
