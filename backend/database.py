from flask_sqlalchemy import SQLAlchemy

db = SQLAlchemy()

# 配置数据库连接。使用 Flask-SQLAlchemy 库建立与数据库的连接，配置数据库的 URI 和跟踪修改等设置。
def configure_db(app):
    app.config['SQLALCHEMY_DATABASE_URI'] = 'mysql://root:sisyphus@localhost/restaurant'
    app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
    db.init_app(app)
