```markdown
# Docker Setup Guide

This repository contains a Docker-based development and production environment for our Node.js/TypeScript application with Nginx as a reverse proxy.

## 🏗️ Project Structure

```
.
├── Dockerfile              # Main application Dockerfile
├── Dockerfile.local        # Nginx Dockerfile
├── docker-compose.yml      # Base Docker composition
├── docker-compose.override.yml  # Development overrides
└── nginx/
    ├── nginx.dev.conf     # Nginx development configuration
    └── nginx.prod.conf    # Nginx production configuration
```

## 🚀 Quick Start

### Development Mode

```bash
# Start the development environment
docker compose up --build

# Start in detached mode
docker compose up --build -d
```

Development mode includes:
- Hot-reloading
- Full TypeScript support
- All development dependencies
- Volume mounts for live code updates

### Production Mode

```bash
# Start production environment (without override file)
docker compose -f docker-compose.yml up --build

# Start in detached mode
docker compose -f docker-compose.yml up --build -d
```

## 🛠️ Common Commands

### Container Management

```bash
# Stop all containers
docker compose down

# Stop and remove volumes, containers, and images
docker compose down -v --rmi all

# Restart a specific service
docker compose restart api
docker compose restart nginx

# View running containers
docker compose ps

# Access container shell
docker compose exec api sh
docker compose exec nginx sh
```

### Logs

```bash
# View logs from all services
docker compose logs -f

# View logs from specific service
docker compose logs -f api
docker compose logs -f nginx
```

### Cleanup

```bash
# Remove unused containers, networks, and images
docker system prune

# Remove all unused volumes
docker volume prune

# Remove everything and start fresh
docker compose down -v --rmi all
docker system prune -a
```

## 🌐 Access Points

- API through Nginx: `http://localhost/`
- API health check: `http://localhost/health`
- Direct API access (if configured in override): `http://localhost:8000`

## 🔧 Configuration

### Environment Variables

#### API Service
```env
NODE_ENV=development|production
PORT=8000
```

### Docker Compose Files

- `docker-compose.yml`: Base configuration for all environments
- `docker-compose.override.yml`: Development-specific settings

## 💡 Development Tips

### Rebuilding Containers

```bash
# Rebuild a specific service
docker compose build api

# Rebuild all services
docker compose build

# Force rebuild with no cache
docker compose build --no-cache
```

### Debugging

```bash
# Check container logs
docker compose logs -f api

# Access container shell
docker compose exec api sh

# View running processes
docker compose top
```

### Volume Management

```bash
# List volumes
docker volume ls

# Clean up unused volumes
docker volume prune
```

## 🔒 Production Deployment

For production deployment:

1. Use only the base docker-compose.yml:
```bash
docker compose -f docker-compose.yml up -d
```

2. Ensure proper environment variables are set
3. Use proper SSL certificates in Nginx
4. Consider using Docker secrets for sensitive data

## 🚨 Troubleshooting

### Common Issues

1. **Port conflicts**
```bash
# Check for port usage
sudo lsof -i :80
sudo lsof -i :8000
```

2. **Container won't start**
```bash
# Check logs
docker compose logs -f

# Verify container status
docker compose ps
```

3. **Volume permission issues**
```bash
# Reset permissions
sudo chown -R $USER:$USER .
```

### Health Checks

The setup includes health checks for both services:
- API: Checks `/health` endpoint every 30s
- Nginx: Checks HTTP response every 30s

Monitor health status:
```bash
docker compose ps
```

## 📝 Notes

- Development mode uses volume mounts for hot-reloading
- Production mode runs compiled code
- Nginx serves as a reverse proxy
- All internal communication happens over the `app_network` bridge network
```
