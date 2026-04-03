#!/bin/bash

# Start the Python backend in the background
echo "Starting backend server..."
cd lib/backend
venv/bin/python -m uvicorn main:app --reload --port 8000 &
BACKEND_PID=$!
echo "Backend running on PID $BACKEND_PID"

cd ../..

# Run the flutter app
echo "Starting Flutter app..."
flutter run

# Cleanup the backend when Flutter exits
echo "Cleaning up backend server..."
kill -9 $BACKEND_PID
