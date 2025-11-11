# Use official Node.js LTS image based on Debian
FROM node:20-bullseye

# Install build and X11-related deps needed by native modules like robotjs
RUN apt-get update \
  && apt-get install -y --no-install-recommends \
     build-essential \
     python3 \
     pkg-config \
     libcairo2-dev \
     libx11-dev \
     libxkbfile-dev \
     libxtst-dev \
     libpng-dev \
     ca-certificates \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy package manifests and install dependencies first (layer caching)
COPY package*.json ./

# Install production dependencies (use npm ci for reproducible installs)
RUN npm ci --only=production

# Copy source
COPY . /app

# Run as unprivileged user for safety
RUN useradd --user-group --create-home --shell /bin/false appuser \
  && chown -R appuser:appuser /app
USER appuser

ENV NODE_ENV=production

# This project runs as a stdio MCP server; no HTTP port is required
CMD ["node", "server.js"]
