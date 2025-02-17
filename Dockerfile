# Build stage
FROM node:lts-alpine AS builder

WORKDIR /app

COPY package*.json ./

# Only install production dependencies
RUN npm ci --only=production && \
    npm cache clean --force

COPY . .

# Production stage
FROM node:lts-alpine

# Install only necessary system packages
RUN apk --no-cache add dumb-init

WORKDIR /app

# Copy only necessary files from builder
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/api ./api
COPY --from=builder /app/package.json .

# Use dumb-init as entrypoint to handle signals properly
ENTRYPOINT ["dumb-init", "--"]

EXPOSE 8787

CMD ["npm", "start"]
