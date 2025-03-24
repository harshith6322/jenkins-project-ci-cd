#Build stage
FROM node:21 AS builder
WORKDIR /app
COPY package*.json ./app
RUN npm install
COPY . .
RUN npm run build

#production stage
FROM nginx:alpine AS production-stage
COPY --from=builder /app/dist /usr/share/nginx/html
EXPOSE 80
# Start Nginx when the container starts
CMD ["nginx", "-g", "daemon off;"]





## reference
# # Use an official Node.js image as the base
# FROM node:16 as build-stage

# # Set the working directory in the container
# WORKDIR /app

# # Copy package.json and install dependencies
# COPY package*.json ./
# RUN npm install

# # Copy the rest of the application code
# COPY . .

# # Build the app
# RUN npm run build

# # Use a lightweight web server for the production stage
# FROM nginx:alpine as production-stage

# # Copy the React build files to the Nginx HTML directory
# COPY --from=build-stage /app/build /usr/share/nginx/html

# # Expose port 80
# EXPOSE 80

# # Start Nginx when the container starts
# CMD ["nginx", "-g", "daemon off;"]

