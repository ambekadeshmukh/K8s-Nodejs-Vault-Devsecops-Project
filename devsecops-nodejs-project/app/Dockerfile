# Use Node.js 16 Alpine as the base image (smaller footprint)
FROM node:16-alpine

# Set working directory
WORKDIR /usr/src/app

# Install security updates
RUN apk update && apk upgrade

# Create non-root user for better security
RUN addgroup -S nodeapp && adduser -S -G nodeapp nodeapp

# Copy package.json and package-lock.json
COPY package*.json ./

# Install dependencies
RUN npm ci --only=production

# Copy application code
COPY . .

# Change ownership to non-root user
RUN chown -R nodeapp:nodeapp /usr/src/app

# Set user
USER nodeapp

# Expose the port the app will run on
EXPOSE 3000

# Run the application
CMD ["node", "app.js"]