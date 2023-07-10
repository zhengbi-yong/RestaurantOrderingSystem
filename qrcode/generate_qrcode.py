import qrcode
from PIL import Image
import io

def generate_qr(url):
    qr = qrcode.QRCode(
        version=1,
        error_correction=qrcode.constants.ERROR_CORRECT_H,
        box_size=10,
        border=4,
    )
    qr.add_data(url)
    qr.make(fit=True)

    img = qr.make_image(fill_color="black", back_color="white")
    
    # Convert PIL Image to Bytes
    byte_arr = io.BytesIO()
    img.save(byte_arr, format='PNG')
    return byte_arr.getvalue()

item = '内'
num = 6
# Example usage
for i in range(num):
    url = f'http://8.134.163.125/#/auto_login?username={item}{i}&password=1'
    qr_code = generate_qr(url)

    # Save to file
    with open(f'./result/qr_code{item}{i}.png', 'wb') as f:
        f.write(qr_code)
