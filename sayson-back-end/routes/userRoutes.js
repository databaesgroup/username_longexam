import { Router } from 'express';
import { register, login, me } from '../controllers/userController.js';
import { auth } from '../middleware/auth.js';
const r = Router();

r.post('/users', register); // Sign Up
r.post('/auth/login', login); // Login
r.get('/users/me', auth, me); // Profile

export default r;
