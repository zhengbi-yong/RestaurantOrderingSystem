from database import db
import json


class MenuItem(db.Model):
    __tablename__ = 'menu_items'
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(100), nullable=False)
    price = db.Column(db.Float, nullable=False)

    def serialize(self):
        return {
            'id': self.id,
            'name': self.name,
            'price': self.price
        }


class Order(db.Model):
    __tablename__ = 'orders'
    id = db.Column(db.Integer, primary_key=True)
    user = db.Column(db.String(100), nullable=False)
    timestamp = db.Column(db.DateTime, nullable=False)
    total = db.Column(db.Float, nullable=False)
    items = db.Column(db.String(5000), nullable=False)  # 我们将把菜品信息保存为字符串

    def serialize(self):
        print(self.items)
        print(json.loads(self.items))
        return {
            'user': self.user,
            'timestamp': self.timestamp.isoformat(),
            'total': self.total,
            'items': json.loads(self.items)
        }
