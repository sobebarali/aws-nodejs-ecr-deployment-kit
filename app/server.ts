import express, { Express, Request, Response, NextFunction } from 'express';
import cors from 'cors';
import helmet from 'helmet';
import dotenv from 'dotenv';
import compression from 'compression';
import hpp from 'hpp';
import mongoSanitize from 'express-mongo-sanitize';
import morgan from 'morgan';

// Load environment variables
dotenv.config();

// Define types for environment variables
interface ServerConfig {
  port: number;
  nodeEnv: string;
}

// Server configuration with default values
const config: ServerConfig = {
  port: parseInt(process.env.PORT ?? '3000', 10),
  nodeEnv: process.env.NODE_ENV ?? 'development',
};

// Initialize express app
const app: Express = express();

// Middleware
app.use(
  helmet({
    contentSecurityPolicy: config.nodeEnv === 'production',
    crossOriginEmbedderPolicy: config.nodeEnv === 'production',
  })
); // Security headers
app.use(cors()); // Enable CORS
app.use(express.json()); // Parse JSON bodies
app.use(compression());

// Prevent parameter pollution
app.use(hpp());

// Sanitize data
app.use(mongoSanitize());

// Add custom logging format
const morganFormat =
  config.nodeEnv === 'production' ? 'combined' : ':method :url :status :response-time ms';

// Add logging middleware
app.use(
  morgan(morganFormat, {
    skip: (req) => req.url === '/health', // Skip logging health checks
  })
);

// Basic error handling middleware
const errorHandler = (err: Error, req: Request, res: Response, _next: NextFunction): void => {
  console.error('Error:', err);
  res.status(500).json({
    status: 'error',
    message: 'Internal server error',
  });
};

// Basic health check endpoint
app.get('/health', (_req: Request, res: Response) => {
  res.status(200).json({
    status: 'ok',
    timestamp: new Date().toISOString(),
  });
});

// Apply error handler
app.use(errorHandler);

// Start server

const startServer = async (): Promise<void> => {
  try {
    const server = app.listen(config.port, () => {
      console.log(`Server running on port ${config.port} in ${config.nodeEnv} mode`);
    });

    // Graceful shutdown handler
    const gracefulShutdown = async (signal: string): Promise<void> => {
      console.log(`${signal} received. Starting graceful shutdown`);

      server.close(() => {
        console.log('Server closed');
        process.exit(0);
      });

      // Force close after 10s
      setTimeout(() => {
        console.error('Could not close connections in time, forcefully shutting down');
        process.exit(1);
      }, 10000);
    };

    process.on('SIGTERM', () => gracefulShutdown('SIGTERM'));
    process.on('SIGINT', () => gracefulShutdown('SIGINT'));
  } catch (error) {
    console.error('Failed to start server:', error);
    process.exit(1);
  }
};

if (config.nodeEnv !== 'test') {
  startServer();
}

// Export for testing purposes
export default app;
