import qrcode
import io
import os

def generate_qr(url):
    qr = qrcode.QRCode(
        version=1,
        error_correction=qrcode.constants.ERROR_CORRECT_H,
        box_size=10,
        border=4,
    )
    qr.add_data(url)
    qr.make(fit=True)

    img_qr = qr.make_image(fill_color="black", back_color="white").convert('RGB')

    # Convert PIL Image to Bytes
    byte_arr = io.BytesIO()
    img_qr.save(byte_arr, format='PNG')
    return byte_arr.getvalue()


base_url = 'http://8.134.163.125/#/auto_login?username={}&password=1'

# Make sure the result directory exists
if not os.path.exists('./result'):
    os.makedirs('./result')

# Generate QR codes for usernames from 1 to 12
for i in range(1, 13):
    url = base_url.format(i)  # Create the URL with the current username
    qr_code = generate_qr(url)  # Generate the QR code

    # Save to file
    with open(f'./result/qr_code_{i}.png', 'wb') as f:
        f.write(qr_code)
