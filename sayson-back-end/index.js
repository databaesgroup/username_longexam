import 'dotenv/config';
import express from 'express';
import cors from 'cors';
import { connectDB } from './db.js';
import userRoutes from './routes/userRoutes.js';
import articleRoutes from './routes/articleRoutes.js';

const app = express();
app.use(cors());
app.use(express.json());

app.get('/', (_, res) => res.json({ ok: true }));
app.use('/api', userRoutes);
app.use('/api', articleRoutes);

await connectDB(process.env.MONGO_URI);
const port = process.env.PORT || 8000;
app.listen(port, () => console.log(`API running on http://localhost:${port}`));
