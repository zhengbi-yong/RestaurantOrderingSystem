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


def configure_db(app):
    app.config['SQLALCHEMY_DATABASE_URI'] = 'mysql://root:sisyphus@localhost/restaurant'
    app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False


app = create_app()


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
