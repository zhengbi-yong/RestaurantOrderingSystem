#!/usr/bin/env python3
from flask import Flask, jsonify, request
from flask import session
from flask import make_response
from flask_cors import CORS
from models import MenuItem, Order, User
from flask_sqlalchemy import SQLAlchemy
from sqlalchemy import exc
import json
from werkzeug.security import generate_password_hash, check_password_hash
import os
import codecs
import logging
from datetime import datetime, date, timedelta
import time
from database import db
import sys
from flask_socketio import SocketIO, emit
import smtplib
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText
from email.header import Header
import smtplib
from reportlab.lib.pagesizes import letter
from reportlab.pdfgen import canvas
from email.mime.base import MIMEBase
from email import encoders
from reportlab.lib.pagesizes import letter
from reportlab.pdfgen import canvas
from reportlab.lib.units import inch
from reportlab.pdfbase import pdfmetrics
from reportlab.pdfbase.ttfonts import TTFont
from reportlab.platypus import SimpleDocTemplate, Paragraph, Spacer, Table
from reportlab.lib.styles import getSampleStyleSheet
from reportlab.lib import colors
from reportlab.platypus import TableStyle
from reportlab.platypus import SimpleDocTemplate, Paragraph, Table, TableStyle, Frame, PageTemplate
from reportlab.lib import colors
from reportlab.pdfbase import pdfmetrics
from reportlab.pdfbase.ttfonts import TTFont
from reportlab.lib.pagesizes import letter
from reportlab.lib.styles import getSampleStyleSheet
from reportlab.platypus import PageBreak
from reportlab.platypus import NextPageTemplate
from reportlab.platypus import FrameBreak
# 创建日志记录器
logger = logging.getLogger(__name__)
logger.setLevel(logging.DEBUG)

# 创建文件处理器
file_handler = logging.FileHandler("app.log")
file_handler.setLevel(logging.DEBUG)

# 创建日志记录格式
log_format = logging.Formatter(
    "[%(asctime)s] %(levelname)s: %(message)s", datefmt="%Y-%m-%d %H:%M:%S"
)
file_handler.setFormatter(log_format)

# 创建控制台处理器
console_handler = logging.StreamHandler(sys.stdout)
console_handler.setLevel(logging.DEBUG)
console_handler.setFormatter(log_format)

# 将处理器添加到日志记录器
logger.addHandler(file_handler)
# 将控制台处理器添加到日志记录器
logger.addHandler(console_handler)


def create_app():
    logger.info("开始创建后端程序")
    app = Flask(__name__)
    configure_db(app)
    logger.debug("数据库设置完成")

    logger.debug("跨域设置完成")
    db.init_app(app)
    app.config["SECRET_KEY"] = "your-secret-key"
    logger.info("后端程序创建完成")
    return app


def configure_db(app):
    logger.info("开始配置数据库")
    app.config["SQLALCHEMY_DATABASE_URI"] = f"mysql://root:sisyphus@db:3306/restaurant"
    app.config["SQLALCHEMY_TRACK_MODIFICATIONS"] = False
    logger.info("数据库配置完成")


app = create_app()
CORS(app, resources={r"/*": {"origins": "*"}}, supports_credentials=True)
socketio = SocketIO(cors_allowed_origins="*")
socketio.init_app(app)

# 重试机制，尝试连接数据库
MAX_RETRIES = 10
last_exception = None
for i in range(MAX_RETRIES):
    try:
        with app.app_context():
            db.create_all()  # 或者其他一些会访问数据库的操作
    except exc.OperationalError as e:
        last_exception = e
        if i < MAX_RETRIES - 1:  # i 从0开始，所以这里使用 MAX_RETRIES - 1
            wait_time = 2**i  # 指数退避策略
            logger.info(f"数据库连接失败，等待 {wait_time} 秒后重试（第 {i+1} 次尝试）")
            time.sleep(wait_time)
            continue
        else:
            logger.error(f"数据库连接失败，已达最大尝试次数：{e}")
            raise
    break
else:  # 这个else块在for循环正常结束（即没有被break语句中断）时执行
    if last_exception is not None:
        raise last_exception


@app.route("/register", methods=["POST"])
def register():
    logger.info("开始注册用户")
    data = request.get_json()
    username = data.get("username")
    password = data.get("password")
    identity = data.get("identity")

    if not username or not password or not identity:
        logger.warning("缺少用户名、密码或身份信息")
        return jsonify({"message": "Missing username, password or identity"}), 400

    with app.app_context():
        user = User.query.filter_by(username=username).first()
        if user:
            logger.warning("用户已存在")
            return jsonify({"message": "User already exists"}), 400
        password_hash = generate_password_hash(password)
        new_user = User(
            username=username, password_hash=password_hash, identity=identity
        )
        db.session.add(new_user)
        db.session.commit()
    logger.info("用户注册成功")
    return jsonify({"message": "User registered successfully"}), 200


@app.route("/login", methods=["POST"])
def login():
    logger.debug("收到登录请求")
    data = request.get_json()
    username = data.get("username")
    password = data.get("password")

    if not username or not password:
        return jsonify({"message": "Missing username or password"}), 400

    with app.app_context():
        logger.debug(f"正在数据库中寻找用户: {username}")
        user = User.query.filter_by(username=username).first()
        if user:
            logger.debug(f"用户 {username} 存在, 正在检查密码")
            if check_password_hash(user.password_hash, password):
                session["username"] = username
                session["identity"] = user.identity
                # 创建响应，并设置 cookie 以与前端同步会话信息
                response = jsonify({"message": "Logged in successfully"})
                response.set_cookie("username", username)
                response.set_cookie("identity", user.identity)
                logger.debug(f"用户 {username} 成功登入系统")
                return response, 200
            else:
                logger.debug(f"用户 {username} 密码错误")
                return jsonify({"message": "Invalid username or password"}), 400
        else:
            logger.debug(f"用户 {username} 不存在")
            return jsonify({"message": "Invalid username or password"}), 400


@app.route("/menu", methods=["GET"])
def get_menu():
    logger.debug(f"获取菜单列表")
    with app.app_context():
        menu_items = MenuItem.query.all()
        menu = [item.serialize() for item in menu_items]
        return jsonify(menu)


@app.route("/menu", methods=["POST"])
def add_menu_item():
    logger.debug(f"添加菜单项")
    data = request.get_json()
    new_item = MenuItem(
        name=data["name"], price=data["price"], category=data["category"]
    )
    with app.app_context():
        db.session.add(new_item)
        db.session.commit()
        socketio.emit("new menuitem", "new menuitem")
    return jsonify({"message": "Menu item added successfully"})


@app.route("/menu/<int:item_id>", methods=["PUT"])
def update_menu_item(item_id):
    data = request.get_json()
    name = data.get("name")
    price = data.get("price")
    category = data.get("category")

    with app.app_context():
        item = MenuItem.query.get(item_id)
        if item:
            if name is not None:
                item.name = name
            if price is not None:
                item.price = price
            if category is not None:
                item.category = category
            db.session.commit()
            socketio.emit("modify menuitem", "modify menuitem")
            return jsonify({"message": "Menu item updated successfully"})
        else:
            return jsonify({"message": "Menu item not found"}), 404


@app.route("/menu/<int:item_id>", methods=["DELETE"])
def delete_menu_item(item_id):
    logger.debug(f"删除菜单项")
    with app.app_context():
        item = MenuItem.query.get(item_id)
        if item:
            db.session.delete(item)
            db.session.commit()
            socketio.emit("delete menuitem", "delete menuitem")
            return jsonify({"message": "Menu item deleted successfully"})
        else:
            return jsonify({"message": "Menu item not found"}), 404


@app.route("/orders", methods=["POST"])
def add_order():
    logger.debug(f"新增订单")
    data = request.get_json()
    new_order = Order(
        user=data["user"],
        timestamp=data["timestamp"],
        total=data["total"],
        items=json.dumps(data["items"]),
        isSubmitted=data.get("isSubmitted", False),
        isConfirmed=data.get("isConfirmed", False),
        isCompleted=data.get("isCompleted", False),
        isPaid=data.get("isPaid", False),
    )
    with app.app_context():
        db.session.add(new_order)
        db.session.commit()
        socketio.emit("new order", "A new order has been submitted")
        logger.debug(f"已发射new order事件,通知前端有新订单提交")
    return jsonify({"message": "Order added successfully"}), 200


@app.route("/orders", methods=["GET"])
def get_orders():
    with app.app_context():
        order_items = Order.query.all()
        orders = [item.serialize() for item in order_items]
        return jsonify(orders)


@app.route("/orders/submitted", methods=["GET"])
def get_submitted_orders():
    with app.app_context():
        order_items = Order.query.filter_by(
            isSubmitted=True, isPaid=False
        ).all()  # 修改这里，返回所有已提交且未支付的订单
        orders = [item.serialize() for item in order_items]
        return jsonify(orders)


@app.route("/orders/confirmed", methods=["GET"])
def get_confirmed_orders():
    with app.app_context():
        order_items = Order.query.filter_by(isConfirmed=True, isCompleted=False).all()
        orders = [item.serialize() for item in order_items]
        return jsonify(orders)


@app.route("/orders/confirm", methods=["POST"])
def confirm_order():
    data = request.get_json()
    order_id = data["id"]
    with app.app_context():
        order = Order.query.get(order_id)
        if order:
            order.isConfirmed = True
            db.session.commit()
            socketio.emit("order confirmed", {"order_id": order_id})
            logger.debug(f"已发射order confirmed事件,通知前端有新订单确认")
            return jsonify({"message": "Order confirmed successfully"}), 200
        else:
            return jsonify({"message": "Order not found"})


@app.route("/orders/complete_item", methods=["POST"])
def complete_order_item():
    data = request.get_json()
    order_id = data["orderId"]
    item_name = data["itemName"]
    with app.app_context():
        order = Order.query.get(order_id)
        if order:
            items = json.loads(order.items)
            if item_name in items:
                items[item_name]["isPrepared"] = True
                order.items = json.dumps(items)
                db.session.commit()
                socketio.emit("dish prepared", {"order_id": order_id})
                logger.debug(f"已发射dish prepared事件,通知前端有新订单确认")
                return jsonify({"message": "Order item completed successfully"})
            else:
                return jsonify({"message": "Order item not found"})
        else:
            return jsonify({"message": "Order not found"})


@app.route("/orders/serve_item", methods=["POST"])
def serve_order_item():
    data = request.get_json()
    order_id = data["orderId"]
    item_name = data["itemName"]
    with app.app_context():
        order = Order.query.get(order_id)
        if order:
            items = json.loads(order.items)
            if item_name in items and items[item_name]["isPrepared"]:
                items[item_name]["isServed"] = True
                order.items = json.dumps(items)
                if all(item["isServed"] for item in items.values()):
                    order.isCompleted = True
                db.session.commit()
                socketio.emit("dish served", {"order_id": order_id})
                return jsonify({"message": "Order item served successfully"})
            else:
                return jsonify({"message": "Order item not prepared or not found"})
        else:
            return jsonify({"message": "Order not found"})


@app.route("/users", methods=["GET"])
def get_users():
    with app.app_context():
        user_items = User.query.all()
        users = [item.serialize() for item in user_items]
        return jsonify(users)


@app.route("/users/<int:user_id>", methods=["DELETE"])
def delete_user(user_id):
    with app.app_context():
        user = User.query.get(user_id)
        if user:
            db.session.delete(user)
            db.session.commit()
            socketio.emit("delete user", "delete user")
            return jsonify({"message": "User deleted successfully"})
        else:
            return jsonify({"message": "User not found"}), 404


@app.route("/orders/<int:order_id>", methods=["DELETE"])
def delete_order(order_id):
    order = Order.query.get(order_id)
    if order is None:
        return jsonify({"error": "Order not found"}), 404

    db.session.delete(order)
    db.session.commit()
    socketio.emit("delete order", "delete order")
    return jsonify({"message": "Order deleted successfully"}), 200


@app.route("/orders/<int:order_id>", methods=["PUT"])
def modify_order(order_id):
    order = Order.query.get(order_id)
    if order is None:
        return jsonify({"error": "Order not found"}), 404

    updated_order = request.json
    order.user = updated_order["user"]
    order.timestamp = datetime.strptime(
        updated_order["timestamp"], "%Y-%m-%dT%H:%M:%S"
    )  # 修改格式字符串
    order.total = updated_order["total"]
    # order.isSubmitted = updated_order["isSubmitted"]
    # order.isConfirmed = updated_order["isConfirmed"]
    # order.isCompleted = updated_order["isCompleted"]
    # order.isPaid = updated_order["isPaid"]
    order.isSubmitted = True
    order.isConfirmed = True
    order.isCompleted = False
    order.isPaid = False
    order.items = json.dumps(updated_order["items"])

    db.session.commit()
    socketio.emit("order modified", {"order_id": order_id})

    return jsonify({"message": "Order modified successfully"}), 200


@app.route("/orders/pay", methods=["POST"])
def pay_order():
    data = request.get_json()
    order_id = data["id"]
    with app.app_context():
        order = Order.query.get(order_id)
        if order:
            order.isPaid = True
            db.session.commit()
            socketio.emit("order paid", {"order_id": order_id})  # 发送订单已支付的事件
            return jsonify({"message": "Order paid successfully"}), 200
        else:
            return jsonify({"message": "Order not found"})

@app.route("/orders/print", methods=["POST"])
def print_order():

    data = request.get_json()
    order_id = data["id"]
    with app.app_context():
        order = Order.query.get(order_id)
        if order:
            # Register a Chinese font
            pdfmetrics.registerFont(TTFont('AR PL UMing CN', '/usr/share/fonts/truetype/arphic/uming.ttc'))

            # Create a new PDF with Reportlab
            doc = SimpleDocTemplate("order.pdf", pagesize=letter,
                                    rightMargin=72, leftMargin=72,
                                    topMargin=72, bottomMargin=18)
            
            # Define two columns with Frames
            frame1 = Frame(doc.leftMargin, doc.bottomMargin, doc.width/2-7, doc.height, id='col1')
            frame2 = Frame(doc.leftMargin + doc.width/2 + 7, doc.bottomMargin, doc.width/2-6, doc.height, id='col2')
            doc.addPageTemplates([PageTemplate(id='TwoCol', frames=[frame1, frame2])])

            # Create a list for all the flowables
            story = []

            # Add order information to the PDF
            styles = getSampleStyleSheet()
            styles["BodyText"].fontName = 'AR PL UMing CN'
            styles["BodyText"].fontSize = 16
            styles["BodyText"].leading = 20
            styles["Title"].fontName = 'AR PL UMing CN'
            styles["Title"].fontSize = 24
            styles["Title"].leading = 30
            story.append(Paragraph(f"订单编号： {order.id}", styles["Title"]))
            story.append(Paragraph(f"顾客：    {order.user}", styles["BodyText"]))
            story.append(Paragraph(f"总价：    {order.total}  元", styles["BodyText"]))

            order_info = json.loads(order.items)
            data = [["菜品", "数量", "单价"]]  # Add table header
            for item_name, item_info in order_info.items():
                quantity = item_info.get("count", "N/A")
                price = item_info.get("price", "N/A")
                data.append([item_name, quantity, price])
            table = Table(data, hAlign='CENTER')

            table_style = TableStyle([
                ('FONTNAME', (0,0), (-1,-1), 'AR PL UMing CN'),
                ('FONTSIZE', (0,0), (-1,-1), 20),
                ('LEADING', (0,0), (-1,-1), 30),  # 新增行间距设置
                ('BACKGROUND', (0, 0), (-1, 0), colors.grey),  # table header color
                ('TEXTCOLOR', (0, 0), (-1, 0), colors.whitesmoke),  # table header text color
                ('ALIGN', (0, 0), (-1, -1), 'CENTER'),  # all text centered
                ('VALIGN', (0, 0), (-1, -1), 'MIDDLE')  # all text middle aligned
            ])
            table.setStyle(table_style)

            story.append(table)

            # Add a frame break to move to the next column
            story.append(FrameBreak())

            # Add the same content for the second column
            story.append(Paragraph(f"订单编号： {order.id}", styles["Title"]))
            story.append(Paragraph(f"顾客：    {order.user}", styles["BodyText"]))
            story.append(Paragraph(f"总价：    {order.total}  元", styles["BodyText"]))
            story.append(table)

            # Save the PDF
            doc.build(story)

            # Prepare the email
            msg = MIMEMultipart()
            msg["From"] = "haidishijierestaurant@outlook.com"
            msg["To"] = "jcc8792vm3h5e8@print.rpt.epson.com.cn"
            msg["Subject"] = "Print order"

            # Attach the PDF to the email
            with open("order.pdf", "rb") as f:
                attach = MIMEBase("application", "octet-stream")
                attach.set_payload(f.read())
            encoders.encode_base64(attach)
            attach.add_header(
                "Content-Disposition",
                "attachment",
                filename=str(order.id) + "_order.pdf",
            )
            msg.attach(attach)

            # Send the email
            server = smtplib.SMTP("smtp.office365.com", 587)
            server.starttls()
            server.login("haidishijierestaurant@outlook.com", "Haidishijie")
            server.sendmail(
                "haidishijierestaurant@outlook.com",
                "jcc8792vm3h5e8@print.rpt.epson.com.cn",
                msg.as_string(),
            )
            server.quit()

            return jsonify({"message": "Print request sent"}), 200
        else:
            return jsonify({"message": "Order not found"}), 404




@app.route("/summary", methods=["GET"])
def get_summary():
    # 获取当天的日期
    today = date.today()
    start_time = datetime.combine(today, datetime.min.time())
    end_time = datetime.combine(today, datetime.max.time())

    # 计算当天的营业额
    revenue_today = (
        db.session.query(db.func.sum(Order.total))
        .filter(Order.timestamp.between(start_time, end_time), Order.isPaid == True)
        .scalar()
        or 0.0
    )

    # 计算用户数量
    user_count = db.session.query(User).count()

    # 计算菜品数量
    menu_item_count = db.session.query(MenuItem).count()

    # 计算订单数量
    order_count = db.session.query(Order).count()

    return jsonify(
        {
            "revenueToday": revenue_today,
            "userCount": user_count,
            "menuItemCount": menu_item_count,
            "orderCount": order_count,
        }
    )


if __name__ == "__main__":
    app.run(debug=True)
