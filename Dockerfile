# Build stage
FROM node:20-alpine AS builder

# Set working directory
WORKDIR /app

# Copy package files
COPY package*.json ./

# Install ALL dependencies (including devDependencies)
RUN npm ci

# Copy source code
COPY . .

# Build TypeScript code
RUN npm run build

# Production stage
FROM node:20-alpine

# Set working directory
WORKDIR /app

# Set NODE_ENV
ARG NODE_ENV=production
ENV NODE_ENV=${NODE_ENV}

# Copy package files
COPY package*.json ./

# Install dependencies (if NODE_ENV=production, only prod dependencies will be installed)
RUN if [ "$NODE_ENV" = "production" ] ; then npm ci --only=production ; else npm ci ; fi

# Copy built files from builder stage (for production)
COPY --from=builder /app/dist ./dist

# Copy source code (for development)
COPY . .

# Add healthcheck
HEALTHCHECK --interval=30s --timeout=3s \
    CMD wget --quiet --tries=1 --spider http://localhost:3000/health || exit 1

# Expose port
EXPOSE 3000

# Start the server based on NODE_ENV
CMD if [ "$NODE_ENV" = "production" ] ; then npm start ; else npm run dev ; fi