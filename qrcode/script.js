document.getElementById('generateQRCode').addEventListener('click', () => {
  const restaurantUrl = 'http://your_frontend_ip/menu_screen';
  const qrcodeElement = document.getElementById('qrcode');
  QRCode.toCanvas(qrcodeElement, restaurantUrl, { width: 300, height: 300 }, (error) => {
    if (error) console.error(error);
  });
});