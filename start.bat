@echo off

start cmd /k "conda activate FlutterBackend && cd /d C:\Sisyphus\Projects\RestaurantOrderingSystem\backend && python run.py"

start cmd /k "cd /d C:\Sisyphus\Projects\RestaurantOrderingSystem\resordsys && flutter run -d edge"