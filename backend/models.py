from database import db
import json
from werkzeug.security import generate_password_hash, check_password_hash


class User(db.Model):
    __tablename__ = "users"
    id = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.String(50), unique=True, nullable=False)
    password_hash = db.Column(db.String(512), nullable=False)
    identity = db.Column(db.String(20), nullable=False)

    def set_password(self, password):
        self.password_hash = generate_password_hash(password)

    def check_password(self, password):
        return check_password_hash(self.password_hash, password)

    def serialize(self):
        return {
            "id": self.id,
            "username": self.username,
            "identity": self.identity,
        }


class MenuItem(db.Model):
    __tablename__ = "menu_items"
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(100), nullable=False)
    price = db.Column(db.Float, nullable=False)
    category = db.Column(db.String(100), nullable=False)

    def serialize(self):
        return {
            "id": self.id,
            "name": self.name,
            "price": self.price,
            "category": self.category,
        }


class Order(db.Model):
    __tablename__ = "orders"
    id = db.Column(db.Integer, primary_key=True)
    user = db.Column(db.String(100), nullable=False)
    timestamp = db.Column(db.DateTime, nullable=False)
    total = db.Column(db.Float, nullable=False)
    isSubmitted = db.Column(db.Boolean, default=False)
    isConfirmed = db.Column(db.Boolean, default=False)
    isCompleted = db.Column(db.Boolean, default=False)
    isPaid = db.Column(db.Boolean, default=False)  # 新增字段，表示订单是否已付款
    items = db.Column(db.String(5000), nullable=False)

    def serialize(self):
        return {
            "id": self.id,
            "user": self.user,
            "timestamp": self.timestamp.isoformat(),
            "total": self.total,
            "isSubmitted": self.isSubmitted,
            "isConfirmed": self.isConfirmed,
            "isCompleted": self.isCompleted,
            "isPaid": self.isPaid,  # 新增字段，表示订单是否已付款
            "items": json.loads(self.items),
        }
