# Use the official Python image
FROM python:3.9-slim

# Set the working directory in the container
WORKDIR /app

# Copy the current directory contents into the container at /app
COPY . /app

# Install required packages
RUN pip install Flask requests

# Expose the port Flask is running on
EXPOSE 8100

# Run the Flask application
CMD ["python", "app.py"]