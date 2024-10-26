# Use an official Python runtime as a parent image
FROM python:3.10

# Set the working directory in the container
WORKDIR /app


# Copy the rest of the application code into the container
COPY . .


# Install any needed packages specified in requirements.txt
RUN pip install -r requirements.txt

# Expose the port your app runs on
EXPOSE 5000

# Copy the rest of the application code into the container
COPY . .

# Run the application
CMD ["python", "run.py"]
