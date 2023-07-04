from flask import Flask, jsonify, request
from flask_cors import CORS
from models import MenuItem, Order
from database import db
from flask_sqlalchemy import SQLAlchemy
import json

def create_app():
    app = Flask(__name__)
    configure_db(app)
    CORS(app)
    db.init_app(app)
    return app

# 配置数据库连接。使用 Flask-SQLAlchemy 库建立与数据库的连接，配置数据库的 URI 和跟踪修改等设置。
def configure_db(app):
    app.config['SQLALCHEMY_DATABASE_URI'] = 'mysql://root:sisyphus@localhost/restaurant'
    app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False

app = create_app()

# 路由: 获取所有菜单项
@app.route('/menu', methods=['GET'])
def get_menu():
    with app.app_context():
        menu_items = MenuItem.query.all()
        menu = [item.serialize() for item in menu_items]
        return jsonify(menu)

# 路由: 添加新的菜单项
@app.route('/menu', methods=['POST'])
def add_menu_item():
    data = request.get_json()
    new_item = MenuItem(name=data['name'], price=data['price'])
    with app.app_context():
        db.session.add(new_item)
        db.session.commit()
    return jsonify({'message': 'Menu item added successfully'})

# 路由: 添加订单
@app.route('/orders', methods=['POST'])
def add_order():
    data = request.get_json()
    new_order = Order(
        user=data['user'], 
        timestamp=data['timestamp'], 
        total=data['total'], 
        items=json.dumps(data['items']),
        isSubmitted=data.get('isSubmitted', False),  # 从请求体中获取这些字段的值，如果不存在则默认为 False
        isConfirmed=data.get('isConfirmed', False),
        isCompleted=data.get('isCompleted', False)
    )
    with app.app_context():
        db.session.add(new_order)
        db.session.commit()
    return jsonify({'message': 'Order added successfully'})

# 路由: 获取所有订单
@app.route('/orders', methods=['GET'])
def get_orders():
    with app.app_context():
        order_items = Order.query.all()
        orders = [item.serialize() for item in order_items]
        return jsonify(orders)

# 路由: 获取所有提交但未完成的订单
@app.route('/orders/submitted', methods=['GET'])
def get_submitted_orders():
    with app.app_context():
        order_items = Order.query.filter_by(isSubmitted=True, isCompleted=False).all()
        orders = [item.serialize() for item in order_items]
        return jsonify(orders)

# 路由: 获取所有已确认但未完成的订单
@app.route('/orders/confirmed', methods=['GET'])
def get_confirmed_orders():
    with app.app_context():
        order_items = Order.query.filter_by(isConfirmed=True, isCompleted=False).all()
        orders = [item.serialize() for item in order_items]
        return jsonify(orders)

# 路由: 确认订单
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

# 路由: 完成订单中的菜品
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

if __name__ == '__main__':
    app.run(debug=True)
