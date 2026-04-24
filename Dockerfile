# Stage 1: Build the Angular application
FROM node:18-alpine AS build
WORKDIR /app

# Copy package files and install dependencies cleanly
COPY package*.json ./
RUN npm ci --legacy-peer-deps

# Copy the rest of the application code
COPY . .

# Build the project for production. 
# NOTE: Check the package.json of your chosen project. The command might just be `npm run build`
RUN npm run build --configuration=production 

# Stage 2: Serve the application with Nginx
FROM nginx:alpine

# Remove default nginx website
RUN rm -rf /usr/share/nginx/html/*

# Copy the built output from Stage 1 to Nginx
# IMPORTANT: Change 'project-name' to the actual output folder name found in angular.json
COPY --from=build /app/dist/browser /usr/share/nginx/html

# Copy the custom Nginx configuration
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
