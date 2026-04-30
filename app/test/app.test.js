const request = require('supertest');
const app = require('../app');

describe('DevOps TP App - Tests Unitaires', () => {

  describe('GET /', () => {
    test('doit retourner status ok et les infos de version', async () => {
      const res = await request(app).get('/');
      expect(res.statusCode).toBe(200);
      expect(res.body.status).toBe('ok');
      expect(res.body.message).toBe('DevOps TP App');
      expect(res.body.version).toBe('1.0');
      expect(res.body.timestamp).toBeDefined();
    });
  });

  describe('GET /health', () => {
    test('doit retourner health UP avec status 200', async () => {
      const res = await request(app).get('/health');
      expect(res.statusCode).toBe(200);
      expect(res.body.health).toBe('UP');
    });
  });

  describe('GET /metrics-info', () => {
    test('doit retourner les metriques systeme', async () => {
      const res = await request(app).get('/metrics-info');
      expect(res.statusCode).toBe(200);
      expect(res.body.uptime).toBeDefined();
      expect(res.body.memoryUsage).toBeDefined();
      expect(res.body.nodeVersion).toBeDefined();
    });
  });

  describe('Route inexistante', () => {
    test('doit retourner 404 pour une route inconnue', async () => {
      const res = await request(app).get('/route-inexistante');
      expect(res.statusCode).toBe(404);
    });
  });

});
