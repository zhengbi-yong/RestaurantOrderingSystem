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
    isSubmitted = db.Column(db.Boolean, default=False)  # 新增字段，表示订单是否已提交
    isConfirmed = db.Column(db.Boolean, default=False)  # 新增字段，表示订单是否已确认
    isCompleted = db.Column(db.Boolean, default=False)  # 新增字段，表示订单是否已完成
    items = db.Column(db.String(5000), nullable=False)  # 我们将把菜品信息保存为字符串，其中每个菜品也有一个状态字段表示是否已完成

    def serialize(self):
        return {
            'id': self.id,
            'user': self.user,
            'timestamp': self.timestamp.isoformat(),
            'total': self.total,
            'isSubmitted': self.isSubmitted,
            'isConfirmed': self.isConfirmed,
            'isCompleted': self.isCompleted,
            'items': json.loads(self.items)
        }
