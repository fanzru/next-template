# Stage 1: Build the application
# Use Node.js 20 as the base image for the build environment
FROM node:20-alpine AS builder

# Set the working directory inside the container
WORKDIR /app

# Copy package.json and bun.lock, then install dependencies using Bun
COPY package.json bun.lock ./
RUN bun install

# Copy all source files from the host to the container
COPY . .

# Create a production build of the application
# Use Bun to run the build command
RUN bun run build

# Stage 2: Run the application
# Use a lightweight and secure Node.js 20 image for production
FROM node:20-slim AS runner

# Set environment variables for production
ENV NODE_ENV=production

# Set the working directory for the runner stage
WORKDIR /app

# Copy the necessary files from the builder stage
# This creates a minimal image for production
COPY --from=builder /app/public ./public
COPY --from=builder /app/.next ./.next
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/package.json ./package.json

# Expose the port that Next.js will use
EXPOSE 3000

# Start the Next.js server
CMD ["node_modules/.bin/next", "start"]
