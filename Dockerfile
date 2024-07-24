# Use the official Python image from the Docker Hub
FROM python:3.9-slim

# Set the working directory inside the container
WORKDIR /app

# Copy the current directory contents into the container at /app
COPY . /app

# Install any needed packages specified in requirements.txt
# (for a simple HTTP server, we don't need any additional packages)

# Expose port 8000 to the outside world
EXPOSE 8000

# Run the command to start the HTTP server
CMD ["python3", "-m", "http.server", "8000"]
