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
from datetime import datetime
import time
from database import db
import sys
# 创建日志记录器
logger = logging.getLogger(__name__)
logger.setLevel(logging.DEBUG)

# 创建文件处理器
file_handler = logging.FileHandler('app.log')
file_handler.setLevel(logging.DEBUG)

# 创建日志记录格式
log_format = logging.Formatter('[%(asctime)s] %(levelname)s: %(message)s', datefmt='%Y-%m-%d %H:%M:%S')
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
    logger.info('开始创建程序')
    app = Flask(__name__)
    configure_db(app)
    logger.debug('数据库设置完成')
    CORS(app)
    logger.debug('跨域设置完成')
    db.init_app(app)
    app.config['SECRET_KEY'] = 'your-secret-key'
    logger.info('创建程序完成')
    return app

def configure_db(app):
    app.config['SQLALCHEMY_DATABASE_URI'] = f'mysql://root:sisyphus@db:3306/restaurant'
    app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False

app = create_app()

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
            wait_time = 2 ** i  # 指数退避策略
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



@app.route('/register', methods=['POST'])
def register():
    logger.info('开始注册用户...')
    data = request.get_json()
    username = data.get('username')
    password = data.get('password')
    identity = data.get('identity')

    if not username or not password or not identity:
        logger.warning('缺少用户名、密码或身份信息')
        return jsonify({'message': 'Missing username, password or identity'}), 400

    with app.app_context():
        user = User.query.filter_by(username=username).first()
        if user:
            logger.warning('用户已存在')
            return jsonify({'message': 'User already exists'}), 400
        password_hash = generate_password_hash(password)
        new_user = User(username=username, password_hash=password_hash, identity=identity)
        db.session.add(new_user)
        db.session.commit()
    logger.info('用户注册成功')
    return jsonify({'message': 'User registered successfully'}), 200


@app.route('/login', methods=['POST'])
def login():
    logger.debug('Received login request')
    data = request.get_json()
    username = data.get('username')
    password = data.get('password')

    if not username or not password:
        return jsonify({'message': 'Missing username or password'}), 400

    with app.app_context():
        logger.debug(f'Attempting to find user: {username}')
        user = User.query.filter_by(username=username).first()
        if user:
            logger.debug(f'User {username} found, checking password...')
            if check_password_hash(user.password_hash, password):
                session['username'] = username
                session['identity'] = user.identity
                # 创建响应，并设置 cookie 以与前端同步会话信息
                response = jsonify({'message': 'Logged in successfully'})
                response.set_cookie('username', username)
                response.set_cookie('identity', user.identity)
                logger.debug(f'User {username} logged in successfully')
                return response, 200
            else:
                logger.debug(f'Incorrect password for user {username}')
                return jsonify({'message': 'Invalid username or password'}), 400
        else:
            logging.debug(f'User {username} not found')
            return jsonify({'message': 'Invalid username or password'}), 400


@app.route('/menu', methods=['GET'])
def get_menu():
    with app.app_context():
        menu_items = MenuItem.query.all()
        menu = [item.serialize() for item in menu_items]
        return jsonify(menu)


@app.route('/menu', methods=['POST'])
def add_menu_item():
    data = request.get_json()
    new_item = MenuItem(name=data['name'], price=data['price'])
    with app.app_context():
        db.session.add(new_item)
        db.session.commit()
    return jsonify({'message': 'Menu item added successfully'})


@app.route('/menu/<int:item_id>', methods=['DELETE'])
def delete_menu_item(item_id):
    with app.app_context():
        item = MenuItem.query.get(item_id)
        if item:
            db.session.delete(item)
            db.session.commit()
            return jsonify({'message': 'Menu item deleted successfully'})
        else:
            return jsonify({'message': 'Menu item not found'}), 404


@app.route('/orders', methods=['POST'])
def add_order():
    data = request.get_json()
    new_order = Order(
        user=data['user'],
        timestamp=data['timestamp'],
        total=data['total'],
        items=json.dumps(data['items']),
        isSubmitted=data.get('isSubmitted', False),
        isConfirmed=data.get('isConfirmed', False),
        isCompleted=data.get('isCompleted', False)
    )
    with app.app_context():
        db.session.add(new_order)
        db.session.commit()
    return jsonify({'message': 'Order added successfully'})


@app.route('/orders', methods=['GET'])
def get_orders():
    with app.app_context():
        order_items = Order.query.all()
        orders = [item.serialize() for item in order_items]
        return jsonify(orders)


@app.route('/orders/submitted', methods=['GET'])
def get_submitted_orders():
    with app.app_context():
        order_items = Order.query.filter_by(
            isSubmitted=True, isCompleted=False).all()
        orders = [item.serialize() for item in order_items]
        return jsonify(orders)


@app.route('/orders/confirmed', methods=['GET'])
def get_confirmed_orders():
    with app.app_context():
        order_items = Order.query.filter_by(
            isConfirmed=True, isCompleted=False).all()
        orders = [item.serialize() for item in order_items]
        return jsonify(orders)


@app.route('/orders/confirm', methods=['POST'])
def confirm_order():
    data = request.get_json()
    order_id = data['id']
    with app.app_context():
        order = Order.query.get(order_id)
        if order:
            order.isConfirmed = True
            db.session.commit()
            return jsonify({'message': 'Order confirmed successfully'})
        else:
            return jsonify({'message': 'Order not found'})


@app.route('/orders/complete_item', methods=['POST'])
def complete_order_item():
    data = request.get_json()
    order_id = data['orderId']
    item_name = data['itemName']
    with app.app_context():
        order = Order.query.get(order_id)
        if order:
            items = json.loads(order.items)
            if item_name in items:
                items[item_name]['isPrepared'] = True
                order.items = json.dumps(items)
                db.session.commit()
                return jsonify({'message': 'Order item completed successfully'})
            else:
                return jsonify({'message': 'Order item not found'})
        else:
            return jsonify({'message': 'Order not found'})


@app.route('/orders/serve_item', methods=['POST'])
def serve_order_item():
    data = request.get_json()
    order_id = data['orderId']
    item_name = data['itemName']
    with app.app_context():
        order = Order.query.get(order_id)
        if order:
            items = json.loads(order.items)
            if item_name in items and items[item_name]['isPrepared']:
                items[item_name]['isServed'] = True
                order.items = json.dumps(items)
                if all(item['isServed'] for item in items.values()):
                    order.isCompleted = True
                db.session.commit()
                return jsonify({'message': 'Order item served successfully'})
            else:
                return jsonify({'message': 'Order item not prepared or not found'})
        else:
            return jsonify({'message': 'Order not found'})


if __name__ == '__main__':
    app.run(debug=True)
